provider "google" {
  project = var.project_id
    credentials = file("./keycloak-sa.json")
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
  url      = var.keycloak_url
  client_id = "admin-cli"
  username  = var.keycloak_admin_user
  password  = var.keycloak_admin_password
  tls_insecure_skip_verify = true
}
provider "grafana" {
  url  = "https://${var.grafana_url}"
  auth = "${var.grafana_admin_user}:${var.grafana_admin_password}"
}

