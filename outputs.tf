output "keycloak_url" {
  value = module.keycloak.keycloak_url
  description = "The URL to access Keycloak"
}
# Output the Grafana URL
output "grafana_url" {
  description = "URL to access Grafana"
  value       = module.grafana.grafana_url
}

# Output the Grafana namespace
output "grafana_namespace" {
  description = "Kubernetes namespace where Grafana is deployed"
  value       = module.grafana.grafana_namespace
}

output "radius_service_ip" {
  description = "External IP address for RADIUS service"
  value       = module.keycloak_radius.radius_service_ip
}


output "keycloak_realm_id" {
  value       = module.grafana_keycloak.keycloak_realm_id
  description = "The ID of the Keycloak realm"
}

output "auth_url" {
  value       = module.grafana_keycloak.auth_url
  description = "The authentication URL for Grafana"
}

output "token_url" {
  value       = module.grafana_keycloak.token_url
  description = "The token URL for Grafana"
}

#output "grafana_jwks_url" {
#  value       = module.grafana_keycloak.grafana_jwks_url
#  description = "The JWKS URL for Grafana"
#}

#output "grafana_logout_url" {
#  value       = module.grafana_keycloak.grafana_logout_url
#  description = "The logout URL for Grafana"
#}

output "grafana_viewers_group_id" {
  value       = module.grafana_keycloak.grafana_viewers_group_id
  description = "ID of the Grafana Viewers group"
}

output "grafana_editors_group_id" {
  value       = module.grafana_keycloak.grafana_editors_group_id
  description = "ID of the Grafana Editors group"
}

output "grafana_admins_group_id" {
  value       = module.grafana_keycloak.grafana_admins_group_id
  description = "ID of the Grafana Admins group"
}

output "test_admin_user_id" {
  value       = module.grafana_keycloak.test_admin_user_id
  description = "ID of the test admin user"
}

output "test_editor_user_id" {
  value       = module.grafana_keycloak.test_editor_user_id
  description = "ID of the test editor user"
}

output "test_viewer_user_id" {
  value       = module.grafana_keycloak.test_viewer_user_id
  description = "ID of the test viewer user"
}
