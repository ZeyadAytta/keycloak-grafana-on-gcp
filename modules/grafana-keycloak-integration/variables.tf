variable "grafana_url" {
  type        = string
  description = "The URL of the Grafana instance"
  default     = "grafana.cloudfiftytwo.com"
}

variable "keycloak_url" {
  type        = string
  description = "The URL of the Keycloak instance"
  default     = "keycloak-rad.cloudfiftytwo.com"
}

variable "keycloak_realm" {
  type        = string
  description = "The Keycloak realm to use for authentication"
  default     = "cloudfiftytwo"
}

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

variable "grafana_namespace" {
  type        = string
  description = "Kubernetes namespace where Grafana is deployed"
  default     = "grafana"
}
