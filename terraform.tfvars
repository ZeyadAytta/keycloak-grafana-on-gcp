project_id = "example-project-id" #Replace it with your GCP project ID
region = "example-region" #Region for GKE cluster
cluster_name = "example-cluster-name" #Name of the Kubernetes cluster
machine_type = "example-machine-type" #GCE machine type
node_count = 1 #Initial number of nodes
min_nodes = 1 #Minimum number of nodes for autoscaling
max_nodes = 4 #Maximum number of nodes for autoscaling
disk_size_gb = "30" #Size of the disk in GB
disk_type = "example-disk-type" #Type of persistent disk
image_type = "example-image-type" #Container-Optimized OS with containerd
organization = "example-org-name" #Organization name
network = "example-network" #VPC network
subnetwork = "example-subnetwork" #VPC subnetwork

#cert-manager
letsencrypt_email = "example@example.com" #Email for Let's Encrypt
email = "example@example.com" #Contact email

#keycloak
keycloak_admin_password = "example-password" #Admin password for Keycloak
keycloak_admin_user = "example-admin" #Admin username for Keycloak
keycloak_url = "https://example-keycloak.example.com" #URL for Keycloak
keycloak_hostname = "example-keycloak.example.com" #Hostname for Keycloak

# PostgreSQL database configuration
postgres_password = "example-password" #Password for internal PostgreSQL

#grafana
grafana_hostname = "example-grafana.example.com" #Hostname for Grafana
radius_shared_secret = "example-secret" #Shared secret for RADIUS authentication
grafana_admin_user = "example-admin" #Admin username for Grafana
grafana_admin_password = "example-password" #Admin password for Grafana
grafana_oauth_client_secret = "example-oauth-client-secret" #OAuth client secret
default_admin_password = "example-password" #Default admin password
default_viewer_password = "example-password" #Default viewer password
grafana_namespace = "example-namespace" #Kubernetes namespace for Grafana
grafana_helm_repo = "https://example-helm-repo.example.com" #Helm repository URL
grafana_chart_version = "example-version" #Grafana chart version
grafana_url = "https://example-grafana.example.com" #URL for Grafana

#Grafana-Keycloak Module
realm_id = "example-realm" #Keycloak realm ID
realm_display_name = "Example Realm Name" #Display name for Keycloak realm
