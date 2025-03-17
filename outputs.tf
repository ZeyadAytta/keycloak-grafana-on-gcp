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
