# modules/grafana-keycloak-integration/variables.tf

# Domain values
variable "grafana_url" {
  type        = string
  description = "The URL of the Grafana instance"
}

variable "keycloak_url" {
  type        = string
  description = "The URL of the Keycloak instance"
}

# Realm configuration
variable "create_realm" {
  type        = bool
  description = "Whether to create a new realm or use an existing one"
  default     = false
}

variable "realm_id" {
  type        = string
  description = "The ID of the Keycloak realm to use for Grafana integration"
}

variable "realm_display_name" {
  type        = string
  description = "Display name for the realm"
  default     = ""
}

variable "login_theme" {
  type        = string
  description = "The login theme to use for this realm"
  default     = "keycloak"
}

# Admin credentials
variable "grafana_admin_user" {
  type        = string
  description = "The admin username for Grafana"
  default     = "admin"
}

variable "grafana_admin_password" {
  type        = string
  description = "The admin password for Grafana"
  sensitive   = true
}

variable "keycloak_admin_user" {
  type        = string
  description = "The admin username for Keycloak"
  default     = "admin"
}

variable "keycloak_admin_password" {
  type        = string
  description = "The admin password for Keycloak"
  sensitive   = true
}

# OAuth client configuration
variable "grafana_oauth_client_id" {
  type        = string
  description = "The client ID for Grafana in Keycloak"
  default     = "grafana"
}

variable "grafana_oauth_client_secret" {
  type        = string
  description = "The client secret for Grafana in Keycloak"
  sensitive   = true
}

# Grafana namespace
variable "grafana_namespace" {
  type        = string
  description = "Kubernetes namespace where Grafana is deployed"
  default     = "grafana"
}

# Authentication configuration
variable "oauth_auto_login" {
  type        = bool
  description = "Whether to automatically redirect to OAuth login"
  default     = false
}

variable "disable_login_form" {
  type        = bool
  description = "Whether to disable the Grafana login form"
  default     = false
}

variable "disable_initial_admin_creation" {
  type        = bool
  description = "Whether to disable initial admin creation in Grafana"
  default     = false
}

variable "default_user_role" {
  type        = string
  description = "Default role to assign to users in Grafana"
  default     = "Viewer"
}

# Default users configuration
variable "create_default_admin_user" {
  type        = bool
  description = "Whether to create a default admin user in Keycloak"
  default     = true
}

variable "create_default_viewer_user" {
  type        = bool
  description = "Whether to create a default viewer user in Keycloak"
  default     = true
}

variable "default_admin_password" {
  type        = string
  description = "Default password for the admin user in Keycloak"
  sensitive   = true
  default     = "Admin123!"
}

variable "default_viewer_password" {
  type        = string
  description = "Default password for the viewer user in Keycloak"
  sensitive   = true
  default     = "Viewer123!"
}

variable "admin_user_email" {
  type        = string
  description = "Email for the admin user in Keycloak"
  default     = "grafana-admin@example.com"
}

variable "viewer_user_email" {
  type        = string
  description = "Email for the viewer user in Keycloak"
  default     = "grafana-viewer@example.com"
}
