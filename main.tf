# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.0"
    }
  }
}

module "gke" {
  source = "./modules/gke"

  project_id    = var.project_id
  region        = var.region
  cluster_name  = var.cluster_name
  machine_type  = var.machine_type
  node_count    = var.node_count
  min_nodes     = var.min_nodes
  max_nodes     = var.max_nodes
  disk_size_gb   = var.disk_size_gb
  disk_type      = var.disk_type
  image_type     = var.image_type

 # Network configuration
  network           = var.network
  subnetwork        = var.subnetwork
  network_project_id = var.network_project_id != "" ? var.network_project_id : var.project_id
  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services
}


module "nginx_ingress" {
  source = "./modules/nginx-ingress"
  depends_on = [module.gke]
}
module "cert_manager" {
  source = "./modules/cert-manager"
  email  = var.email
  depends_on = [module.nginx_ingress]
}
module "grafana" {
  source = "./modules/grafana"

  # Use direct values instead of variables that aren't declared
  grafana_hostname = var.grafana_hostname

  # Get the admin password from a variable that should be declared in your variables.tf
  admin_password   = var.grafana_admin_password

  # Optional parameters with default values - you can remove these if you want to use defaults
  # grafana_version        = "10.2.3"
  # grafana_replicas       = 1
  # resource_limits_cpu    = "200m"
  # resource_limits_memory = "256Mi"
  # resource_requests_cpu  = "100m"
  # resource_requests_memory = "128Mi"
}
module "keycloak" {
  source = "./modules/keycloak"

  # GKE settings
  gke_cluster_name = var.cluster_name
  gke_project      = var.project_id  
  gke_region       = var.region

  # Keycloak settings
  keycloak_hostname    = var.keycloak_hostname
  keycloak_admin_user  = "admin"
  keycloak_admin_password = var.keycloak_admin_password

  # RADIUS settings
  radius_shared_secret = var.radius_shared_secret
  radius_auth_port     = 1812
  radius_accounting_port = 1813

  # Certificate management
  create_certificate = false  # Set to false since certificate already exists
  organization = var.organization
}
module "grafana_keycloak" {
  source = "./modules/grafana-keycloak"

  # Domain values
  grafana_url      = var.grafana_hostname
  keycloak_url     = var.keycloak_hostname
  keycloak_auth_url = var.keycloak_hostname
# Realm configuration
  realm_id          = var.realm_id
  realm_display_name = var.realm_display_name

  # Grafana configuration
  grafana_namespace = "grafana"
  grafana_pvc_name = "grafana-data"  # Use the same PVC name that was used by your original Grafana deployment
  grafana_admin_password = "Passw0rd123"  # Use the same admin password

  # OAuth client configuration
  grafana_oauth_client_id     = "grafana"
  grafana_oauth_client_secret = "12wedfvghyu890olmjhgtr43erfghjki8765"

  # Test users
  create_test_users    = true
  test_users_password  = "Passw0rd123"
}
