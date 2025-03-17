# modules/keycloak/outputs.tf
output "keycloak_namespace" {
  description = "The namespace where Keycloak is deployed"
  value       = kubernetes_namespace.keycloak.metadata[0].name
}

output "keycloak_url" {
  description = "The URL to access Keycloak"
  value       = "https://${var.keycloak_hostname}"
}

output "keycloak_service_name" {
  description = "The name of the Keycloak service"
  value       = kubernetes_service.keycloak.metadata[0].name
}

output "keycloak_ingress_name" {
  description = "The name of the Keycloak ingress"
  value       = kubernetes_ingress_v1.keycloak_ingress.metadata[0].name
}

output "postgres_service_name" {
  description = "The name of the PostgreSQL service if deployed"
  value       = var.use_external_database ? null : "keycloak-postgres"
}
