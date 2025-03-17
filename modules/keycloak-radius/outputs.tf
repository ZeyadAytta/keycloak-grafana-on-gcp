output "keycloak_url" {
  description = "URL for accessing Keycloak"
  value       = "https://${var.keycloak_hostname}"
}

output "radius_service_ip" {
  description = "External IP address for RADIUS service"
  value       = kubernetes_service.keycloak_radius.status.0.load_balancer.0.ingress.0.ip
}

output "radius_auth_port" {
  description = "RADIUS authentication port"
  value       = var.radius_auth_port
}

output "radius_accounting_port" {
  description = "RADIUS accounting port"
  value       = var.radius_accounting_port
}

