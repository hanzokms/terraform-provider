package provider

import (
	"context"
	"os"

	kmsclient "github.com/hanzokms/terraform-provider/internal/client"
	kmsDatasource "github.com/hanzokms/terraform-provider/internal/provider/datasource"
	kmsResource "github.com/hanzokms/terraform-provider/internal/provider/resource"
	appConnectionResource "github.com/hanzokms/terraform-provider/internal/provider/resource/app_connection"
	dynamicSecretResource "github.com/hanzokms/terraform-provider/internal/provider/resource/dynamic_secret"
	externalKmsResource "github.com/hanzokms/terraform-provider/internal/provider/resource/external_kms"
	secretRotationResource "github.com/hanzokms/terraform-provider/internal/provider/resource/secret_rotation"
	secretSyncResource "github.com/hanzokms/terraform-provider/internal/provider/resource/secret_sync"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/ephemeral"
	"github.com/hashicorp/terraform-plugin-framework/provider"
	"github.com/hashicorp/terraform-plugin-framework/provider/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure the implementation satisfies the expected interfaces.
var (
	_ provider.Provider = &kmsProvider{}
)

// New is a helper function to simplify provider server and testing implementation.
func New(version string) func() provider.Provider {
	return func() provider.Provider {
		return &kmsProvider{
			version: version,
		}
	}
}

// kmsProvider is the provider implementation.
type kmsProvider struct {
	// version is set to the provider version on release, "dev" when the
	// provider is built and ran locally, and "test" when running acceptance
	// testing.
	version string
}

// kmsProviderModel maps provider schema data to a Go type.
type kmsProviderModel struct {
	Host         types.String `tfsdk:"host"`
	ServiceToken types.String `tfsdk:"service_token"`

	ClientId     types.String `tfsdk:"client_id"`
	ClientSecret types.String `tfsdk:"client_secret"`

	Auth *authModel `tfsdk:"auth"`
}

type authModel struct {
	OrganizationSlug types.String         `tfsdk:"organization_slug"`
	Oidc             *oidcAuthModel       `tfsdk:"oidc"`
	Token            types.String         `tfsdk:"token"`
	Universal        *universalAuthModel  `tfsdk:"universal"`
	Kubernetes       *kubernetesAuthModel `tfsdk:"kubernetes"`
	AWS              *awsIamAuthModel     `tfsdk:"aws_iam"`
}

type oidcAuthModel struct {
	IdentityId   types.String `tfsdk:"identity_id"`
	TokenEnvName types.String `tfsdk:"token_environment_variable_name"`
}

type universalAuthModel struct {
	ClientId     types.String `tfsdk:"client_id"`
	ClientSecret types.String `tfsdk:"client_secret"`
}

type awsIamAuthModel struct {
	IdentityId types.String `tfsdk:"identity_id"`
}

type kubernetesAuthModel struct {
	IdentityId types.String `tfsdk:"identity_id"`
	TokenPath  types.String `tfsdk:"service_account_token_path"`
	Token      types.String `tfsdk:"service_account_token"`
}

// Metadata returns the provider type name.
func (p *kmsProvider) Metadata(_ context.Context, _ provider.MetadataRequest, resp *provider.MetadataResponse) {
	resp.TypeName = "kms"
	resp.Version = p.version
}

// Schema defines the provider-level schema for configuration data.
func (p *kmsProvider) Schema(ctx context.Context, _ provider.SchemaRequest, resp *provider.SchemaResponse) {
	resp.Schema = schema.Schema{
		Description: "This provider allows you to interact with Kms",
		Attributes: map[string]schema.Attribute{
			"host": schema.StringAttribute{
				Optional:    true,
				Description: "Used to point the client to fetch secrets from your self hosted instance of Kms. If not host is provided, https://kms.hanzo.ai is the default host. This attribute can also be set using the `KMS_HOST` environment variable",
			},
			"service_token": schema.StringAttribute{
				Optional:    true,
				Sensitive:   true,
				Description: " (DEPRECATED, Use machine identity auth), Used to fetch/modify secrets for a given project",
			},
			"client_id": schema.StringAttribute{
				Optional:    true,
				Sensitive:   true,
				Description: "(DEPRECATED, Use the `auth` attribute), Machine identity client ID. Used to fetch/modify secrets for a given project.",
			},
			"client_secret": schema.StringAttribute{
				Optional:    true,
				Sensitive:   true,
				Description: "(DEPRECATED, use `auth` attribute), Machine identity client secret. Used to fetch/modify secrets for a given project",
			},
			"auth": schema.SingleNestedAttribute{
				Optional:    true,
				Description: "The configuration values for authentication",
				Attributes: map[string]schema.Attribute{
					"organization_slug": schema.StringAttribute{
						Optional:    true,
						Description: "When set, this will scope the login session to the specified organization the machine identity has access to. If left empty, the session defaults to the organization where the machine identity was created in.",
					},
					"token": schema.StringAttribute{
						Optional:    true,
						Sensitive:   true,
						Description: "The authentication token for Machine Identity Token Auth. This attribute can also be set using the `KMS_TOKEN` environment variable",
					},
					"universal": schema.SingleNestedAttribute{
						Optional:    true,
						Description: "The configuration values for Universal Auth",
						Attributes: map[string]schema.Attribute{
							"client_id": schema.StringAttribute{
								Optional:    true,
								Sensitive:   true,
								Description: "Machine identity client ID. This attribute can also be set using the `KMS_UNIVERSAL_AUTH_CLIENT_ID` environment variable",
							},
							"client_secret": schema.StringAttribute{
								Optional:    true,
								Sensitive:   true,
								Description: "Machine identity client secret. This attribute can also be set using the `KMS_UNIVERSAL_AUTH_CLIENT_SECRET` environment variable",
							},
						},
					},
					"oidc": schema.SingleNestedAttribute{
						Optional:    true,
						Description: "The configuration values for OIDC Auth",
						Attributes: map[string]schema.Attribute{
							"identity_id": schema.StringAttribute{
								Optional:    true,
								Sensitive:   true,
								Description: "Machine identity ID. This attribute can also be set using the `KMS_MACHINE_IDENTITY_ID` environment variable",
							},
							"token_environment_variable_name": schema.StringAttribute{
								Optional:    true,
								Sensitive:   false,
								Description: "The environment variable name for the OIDC JWT token. This attribute can also be set using the `KMS_OIDC_AUTH_TOKEN_KEY_NAME` environment variable. Default is `KMS_AUTH_JWT`.",
							},
						},
					},
					"kubernetes": schema.SingleNestedAttribute{
						Optional:    true,
						Description: "The configuration values for Kubernetes Auth",
						Attributes: map[string]schema.Attribute{
							"identity_id": schema.StringAttribute{
								Optional:    true,
								Sensitive:   true,
								Description: "Machine identity ID. This attribute can also be set using the `KMS_MACHINE_IDENTITY_ID` environment variable",
							},
							"service_account_token_path": schema.StringAttribute{
								Optional:    true,
								Sensitive:   false,
								Description: "The path to the service account token. This attribute can also be set using the `KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN_PATH` environment variable. Default is `/var/run/secrets/kubernetes.io/serviceaccount/token`.",
							},
							"service_account_token": schema.StringAttribute{
								Optional:    true,
								Sensitive:   true,
								Description: "The service account token. This attribute can also be set using the `KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN` environment variable",
							},
						},
					},
					"aws_iam": schema.SingleNestedAttribute{
						Optional:    true,
						Description: "The configuration values for AWS IAM Auth",
						Attributes: map[string]schema.Attribute{
							"identity_id": schema.StringAttribute{
								Optional:    true,
								Sensitive:   true,
								Description: "Machine identity ID. This attribute can also be set using the `KMS_MACHINE_IDENTITY_ID` environment variable",
							},
						},
					},
				},
			},
		},
	}
}

func (p *kmsProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
	// Retrieve provider data from configuration

	var config kmsProviderModel
	diags := req.Config.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)

	if resp.Diagnostics.HasError() {
		return
	}

	if config.ServiceToken.IsUnknown() {
		resp.Diagnostics.AddError("No authentication credentials provided", "You must define service_token field of the provider")
	}

	host := os.Getenv(kmsclient.KMS_HOST_NAME)

	// Service Token
	serviceToken := os.Getenv(kmsclient.KMS_SERVICE_TOKEN_NAME)

	// Machine Identity
	clientId := os.Getenv(kmsclient.KMS_UNIVERSAL_AUTH_CLIENT_ID_NAME)
	clientSecret := os.Getenv(kmsclient.KMS_UNIVERSAL_AUTH_CLIENT_SECRET_NAME)
	identityId := os.Getenv(kmsclient.KMS_MACHINE_IDENTITY_ID_NAME)
	oidcTokenEnvName := os.Getenv(kmsclient.KMS_OIDC_AUTH_TOKEN_NAME)
	token := os.Getenv(kmsclient.KMS_TOKEN_NAME)
	serviceAccountToken := os.Getenv(kmsclient.KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN_NAME)
	serviceAccountTokenPath := os.Getenv(kmsclient.KMS_KUBERNETES_SERVICE_ACCOUNT_TOKEN_PATH_NAME)
	organizationSlug := os.Getenv(kmsclient.KMS_AUTH_ORGANIZATION_SLUG_ENV_NAME)

	if !config.Host.IsNull() {
		host = config.Host.ValueString()
	}

	if !config.ServiceToken.IsNull() {
		serviceToken = config.ServiceToken.ValueString()
	}

	if !config.ClientId.IsNull() {
		clientId = config.ClientId.ValueString()
	}

	if !config.ClientSecret.IsNull() {
		clientSecret = config.ClientSecret.ValueString()
	}

	// set default to cloud kms if host is empty
	if host == "" {
		host = "https://kms.hanzo.ai"
	}

	if resp.Diagnostics.HasError() {
		return
	}

	var authStrategy kmsclient.AuthStrategyType = ""

	if config.Auth != nil {
		if !config.Auth.OrganizationSlug.IsNull() {
			organizationSlug = config.Auth.OrganizationSlug.ValueString()
		}

		if config.Auth.Oidc != nil {
			authStrategy = kmsclient.AuthStrategy.OIDC_MACHINE_IDENTITY
			if !config.Auth.Oidc.IdentityId.IsNull() {
				identityId = config.Auth.Oidc.IdentityId.ValueString()
			}

			if !config.Auth.Oidc.TokenEnvName.IsNull() {
				oidcTokenEnvName = config.Auth.Oidc.TokenEnvName.ValueString()
			}
		} else if config.Auth.Universal != nil {
			authStrategy = kmsclient.AuthStrategy.UNIVERSAL_MACHINE_IDENTITY
			if !config.Auth.Universal.ClientId.IsNull() {
				clientId = config.Auth.Universal.ClientId.ValueString()
			}
			if !config.Auth.Universal.ClientSecret.IsNull() {
				clientSecret = config.Auth.Universal.ClientSecret.ValueString()
			}
		} else if config.Auth.Kubernetes != nil {
			authStrategy = kmsclient.AuthStrategy.KUBERNETES_MACHINE_IDENTITY
			if !config.Auth.Kubernetes.IdentityId.IsNull() {
				identityId = config.Auth.Kubernetes.IdentityId.ValueString()
			}

			if !config.Auth.Kubernetes.TokenPath.IsNull() {
				serviceAccountTokenPath = config.Auth.Kubernetes.TokenPath.ValueString()
			}

			if !config.Auth.Kubernetes.Token.IsNull() {
				serviceAccountToken = config.Auth.Kubernetes.Token.ValueString()
			}
		} else if config.Auth.AWS != nil {
			authStrategy = kmsclient.AuthStrategy.AWS_IAM_MACHINE_IDENTITY
			if !config.Auth.AWS.IdentityId.IsNull() {
				identityId = config.Auth.AWS.IdentityId.ValueString()
			}
		} else if config.Auth.Token.ValueString() != "" {
			authStrategy = kmsclient.AuthStrategy.TOKEN_MACHINE_IDENTITY
			token = config.Auth.Token.ValueString()
		}
	}

	// strict env vars check:
	if authStrategy == "" {
		// ? note(daniel): this fix only works for token auth.
		// ? we currently don't have a way to identify if a user wants to use the different identity-id based auth strategies.
		// ? We should have a field for specifying the target auth strategy, like we do for the CLI (--method=aws-auth as an example)
		if envVarToken := os.Getenv(kmsclient.KMS_TOKEN_NAME); envVarToken != "" {
			authStrategy = kmsclient.AuthStrategy.TOKEN_MACHINE_IDENTITY
			token = envVarToken
		}

	}

	client, err := kmsclient.NewClient(kmsclient.Config{
		HostURL:                 host,
		AuthStrategy:            authStrategy,
		ServiceToken:            serviceToken,
		ClientId:                clientId,
		ClientSecret:            clientSecret,
		IdentityId:              identityId,
		OidcTokenEnvName:        oidcTokenEnvName,
		Token:                   token,
		ServiceAccountToken:     serviceAccountToken,
		ServiceAccountTokenPath: serviceAccountTokenPath,
		OrganizationSlug:        organizationSlug,
	})

	if err != nil {
		resp.Diagnostics.AddError(
			"Unable to Create Kms API Client",
			"An unexpected error occurred when creating the Kms API client. "+
				"If the error is not clear, please get in touch at hanzo.ai/slack.\n\n"+
				"Kms Client Error: "+err.Error(),
		)
		return
	}

	// type Configure methods.
	resp.DataSourceData = client
	resp.ResourceData = client
	resp.EphemeralResourceData = client

}

