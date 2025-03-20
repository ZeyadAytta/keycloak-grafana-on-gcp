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

provider "keycloak" {
  url      = "https://keycloak-rad.cloudfiftytwo.com"
  client_id = "admin-cli"
  username  = var.keycloak_admin_user
  password  = var.keycloak_admin_password
  tls_insecure_skip_verify = true
}
provider "grafana" {
  url  = "https://${var.grafana_url}"
  auth = "${var.grafana_admin_user}:${var.grafana_admin_password}"
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
module "keycloak_radius" {
  source = "./modules/keycloak-radius"

  # GKE settings
  gke_cluster_name = var.cluster_name
  gke_project      = var.project_id  # Adjust variable name if needed
  gke_region       = var.region

  # Keycloak settings
  keycloak_hostname    = "keycloak-rad.cloudfiftytwo.com"
  keycloak_admin_user  = "admin"
  keycloak_admin_password = var.keycloak_admin_password

  # RADIUS settings
  radius_shared_secret = var.radius_shared_secret
  radius_auth_port     = 1812
  radius_accounting_port = 1813

  # Certificate management
  create_certificate = false  # Set to false since certificate already exists
}
module "grafana_keycloak" {
  source = "./modules/grafana-keycloak"

  # Domain values
  grafana_url      = "grafana.cloudfiftytwo.com"
  keycloak_url     = "keycloak-rad.cloudfiftytwo.com"
  keycloak_auth_url = "keycloak-rad.cloudfiftytwo.com"  # Different URL for auth endpoints

  # Realm configuration
  realm_id          = "cloudfiftytwo"
  realm_display_name = "Cloud52 Organization"

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
