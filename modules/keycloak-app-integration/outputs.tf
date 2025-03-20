# modules/keycloak-app-integration/outputs.tf

output "realm_id" {
  description = "The ID of the Keycloak realm used for this integration"
  value       = local.realm_id
}

output "client_id" {
  description = "The client ID used for this integration"
  value       = keycloak_openid_client.app_client.client_id
}

output "client_uuid" {
  description = "The client UUID (internal Keycloak ID) used for this integration"
  value       = keycloak_openid_client.app_client.id
}

output "client_secret" {
  description = "The client secret used for this integration"
  value       = keycloak_openid_client.app_client.client_secret
  sensitive   = true
}

output "auth_url" {
  description = "The authentication URL for the client"
  value       = local.auth_url
}

output "token_url" {
  description = "The token URL for the client"
  value       = local.token_url
}

output "jwks_url" {
  description = "The JWKS URL for the client"
  value       = local.jwks_url
}

output "logout_url" {
  description = "The logout URL for the client"
  value       = local.logout_url
}