// DataSources defines the data sources implemented in the provider.
func (p *kmsProvider) DataSources(_ context.Context) []func() datasource.DataSource {
	return []func() datasource.DataSource{
		kmsDatasource.NewSecretDataSource,
		kmsDatasource.NewProjectDataSource,
		kmsDatasource.NewSecretTagDataSource,
		kmsDatasource.NewSecretFolderDataSource,
		kmsDatasource.NewGroupsDataSource,
		kmsDatasource.NewIdentityDetailsDataSource,
		kmsDatasource.NewKMSKeyDataSource,
	}
}

// Resources defines the resources implemented in the provider.
func (p *kmsProvider) Resources(_ context.Context) []func() resource.Resource {
	return []func() resource.Resource{
		kmsResource.NewSecretResource,
		kmsResource.NewProjectResource,
		kmsResource.NewProjectUserResource,
		kmsResource.NewProjectIdentityResource,
		kmsResource.NewProjectRoleResource,
		kmsResource.NewOrgRoleResource,
		kmsResource.NewProjectIdentitySpecificPrivilegeResource,
		kmsResource.NewProjectGroupResource,
		kmsResource.NewProjectSecretTagResource,
		kmsResource.NewProjectSecretFolderResource,
		kmsResource.NewProjectEnvironmentResource,
		kmsResource.NewIdentityResource,
		kmsResource.NewIdentityUniversalAuthResource,
		kmsResource.NewIdentityUniversalAuthClientSecretResource,
		kmsResource.NewIdentityAwsAuthResource,
		kmsResource.NewIdentityKubernetesAuthResource,
		kmsResource.NewIdentityGcpAuthResource,
		kmsResource.NewIdentityAzureAuthResource,
		kmsResource.NewIdentityOidcAuthResource,
		kmsResource.NewIdentityTokenAuthResource,
		kmsResource.NewIdentityTokenAuthTokenResource,
		kmsResource.NewIntegrationGcpSecretManagerResource,
		kmsResource.NewIntegrationAwsParameterStoreResource,
		kmsResource.NewIntegrationAwsSecretsManagerResource,
		kmsResource.NewIntegrationCircleCiResource,
		kmsResource.NewIntegrationDatabricksResource,
		kmsResource.NewSecretApprovalPolicyResource,
		kmsResource.NewAccessApprovalPolicyResource,
		kmsResource.NewProjectSecretImportResource,
		kmsResource.NewGroupResource,
		appConnectionResource.NewAppConnectionGcpResource,
		appConnectionResource.NewAppConnectionAwsResource,
		appConnectionResource.NewAppConnectionAzureResource,
		appConnectionResource.NewAppConnectionAzureKeyVaultResource,
		appConnectionResource.NewAppConnection1PasswordResource,
		appConnectionResource.NewAppConnectionAzureAppConfigurationResource,
		appConnectionResource.NewAppConnectionRenderResource,
		appConnectionResource.NewAppConnectionAzureDevOpsResource,
		appConnectionResource.NewAppConnectionMySqlResource,
		appConnectionResource.NewAppConnectionMsSqlResource,
		appConnectionResource.NewAppConnectionPostgresResource,
		appConnectionResource.NewAppConnectionOracleDbResource,
		appConnectionResource.NewAppConnectionBitbucketResource,
		appConnectionResource.NewAppConnectionDatabricksResource,
		appConnectionResource.NewAppConnectionCloudflareResource,
		appConnectionResource.NewAppConnectionSupabaseResource,
		appConnectionResource.NewAppConnectionFlyioResource,
		appConnectionResource.NewAppConnectionLdapResource,
		appConnectionResource.NewAppConnectionGitlabResource,
		secretSyncResource.NewSecretSyncGcpSecretManagerResource,
		secretSyncResource.NewSecretSyncAzureAppConfigurationResource,
		secretSyncResource.NewSecretSyncAzureKeyVaultResource,
		secretSyncResource.NewSecretSyncAwsParameterStoreResource,
		secretSyncResource.NewSecretSyncAwsSecretsManagerResource,
		secretSyncResource.NewSecretSyncGithubResource,
		secretSyncResource.NewSecretSync1PasswordResource,
		secretSyncResource.NewSecretSyncAzureDevOpsResource,
		secretSyncResource.NewSecretSyncRenderResource,
		secretSyncResource.NewSecretSyncBitbucketResource,
		secretSyncResource.NewSecretSyncDatabricksResource,
		secretSyncResource.NewSecretSyncCloudflareWorkersResource,
		secretSyncResource.NewSecretSyncCloudflarePagesResource,
		secretSyncResource.NewSecretSyncSupabaseResource,
		secretSyncResource.NewSecretSyncFlyioResource,
		secretSyncResource.NewSecretSyncGitlabResource,
		dynamicSecretResource.NewDynamicSecretSqlDatabaseResource,
		dynamicSecretResource.NewDynamicSecretAwsIamResource,
		dynamicSecretResource.NewDynamicSecretKubernetesResource,
		dynamicSecretResource.NewDynamicSecretMongoAtlasResource,
		dynamicSecretResource.NewDynamicSecretMongoDbResource,
		secretRotationResource.NewSecretRotationMySqlCredentialsResource,
		secretRotationResource.NewSecretRotationMsSqlCredentialsResource,
		secretRotationResource.NewSecretRotationPostgresCredentialsResource,
		secretRotationResource.NewSecretRotationOracleDbCredentialsResource,
		secretRotationResource.NewSecretRotationAzureClientSecretResource,
		secretRotationResource.NewSecretRotationAwsIamUserSecretResource,
		secretRotationResource.NewSecretRotationLdapPasswordResource,
		kmsResource.NewProjectTemplateResource,
		kmsResource.NewKMSKeyResource,
		kmsResource.NewCertManagerInternalCAResource,
		kmsResource.NewCertManagerExternalCAACMEResource,
		kmsResource.NewCertManagerExternalCAADCSResource,
		kmsResource.NewCertManagerCertificatePolicyResource,
		kmsResource.NewCertManagerCertificateProfileResource,
		kmsResource.NewCertManagerCertificateResource,
		kmsResource.NewCertManagerCACertificateResource,
		externalKmsResource.NewExternalKmsAwsResource,
	}
}

// EphemeralResources defines the ephemeral resources implemented in the provider.
func (p *kmsProvider) EphemeralResources(_ context.Context) []func() ephemeral.EphemeralResource {
	return []func() ephemeral.EphemeralResource{
		func() ephemeral.EphemeralResource {
			return kmsResource.NewEphemeralSecretResource()
		},
	}
}
