# modules/keycloak/variables.tf
variable "keycloak_hostname" {
  description = "Hostname for Keycloak"
  type        = string
}

variable "use_external_database" {
  description = "Whether to use an external database instead of deploying PostgreSQL"
  type        = bool
  default     = false
}

variable "postgres_password" {
  description = "Password for the PostgreSQL database (if deploying PostgreSQL)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_password" {
  description = "Initial admin password for Keycloak"
  type        = string
  sensitive   = true
}

# External database variables (used only if use_external_database = true)
variable "db_host" {
  description = "External database hostname"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "External database port"
  type        = number
  default     = 5432
}

variable "db_user" {
  description = "External database username"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "External database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_name" {
  description = "External database name"
  type        = string
  default     = "keycloak"
}

variable "keycloak_replicas" {
  description = "Number of Keycloak replicas"
  type        = number
  default     = 1
}

variable "resource_limits_cpu" {
  description = "CPU resource limits for Keycloak"
  type        = string
  default     = "1000m"
}

variable "resource_limits_memory" {
  description = "Memory resource limits for Keycloak"
  type        = string
  default     = "1Gi"
}

variable "resource_requests_cpu" {
  description = "CPU resource requests for Keycloak"
  type        = string
  default     = "500m"
}

variable "resource_requests_memory" {
  description = "Memory resource requests for Keycloak"
  type        = string
  default     = "512Mi"
}
