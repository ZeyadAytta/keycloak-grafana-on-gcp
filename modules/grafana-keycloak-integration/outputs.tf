output "keycloak_realm_id" {
  value = keycloak_realm.grafana_realm.id
  description = "The ID of the Keycloak realm"
}

output "grafana_client_id" {
  value = keycloak_openid_client.grafana_client.client_id
  description = "The client ID for Grafana in Keycloak"
}

output "keycloak_admin_user" {
  value = keycloak_user.admin_user.username
  description = "The admin user created in Keycloak for Grafana access"
}

output "keycloak_viewer_user" {
  value = keycloak_user.viewer_user.username
  description = "The viewer user created in Keycloak for Grafana access"
}

output "grafana_auth_url" {
  value = "https://keycloak-rad.cloudfiftytwo.com/realms/${var.keycloak_realm}/protocol/openid-connect/auth"
  description = "The authentication URL for Grafana"
}

output "grafana_token_url" {
  value = "https://keycloak-rad.cloudfiftytwo.com/realms/${var.keycloak_realm}/protocol/openid-connect/token"
  description = "The token URL for Grafana"
}

output "grafana_api_url" {
  value = "https://keycloak-rad.cloudfiftytwo.com/realms/${var.keycloak_realm}/protocol/openid-connect/userinfo"
  description = "The API URL for Grafana"
}
