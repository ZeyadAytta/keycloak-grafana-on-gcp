
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

# If using internal database (use_external_database = false)
postgres_password = "Passw0rd123"

# If using external database (use_external_database = true)
# db_password = "YourExternalDBPassword123!"
keycloak_hostname = keycloak.cloudfiftytwo.com
grafana_hostname      = "grafana.cloudfiftytwo.com"
grafana_admin_password = "Passw0rd123"  # Replace with a secure password

radius_shared_secret = "Passw0rd123"
