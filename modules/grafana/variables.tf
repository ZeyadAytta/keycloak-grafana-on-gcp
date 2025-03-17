# modules/grafana/variables.tf
variable "grafana_hostname" {
  description = "Hostname for Grafana"
  type        = string
  default     = "grafana.cloudfiftytwo.com"
}

variable "admin_password" {
  description = "Initial admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_version" {
  description = "Grafana image version"
  type        = string
  default     = "10.2.3"
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas"
  type        = number
  default     = 1
}

variable "resource_limits_cpu" {
  description = "CPU resource limits for Grafana"
  type        = string
  default     = "200m"
}

variable "resource_limits_memory" {
  description = "Memory resource limits for Grafana"
  type        = string
  default     = "256Mi"
}

variable "resource_requests_cpu" {
  description = "CPU resource requests for Grafana"
  type        = string
  default     = "100m"
}

variable "resource_requests_memory" {
  description = "Memory resource requests for Grafana"
  type        = string
  default     = "128Mi"
}
