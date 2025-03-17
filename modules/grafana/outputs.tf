# modules/grafana/outputs.tf
output "grafana_namespace" {
  description = "The namespace where Grafana is deployed"
  value       = kubernetes_namespace.grafana.metadata[0].name
}

output "grafana_url" {
  description = "The URL to access Grafana"
  value       = "https://${var.grafana_hostname}"
}

output "grafana_service_name" {
  description = "The name of the Grafana service"
  value       = kubernetes_service.grafana.metadata[0].name
}

output "grafana_ingress_name" {
  description = "The name of the Grafana ingress"
  value       = kubernetes_ingress_v1.grafana_ingress.metadata[0].name
}
