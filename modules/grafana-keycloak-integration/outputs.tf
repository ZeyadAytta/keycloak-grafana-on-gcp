# modules/grafana-keycloak-integration/outputs.tf

output "keycloak_realm_id" {
  description = "The ID of the Keycloak realm used for Grafana"
  value       = module.keycloak_integration.realm_id
}

output "grafana_client_id" {
  description = "The client ID used for Grafana"
  value       = module.keycloak_integration.client_id
}

output "grafana_auth_url" {
  description = "The authentication URL for Grafana"
  value       = module.keycloak_integration.auth_url
}

output "grafana_token_url" {
  description = "The token URL for Grafana"
  value       = module.keycloak_integration.token_url
}

output "grafana_admin_user_id" {
  description = "ID of the created Grafana admin user in Keycloak"
  value       = var.create_default_admin_user ? keycloak_user.grafana_admin[0].id : null
}

output "grafana_viewer_user_id" {
  description = "ID of the created Grafana viewer user in Keycloak"
  value       = var.create_default_viewer_user ? keycloak_user.grafana_viewer[0].id : null
}
