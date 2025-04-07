#GKE
project_id    = "cloud52-teleport"
region        = "us-central1-a"
cluster_name  = "keycloak-cls"
machine_type  = "e2-medium"  
node_count    = 1
min_nodes     = 1
max_nodes     = 4
disk_size_gb  = "30"
disk_type     = "pd-standard"  
image_type    = "COS_CONTAINERD"  
organization  = "Cloudfiftytwo" 
network            = "default"
subnetwork         = "default" 
#cert-manager
letsencrypt_email = "study@cloudfiftytwo.com"
email="study@cloudfiftytwo.com"

#keycloak
# Values for sensitive variables
keycloak_admin_password = "Passw0rd123"
keycloak_admin_user = "admin"
keycloak_url = "https://keycloak.cloudfiftytwo.com"
keycloak_hostname= "keycloak.cloudfiftytwo.com"
# If using internal database (use_external_database = false)
postgres_password = "Passw0rd123"

# If using external database (use_external_database = true)
# db_password = "YourExternalDBPassword123!"

#grafana
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
grafana_url= "https://grafana.cloudfiftytwo.com"
#Grafana-Keycloak Module
realm_id = "cloud52"
realm_display_name = "cloud52-Org"
