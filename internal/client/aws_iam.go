package kmsclient

import (
	"context"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	v4 "github.com/aws/aws-sdk-go-v2/aws/signer/v4"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
)

// AWS instance-metadata-service (IMDSv2) endpoints used to discover the region
// when it is not already provided by the default AWS config chain.
const (
	awsEC2MetadataTokenURL            = "http://169.254.169.254/latest/api/token"
	awsEC2InstanceIdentityDocumentURL = "http://169.254.169.254/latest/dynamic/instance-identity/document"
)

// awsIamAuthLoginRequest mirrors the body the Hanzo KMS server expects on the
// AWS IAM machine-identity login endpoint.
type awsIamAuthLoginRequest struct {
	HTTPRequestMethod string `json:"iamHttpRequestMethod"`
	IamRequestBody    string `json:"iamRequestBody"`
	IamRequestHeaders string `json:"iamRequestHeaders"`
	IdentityId        string `json:"identityId"`
	OrganizationSlug  string `json:"organizationSlug,omitempty"`
}

// awsIamMachineIdentityLogin signs a GetCallerIdentity request against AWS STS
// with the caller's IAM credentials and exchanges the signed request for a
// Hanzo KMS access token. The KMS server independently replays the signed
// request against STS to verify the caller's identity.
func (client Client) awsIamMachineIdentityLogin(identityID, organizationSlug string) (string, error) {
	awsCredentials, awsRegion, err := retrieveAwsCredentials()
	if err != nil {
		return "", err
	}

	// Prepare the STS GetCallerIdentity request for SigV4 signing.
	iamRequestURL := fmt.Sprintf("https://sts.%s.amazonaws.com/", awsRegion)
	iamRequestBody := "Action=GetCallerIdentity&Version=2011-06-15"

	req, err := http.NewRequest(http.MethodPost, iamRequestURL, strings.NewReader(iamRequestBody))
	if err != nil {
		return "", fmt.Errorf("error creating HTTP request: %v", err)
	}

	currentTime := time.Now().UTC()
	req.Header.Add("X-Amz-Date", currentTime.Format("20060102T150405Z"))

	hashGenerator := sha256.New()
	hashGenerator.Write([]byte(iamRequestBody))
	payloadHash := fmt.Sprintf("%x", hashGenerator.Sum(nil))

	signer := v4.NewSigner()
	if err := signer.SignHTTP(context.TODO(), awsCredentials, req, payloadHash, "sts", awsRegion, time.Now()); err != nil {
		return "", fmt.Errorf("error signing request: %v", err)
	}

	realHeaders := make(map[string]string)
	for name, values := range req.Header {
		if strings.ToLower(name) == "content-length" {
			continue
		}
		realHeaders[name] = values[0]
	}
	realHeaders["Host"] = fmt.Sprintf("sts.%s.amazonaws.com", awsRegion)
	realHeaders["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
	realHeaders["Content-Length"] = fmt.Sprintf("%d", len(iamRequestBody))

	jsonStringHeaders, err := json.Marshal(realHeaders)
	if err != nil {
		return "", fmt.Errorf("error marshalling headers: %v", err)
	}

	var loginResponse MachineIdentityAuthResponse

	// The login endpoint is unauthenticated; clone the base client so we do not
	// leak an Authorization header onto the request.
	clonedClient := client.Config.HttpClient.Clone()
	clonedClient.SetAuthToken("")
	clonedClient.SetAuthScheme("")

	res, err := clonedClient.R().
		SetResult(&loginResponse).
		SetHeader("User-Agent", USER_AGENT).
		SetBody(awsIamAuthLoginRequest{
			HTTPRequestMethod: req.Method,
			IamRequestBody:    base64.StdEncoding.EncodeToString([]byte(iamRequestBody)),
			IamRequestHeaders: base64.StdEncoding.EncodeToString(jsonStringHeaders),
			IdentityId:        identityID,
			OrganizationSlug:  organizationSlug,
		}).
		Post("api/v1/auth/aws-auth/login")

	if err != nil {
		return "", fmt.Errorf("AwsIamMachineIdentityAuth: unable to get machine identity token [err=%s]", err)
	}

	if res.IsError() {
		return "", fmt.Errorf("AwsIamMachineIdentityAuth: unsuccessful response [status-code=%d] [response=%s]", res.StatusCode(), res.String())
	}

	return loginResponse.AccessToken, nil
}

// retrieveAwsCredentials resolves AWS credentials and region from the standard
// AWS configuration chain, falling back to the EC2 instance metadata service
// for the region when it is not otherwise configured.
func retrieveAwsCredentials() (aws.Credentials, string, error) {
	presetAwsCfg, err := awsconfig.LoadDefaultConfig(context.TODO())
	if err == nil && presetAwsCfg.Region != "" {
		if creds, credErr := presetAwsCfg.Credentials.Retrieve(context.TODO()); credErr == nil {
			return creds, presetAwsCfg.Region, nil
		}
	}

	awsRegion, err := resolveAwsRegion()
	if err != nil {
		return aws.Credentials{}, "", err
	}

	awsCfg, err := awsconfig.LoadDefaultConfig(context.TODO(), awsconfig.WithRegion(awsRegion))
	if err != nil {
		return aws.Credentials{}, "", fmt.Errorf("unable to load AWS config: %v", err)
	}

	creds, err := awsCfg.Credentials.Retrieve(context.TODO())
	if err != nil {
		return aws.Credentials{}, "", fmt.Errorf("error retrieving credentials: %v", err)
	}

	return creds, awsRegion, nil
}

// resolveAwsRegion returns the AWS region from the environment when running in
// Lambda, otherwise from the EC2 instance identity document.
func resolveAwsRegion() (string, error) {
	if region := os.Getenv("AWS_REGION"); region != "" {
		return region, nil
	}
	return ec2IdentityDocumentRegion(5000 * time.Millisecond)
}

// ec2IdentityDocumentRegion reads the region from the EC2 instance identity
// document using IMDSv2.
func ec2IdentityDocumentRegion(timeout time.Duration) (string, error) {
	httpClient := &http.Client{Timeout: timeout}

	tokenReq, err := http.NewRequest(http.MethodPut, awsEC2MetadataTokenURL, nil)
	if err != nil {
		return "", err
	}
	tokenReq.Header.Set("X-aws-ec2-metadata-token-ttl-seconds", "21600")

	tokenRes, err := httpClient.Do(tokenReq)
	if err != nil {
		return "", err
	}
	defer tokenRes.Body.Close()

	if tokenRes.StatusCode < 200 || tokenRes.StatusCode >= 300 {
		return "", fmt.Errorf("unexpected status %d fetching EC2 metadata token", tokenRes.StatusCode)
	}
	tokenBytes, err := io.ReadAll(tokenRes.Body)
	if err != nil {
		return "", err
	}

	docReq, err := http.NewRequest(http.MethodGet, awsEC2InstanceIdentityDocumentURL, nil)
	if err != nil {
		return "", err
	}
	docReq.Header.Set("X-aws-ec2-metadata-token", string(tokenBytes))
	docReq.Header.Set("Accept", "application/json")

	docRes, err := httpClient.Do(docReq)
	if err != nil {
		return "", err
	}
	defer docRes.Body.Close()

	if docRes.StatusCode < 200 || docRes.StatusCode >= 300 {
		return "", fmt.Errorf("unexpected status %d fetching EC2 identity document", docRes.StatusCode)
	}
	docBytes, err := io.ReadAll(docRes.Body)
	if err != nil {
		return "", err
	}

	var identityDocument struct {
		Region string `json:"region"`
	}
	if err := json.Unmarshal(docBytes, &identityDocument); err != nil {
		return "", err
	}

	return identityDocument.Region, nil
}
