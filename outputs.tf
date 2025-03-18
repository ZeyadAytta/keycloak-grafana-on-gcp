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
  value = module.grafana_keycloak_integration.keycloak_realm_id
  description = "The ID of the Keycloak realm"
}

output "grafana_auth_url" {
  value = module.grafana_keycloak_integration.grafana_auth_url
  description = "The authentication URL for Grafana"
}

output "grafana_token_url" {
  value = module.grafana_keycloak_integration.grafana_token_url
  description = "The token URL for Grafana"
}
