variable "project_id" {}
variable "region" {}
variable "cluster_name" {}
variable "machine_type" {}
variable "node_count" {}
variable "min_nodes" {}
variable "max_nodes" {}
variable "disk_size_gb" {}
variable "disk_type" {}
variable "image_type" {}
variable "network" {
  description = "The name of the GCP VPC network to use for the GKE cluster"
  type        = string
}

variable "subnetwork" {
  description = "The name of the GCP VPC subnetwork to use for the GKE cluster"
  type        = string
}

variable "network_project_id" {
  description = "The project ID of the shared VPC network (for Shared VPC setup)"
  type        = string
}

variable "ip_range_pods" {
  description = "The secondary IP range name for pods"
  type        = string
}

variable "ip_range_services" {
  description = "The secondary IP range name for services"
  type        = string
}
