# modules/grafana-keycloak/outputs.tf

output "keycloak_realm_id" {
  description = "The ID of the Keycloak realm used for Grafana"
  value       = keycloak_realm.app_realm.id
}

output "keycloak_client_id" {
  description = "The client ID used for Grafana in Keycloak"
  value       = keycloak_openid_client.grafana_client.client_id
}

output "keycloak_client_uuid" {
  description = "The client UUID (internal Keycloak ID) used for Grafana"
  value       = keycloak_openid_client.grafana_client.id
}

output "auth_url" {
  description = "The authentication URL for Grafana"
  value       = "https://${var.keycloak_auth_url != "" ? var.keycloak_auth_url : var.keycloak_url}/realms/${var.realm_id}/protocol/openid-connect/auth"
}

output "token_url" {
  description = "The token URL for Grafana"
  value       = "https://${var.keycloak_auth_url != "" ? var.keycloak_auth_url : var.keycloak_url}/realms/${var.realm_id}/protocol/openid-connect/token"
}

output "grafana_admin_url" {
  description = "The URL to access Grafana"
  value       = "https://${var.grafana_url}"
}

output "grafana_admins_group_id" {
  description = "ID of the Grafana Admins group"
  value       = keycloak_group.admins_group.id
}

output "grafana_editors_group_id" {
  description = "ID of the Grafana Editors group"
  value       = keycloak_group.editors_group.id
}

output "grafana_viewers_group_id" {
  description = "ID of the Grafana Viewers group"
  value       = keycloak_group.viewers_group.id
}

output "test_admin_user_id" {
  description = "ID of the test admin user"
  value       = var.create_test_users ? keycloak_user.admin_user[0].id : null
}

output "test_editor_user_id" {
  description = "ID of the test editor user"
  value       = var.create_test_users ? keycloak_user.editor_user[0].id : null
}

output "test_viewer_user_id" {
  description = "ID of the test viewer user"
  value       = var.create_test_users ? keycloak_user.viewer_user[0].id : null
}
