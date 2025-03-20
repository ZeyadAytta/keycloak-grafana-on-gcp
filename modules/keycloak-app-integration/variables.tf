# modules/keycloak-app-integration/variables.tf

# Keycloak configuration
variable "keycloak_base_url" {
  description = "The base URL of the Keycloak instance (e.g., https://keycloak.example.com)"
  type        = string
}

variable "keycloak_auth_url" {
  description = "Alternative hostname for Keycloak auth endpoints (e.g., keycloak.example.com) - leave empty to use the same as admin URL"
  type        = string
  default     = ""
}

# Realm configuration
variable "create_realm" {
  description = "Whether to create a new realm or use an existing one"
  type        = bool
  default     = false
}

variable "realm_id" {
  description = "The ID of the Keycloak realm to use"
  type        = string
}

variable "realm_display_name" {
  description = "Display name for the realm"
  type        = string
  default     = ""
}

variable "login_theme" {
  description = "The login theme to use for this realm"
  type        = string
  default     = "keycloak"
}

variable "access_token_lifespan" {
  description = "The access token lifespan in seconds"
  type        = number
  default     = 300  # 5 minutes
}

# Client configuration
variable "client_id" {
  description = "The client ID for the application"
  type        = string
}

variable "client_name" {
  description = "The display name for the client"
  type        = string
}

variable "client_secret" {
  description = "The client secret for the application"
  type        = string
  sensitive   = true
}

variable "app_root_url" {
  description = "The root URL of the application"
  type        = string
}

variable "valid_redirect_uris" {
  description = "List of valid redirect URIs for the client"
  type        = list(string)
}

variable "web_origins" {
  description = "List of allowed web origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "service_accounts_enabled" {
  description = "Enable service accounts for the client"
  type        = bool
  default     = false
}

variable "authorization_policy_enforcement_mode" {
  description = "The authorization policy enforcement mode"
  type        = string
  default     = "ENFORCING"
}

# Scopes configuration
variable "default_scopes" {
  description = "List of default scopes for the client"
  type        = list(string)
  default     = ["profile", "email", "roles", "web-origins"]
}

variable "optional_scopes" {
  description = "List of optional scopes for the client"
  type        = list(string)
  default     = ["address", "phone", "offline_access"]
}

# Protocol mappers configuration
variable "username_claim_name" {
  description = "Claim name for username in tokens"
  type        = string
  default     = "preferred_username"
}

variable "email_claim_name" {
  description = "Claim name for email in tokens"
  type        = string
  default     = "email"
}

variable "map_groups" {
  description = "Whether to map groups to tokens"
  type        = bool
  default     = true
}

variable "groups_claim_name" {
  description = "Claim name for groups in tokens"
  type        = string
  default     = "groups"
}

variable "groups_full_path" {
  description = "Whether to use full path for groups"
  type        = bool
  default     = true
}

variable "map_realm_roles" {
  description = "Whether to map realm roles to tokens"
  type        = bool
  default     = true
}

variable "realm_roles_claim_name" {
  description = "Claim name for realm roles in tokens"
  type        = string
  default     = "realm_roles"
}

variable "map_client_roles" {
  description = "Whether to map client roles to tokens"
  type        = bool
  default     = true
}

variable "client_roles_claim_name" {
  description = "Claim name for client roles in tokens"
  type        = string
  default     = "resource_access.client.roles"
}

variable "add_audience_mapper" {
  description = "Whether to add audience mapper"
  type        = bool
  default     = true
}
