variable "project_id" {}
variable "region" {}
variable "cluster_name" {}
variable "machine_type" {}
variable "node_count" {
  default = 1
}
variable "min_nodes" {
  default = 1
}
variable "max_nodes" {
  default = 3
}
variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
}

variable "rancher_bootstrap_password" {
  description = "Bootstrap password for Rancher admin user"
  type        = string
  default     = "A$123456789"
  sensitive   = true
}

variable "rancher_hostname" {
  description = "Hostname for Rancher access"
  type        = string
}
variable "keycloak_admin_password" {
  description = "Admin password for Keycloak"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password for Keycloak"
  type        = string
  sensitive   = true
  default     = "" # Only required if use_external_database = true
}

variable "postgres_password" {
  description = "Password for the PostgreSQL database (if deploying internal PostgreSQL)"
  type        = string
  sensitive   = true
  default     = "" # Only required if use_external_database = false
}
variable "grafana_admin_password" {
  description = "Initial admin password for Grafana"
  type        = string
  sensitive   = true
}
variable "radius_shared_secret" {
  description = "Shared secret for RADIUS authentication"
  type        = string
  sensitive   = true
}
variable "keycloak_url" {
  type        = string
  description = "The URL of the Keycloak instance"
  default     = "keycloak.cloudfiftytwo.com"
}

variable "grafana_url" {
  type        = string
  description = "The URL of the Grafana instance"
  default     = "grafana.cloudfiftytwo.com"
}

variable "keycloak_admin_user" {
  type        = string
  description = "The admin username for Keycloak"
  default     = "admin"
}

variable "grafana_admin_user" {
  type        = string
  description = "The admin username for Grafana"
  default     = "admin"
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

variable "grafana_hostname" {
  type        = string
  description = "The hostname for Grafana (legacy variable)"
  default     = "grafana.cloudfiftytwo.com"
}
variable "grafana_helm_repo" {
  type        = string
  description = "Helm repository for Grafana"
  default     = "https://grafana.github.io/helm-charts"
}

variable "grafana_chart_version" {
  type        = string
  description = "Version of the Grafana Helm chart to use"
  default     = ""  # Leave empty to use the latest version
}
