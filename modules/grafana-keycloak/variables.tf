# modules/grafana-keycloak/variables.tf

# Domain values
variable "grafana_url" {
  type        = string
  description = "The URL of the Grafana instance"
}

variable "keycloak_url" {
  type        = string
  description = "The URL of the Keycloak instance"
}

variable "keycloak_auth_url" {
  type        = string
  description = "Alternative hostname for Keycloak auth endpoints (e.g., keycloak.example.com) - leave empty to use the same as admin URL"
  default     = ""
}

# Realm configuration
variable "realm_id" {
  type        = string
  description = "The ID of the Keycloak realm to use for Grafana integration"
}

variable "realm_display_name" {
  type        = string
  description = "Display name for the realm"
  default     = ""
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

# Grafana PVC name
variable "grafana_pvc_name" {
  type        = string
  description = "Name of the PVC to use for Grafana data"
  default     = "grafana-data"
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

# Grafana admin password
variable "grafana_admin_password" {
  type        = string
  description = "Admin password for Grafana"
  sensitive   = true
}

# Test users
variable "create_test_users" {
  type        = bool
  description = "Whether to create test users in Keycloak"
  default     = true
}

variable "test_users_password" {
  type        = string
  description = "Password for test users in Keycloak"
  sensitive   = true
  default     = "Test123!"
}

# Grafana version and resources
variable "grafana_version" {
  type        = string
  description = "Grafana image version"
  default     = "10.2.3"
}

variable "resource_limits_cpu" {
  type        = string
  description = "CPU resource limits for Grafana"
  default     = "200m"
}

variable "resource_limits_memory" {
  type        = string
  description = "Memory resource limits for Grafana"
  default     = "256Mi"
}

variable "resource_requests_cpu" {
  type        = string
  description = "CPU resource requests for Grafana"
  default     = "100m"
}

variable "resource_requests_memory" {
  type        = string
  description = "Memory resource requests for Grafana"
  default     = "128Mi"
}
