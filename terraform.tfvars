
project_id    = "cloud52-teleport"
region        = "us-central1"
cluster_name  = "keycloak-cls"
machine_type  = "e2-medium"  # Free tier compatible machine type
node_count    = 1
min_nodes     = 1
max_nodes     = 4
letsencrypt_email         = "study@cloudfiftytwo.com"
rancher_bootstrap_password = "A$123456789"
rancher_hostname          = "rancher.cloudfiftytwo.com"
# Values for sensitive variables
keycloak_admin_password = "Passw0rd123"
keycloak_admin_user = "admin"
keycloak_url = "keycloak-rad.cloudfiftytwo.com"
# If using internal database (use_external_database = false)
postgres_password = "Passw0rd123"

# If using external database (use_external_database = true)
# db_password = "YourExternalDBPassword123!"
keycloak_hostname = "keycloak-rad.cloudfiftytwo.com"
grafana_hostname      = "grafana.cloudfiftytwo.com"

radius_shared_secret = "Passw0rd123"


grafana_admin_user = "admin" 
grafana_admin_password = "Passw0rd123"
grafana_oauth_client_secret = "12wedfvghyu890olmjhgtr43erfghjki8765"
default_admin_password = "Passw0rd123"
default_viewer_password = "Passw0rd123"
grafana_namespace = "grafana" 
grafana_helm_repo = "https://grafana.github.io/helm-charts"
grafana_chart_version = ""
