# modules/grafana-keycloak-integration/main.tf

# Use the generic Keycloak app integration module
module "keycloak_integration" {
  source = "../keycloak-app-integration"

  # Keycloak configuration
  keycloak_base_url = "https://${var.keycloak_url}"
  
  # Realm configuration
  create_realm       = var.create_realm
  realm_id           = var.realm_id
  realm_display_name = var.realm_display_name != "" ? var.realm_display_name : var.realm_id
  login_theme        = var.login_theme
  
  # Client configuration
  client_id     = var.grafana_oauth_client_id
  client_name   = "Grafana"
  client_secret = var.grafana_oauth_client_secret
  
  # Grafana-specific URLs
  app_root_url        = "https://${var.grafana_url}"
  valid_redirect_uris = ["https://${var.grafana_url}/login/generic_oauth"]
  web_origins         = ["https://${var.grafana_url}"]
  
  # OAuth scopes
  default_scopes = [
    "profile", 
    "email", 
    "roles", 
    "web-origins"
  ]
  
  # Protocol mappers for Grafana
  username_claim_name    = "preferred_username"
  email_claim_name       = "email"
  map_groups             = true
  groups_claim_name      = "groups"
  groups_full_path       = false  # Grafana works better with simple group names
  map_realm_roles        = true
  realm_roles_claim_name = "roles"
  map_client_roles       = false  # We'll use groups for Grafana roles
  add_audience_mapper    = true
}

# Update Grafana configuration with Keycloak OAuth2 settings
resource "kubernetes_config_map" "grafana_oauth_config" {
  metadata {
    name      = "grafana-oauth-config"
    namespace = var.grafana_namespace
  }

  data = {
    "oauth.ini" = <<-EOT
      [auth.generic_oauth]
      enabled = true
      name = Keycloak
      allow_sign_up = true
      client_id = ${var.grafana_oauth_client_id}
      client_secret = ${var.grafana_oauth_client_secret}
      scopes = openid profile email
      auth_url = ${module.keycloak_integration.auth_url}
      token_url = ${module.keycloak_integration.token_url}
      api_url = ${module.keycloak_integration.token_url}
      login_attribute_path = preferred_username
      use_pkce = true
      
      [auth]
      oauth_auto_login = ${var.oauth_auto_login}
      disable_login_form = ${var.disable_login_form}
      
      [security]
      oauth_auto_login = ${var.oauth_auto_login}
      disable_initial_admin_creation = ${var.disable_initial_admin_creation}
      
      [users]
      auto_assign_org_role = ${var.default_user_role}
      
      [server]
      root_url = https://${var.grafana_url}
    EOT
  }
}

# Patch the Grafana deployment to use the OAuth configuration
resource "null_resource" "patch_grafana_deployment" {
  triggers = {
    config_map_version = kubernetes_config_map.grafana_oauth_config.metadata[0].resource_version
  }

  provisioner "local-exec" {
    command = <<EOF
kubectl patch deployment grafana -n ${var.grafana_namespace} --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes/-",
    "value": {
      "name": "grafana-oauth-config",
      "configMap": {
        "name": "${kubernetes_config_map.grafana_oauth_config.metadata[0].name}"
      }
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts/-",
    "value": {
      "name": "grafana-oauth-config",
      "mountPath": "/etc/grafana/provisioning/custom.d/oauth.ini",
      "subPath": "oauth.ini"
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env/-",
    "value": {
      "name": "GF_PATHS_PROVISIONING",
      "value": "/etc/grafana/provisioning:/etc/grafana/provisioning/custom.d"
    }
  }
]'
EOF
  }

  depends_on = [
    kubernetes_config_map.grafana_oauth_config
  ]
}

# Create default Grafana admin user in Keycloak if enabled
resource "keycloak_user" "grafana_admin" {
  count       = var.create_default_admin_user ? 1 : 0
  realm_id    = module.keycloak_integration.realm_id
  username    = "grafana-admin"
  enabled     = true
  email       = var.admin_user_email
  first_name  = "Grafana"
  last_name   = "Admin"
  
  initial_password {
    value     = var.default_admin_password
    temporary = false
  }
}

# Create default Grafana viewer user in Keycloak if enabled
resource "keycloak_user" "grafana_viewer" {
  count       = var.create_default_viewer_user ? 1 : 0
  realm_id    = module.keycloak_integration.realm_id
  username    = "grafana-viewer"
  enabled     = true
  email       = var.viewer_user_email
  first_name  = "Grafana"
  last_name   = "Viewer"
  
  initial_password {
    value     = var.default_viewer_password
    temporary = false
  }
}
