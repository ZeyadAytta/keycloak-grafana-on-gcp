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

