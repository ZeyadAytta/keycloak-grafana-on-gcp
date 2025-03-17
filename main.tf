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
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

module "gke" {
  source = "./modules/gke"

  project_id    = var.project_id
  region        = var.region
  cluster_name  = var.cluster_name
  machine_type  = "e2-medium"
  node_count    = 1
  min_nodes     = 1
  max_nodes     = 4
}


module "nginx_ingress" {
  source = "./modules/nginx-ingress"
  depends_on = [module.gke]
}
module "cert_manager" {
  source = "./modules/cert-manager"
  email  = "study@cloudfiftytwo.com"
  depends_on = [module.nginx_ingress]
}
module "teleport" {
  source = "./modules/teleport"
  depends_on = [module.nginx_ingress, module.cert_manager]

  auth_service_domain  = "auth.cloudfiftytwo.com"
  proxy_service_domain = "proxy.cloudfiftytwo.com"
}

module "argocd" {
  source = "./modules/argocd"
  depends_on = [module.nginx_ingress, module.cert_manager]

  argocd_hostname = "argocd.cloudfiftytwo.com"
}
module "rancher" {
  source            = "./modules/rancher"
  rancher_hostname  = "rancher.cloudfiftytwo.com"
  email = "study@cloudfiftytwo.com"
  depends_on        = [module.cert_manager]
}
module "keycloak" {
  source             = "./modules/keycloak"
  
  # Required parameters
  keycloak_hostname  = "keycloak.cloudfiftytwo.com"
  admin_password     = var.keycloak_admin_password
  
  # Database configuration
  use_external_database = false  # Set to true if you want to use external DB
  postgres_password     = var.postgres_password  # Only used if use_external_database = false
  
  # If use_external_database = true, uncomment and set these values
  # db_host              = "your-postgres-server.example.com"
  # db_user              = "keycloak_user"
  # db_password          = var.db_password
  
  # Optional: customize resource allocation
  keycloak_replicas      = 2
  resource_limits_cpu    = "1000m"
  resource_limits_memory = "1Gi"
}
module "grafana" {
  source = "./modules/grafana"

  # Use direct values instead of variables that aren't declared
  grafana_hostname = "grafana.cloudfiftytwo.com"

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
