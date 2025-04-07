#GKE variables
variable "project_id" {}
variable "region" {}
variable "cluster_name" {}
variable "machine_type" {}
variable "node_count" {}
variable "min_nodes" {}
variable "max_nodes" {}
variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
}
variable "keycloak_hostname" {
  description = "keycloak fqdn"
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
}

variable "grafana_url" {
  type        = string
  description = "The URL of the Grafana instance"
}

variable "keycloak_admin_user" {
  type        = string
  description = "The admin username for Keycloak"
  default     = "admin"
}

variable "organization" {
  description = "Organization name for certificate subject"
  type        = string
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
variable "disk_size_gb" {
  description = "Size of the disk attached to each node in GB"
  type        = number
}

variable "disk_type" {
  description = "Type of disk attached to each node"
  type        = string
}

variable "image_type" {
  description = "The image type to use for nodes"
  type        = string
}
variable "email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
}
variable "realm_id" {
 description = "keycloak Realm name"
 type = string
}
variable "realm_display_name" {
 description = "keycloak Realm display  name"
 type = string
}
variable "network" {
  description = "The name of the GCP VPC network to use for the GKE cluster"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The name of the GCP VPC subnetwork to use for the GKE cluster"
  type        = string
  default     = "default"
}

variable "network_project_id" {
  description = "The project ID of the shared VPC network (only needed for Shared VPC setup)"
  type        = string
  default     = ""  # Default to empty, will use project_id if not specified
}

variable "ip_range_pods" {
  description = "The secondary IP range name for pods"
  type        = string
  default     = ""  # If empty, GKE will create a range automatically
}

variable "ip_range_services" {
  description = "The secondary IP range name for services"
  type        = string
  default     = ""  # If empty, GKE will create a range automatically
}
