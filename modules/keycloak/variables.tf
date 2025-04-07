variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "gke_project" {
  description = "GCP project ID"
  type        = string
}

variable "gke_region" {
  description = "GKE cluster region"
  type        = string
}

variable "keycloak_hostname" {
  description = "Hostname for Keycloak"
  type        = string
}

variable "radius_shared_secret" {
  description = "Shared secret for RADIUS authentication"
  type        = string
  sensitive   = true
  default     = "secret" # Change this in production
}

variable "radius_auth_port" {
  description = "RADIUS authentication port"
  type        = number
  default     = 1812
}

variable "radius_accounting_port" {
  description = "RADIUS accounting port"
  type        = number
  default     = 1813
}

variable "keycloak_admin_user" {
  description = "Keycloak admin username"
  type        = string
  default     = "admin"
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "create_certificate" {
  description = "Whether to create a certificate resource or use existing"
  type        = bool
  default     = false
}
variable "organization" {
 description = "Keycloak Orginization"
 type = string
}
