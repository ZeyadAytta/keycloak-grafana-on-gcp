# modules/keycloak-app-integration/main.tf

# This module creates a Keycloak realm, client, and configures integration between 
# Keycloak and an application for OAuth2/OIDC authentication.

terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.0"
    }
  }
}

# Create or use existing Keycloak realm
resource "keycloak_realm" "app_realm" {
  count                   = var.create_realm ? 1 : 0
  realm                   = var.realm_id
  enabled                 = true
  display_name            = var.realm_display_name
  display_name_html       = "<div class=\"kc-logo-text\"><span>${var.realm_display_name}</span></div>"
  login_theme             = var.login_theme
  access_token_lifespan   = var.access_token_lifespan
  ssl_required            = "external"
  registration_allowed    = false
  reset_password_allowed  = true
  remember_me             = true
  verify_email            = false
  login_with_email_allowed = true
  duplicate_emails_allowed = false
}

locals {
  realm_id = var.create_realm ? keycloak_realm.app_realm[0].id : var.realm_id
  # Use separate auth URL if provided, otherwise use the admin URL
  auth_base_url = var.keycloak_auth_url != "" ? "https://${var.keycloak_auth_url}" : var.keycloak_base_url
}

resource "keycloak_openid_client" "app_client" {
  realm_id                     = local.realm_id
  client_id                    = var.client_id
  name                         = var.client_name
  description                  = "Client for ${var.client_name} integration"
  enabled                      = true
  
  # Standard OIDC settings
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  
  # Enable service accounts for authorization
  service_accounts_enabled     = true
  
  # Web origins and redirect URIs
  root_url                     = var.app_root_url
  valid_redirect_uris          = var.valid_redirect_uris
  web_origins                  = var.web_origins
  
  # Client authentication
  client_secret                = var.client_secret
}
# Setup client scope mappings
resource "keycloak_openid_client_default_scopes" "app_client_default_scopes" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  
  default_scopes = var.default_scopes
}

resource "keycloak_openid_client_optional_scopes" "app_client_optional_scopes" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  
  optional_scopes = var.optional_scopes
}

# Create mapper for username
resource "keycloak_openid_user_attribute_protocol_mapper" "username_mapper" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  name      = "username"

  user_attribute              = "username"
  claim_name                  = var.username_claim_name
  claim_value_type            = "String"
  add_to_id_token             = true
  add_to_access_token         = true
  add_to_userinfo             = true
}

# Create mapper for email
resource "keycloak_openid_user_attribute_protocol_mapper" "email_mapper" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  name      = "email"

  user_attribute              = "email"
  claim_name                  = var.email_claim_name
  claim_value_type            = "String"
  add_to_id_token             = true
  add_to_access_token         = true
  add_to_userinfo             = true
}

# Create groups mapper if enabled
resource "keycloak_openid_group_membership_protocol_mapper" "groups_mapper" {
  count     = var.map_groups ? 1 : 0
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  name      = "groups"

  claim_name                  = var.groups_claim_name
  full_path                   = var.groups_full_path
  add_to_id_token             = true
  add_to_access_token         = true
  add_to_userinfo             = true
}

# Create roles mapper if enabled
resource "keycloak_openid_user_realm_role_protocol_mapper" "realm_roles_mapper" {
  count     = var.map_realm_roles ? 1 : 0
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  name      = "realm-roles"

  claim_name                  = var.realm_roles_claim_name
  multivalued                 = true
  add_to_id_token             = true
  add_to_access_token         = true
  add_to_userinfo             = true
}

# Create client roles mapper if enabled
resource "keycloak_openid_user_client_role_protocol_mapper" "client_roles_mapper" {
  count     = var.map_client_roles ? 1 : 0
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  name      = "client-roles"

  claim_name                  = var.client_roles_claim_name
  client_id_for_role_mappings = keycloak_openid_client.app_client.client_id
  multivalued                 = true
  add_to_id_token             = true
  add_to_access_token         = true
  add_to_userinfo             = true
}

# Create audience mapper if enabled
resource "keycloak_openid_audience_protocol_mapper" "audience_mapper" {
  count     = var.add_audience_mapper ? 1 : 0
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.app_client.id
  name      = "audience-mapper"

  included_client_audience = keycloak_openid_client.app_client.client_id
  add_to_id_token          = true
  add_to_access_token      = true
}

# Return essential URLs for app configuration
locals {
  auth_url  = "${local.auth_base_url}/realms/${local.realm_id}/protocol/openid-connect/auth"
  token_url = "${local.auth_base_url}/realms/${local.realm_id}/protocol/openid-connect/token"
  jwks_url  = "${local.auth_base_url}/realms/${local.realm_id}/protocol/openid-connect/certs"
  logout_url = "${local.auth_base_url}/realms/${local.realm_id}/protocol/openid-connect/logout"
}
