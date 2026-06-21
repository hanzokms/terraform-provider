package kmsclient

import "errors"

const (
	USER_AGENT                                        = "terraform"
	KMS_MACHINE_IDENTITY_ID_NAME                      = "KMS_MACHINE_IDENTITY_ID"
	KMS_AUTH_ORGANIZATION_SLUG_ENV_NAME               = "KMS_AUTH_ORGANIZATION_SLUG"
	KMS_OIDC_AUTH_TOKEN_NAME                          = "KMS_OIDC_AUTH_TOKEN_NAME"
	KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN_NAME         = "KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN"
	KMS_UNIVERSAL_AUTH_CLIENT_SECRET_NAME             = "KMS_UNIVERSAL_AUTH_CLIENT_SECRET"
	KMS_UNIVERSAL_AUTH_CLIENT_ID_NAME                 = "KMS_UNIVERSAL_AUTH_CLIENT_ID"
	KMS_TOKEN_NAME                                    = "KMS_TOKEN"
	KMS_SERVICE_TOKEN_NAME                            = "KMS_SERVICE_TOKEN"
	KMS_HOST_NAME                                     = "KMS_HOST"
	KMS_AUTH_JWT_NAME                                 = "KMS_AUTH_JWT"
	KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN_PATH_NAME    = "KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN_PATH"
	KMS_KUBERNETES_SERVICE_ACCOUNT_DEFAULT_TOKEN_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/token"
)

const AWS_MAPPING_BEHAVIOR_MANY_TO_ONE = "many-to-one"
const AWS_MAPPING_BEHAVIOR_ONE_TO_ONE = "one-to-one"

var (
	ErrNotFound = errors.New("resource not found")
)
