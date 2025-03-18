terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Create a Keycloak realm if it doesn't exist
resource "keycloak_realm" "grafana_realm" {
  provider = keycloak
  realm             = var.keycloak_realm
  enabled           = true
  display_name      = "CloudFiftyTwo Organization"
  display_name_html = "<div class=\"kc-logo-text\">CloudFiftyTwo</div>"

  login_theme       = "keycloak"
  account_theme     = "keycloak"
  admin_theme       = "keycloak"
  email_theme       = "keycloak"

  access_token_lifespan = "8h"
  ssl_required    = "external"
  password_policy = "length(8) and notUsername"
}

# Create roles in the realm
resource "keycloak_role" "grafana_admin_role" {
  provider    = keycloak
  realm_id    = keycloak_realm.grafana_realm.id
  name        = "grafana-admin"
  description = "Grafana Administrator"
}

resource "keycloak_role" "grafana_editor_role" {
  provider    = keycloak
  realm_id    = keycloak_realm.grafana_realm.id
  name        = "grafana-editor"
  description = "Grafana Editor"
}

resource "keycloak_role" "grafana_viewer_role" {
  provider    = keycloak
  realm_id    = keycloak_realm.grafana_realm.id
  name        = "grafana-viewer"
  description = "Grafana Viewer"
}

# Create a default admin user
resource "keycloak_user" "admin_user" {
  provider   = keycloak
  realm_id   = keycloak_realm.grafana_realm.id
  username   = "grafana-admin"
  enabled    = true
  email      = "admin@cloudfiftytwo.com"
  first_name = "Grafana"
  last_name  = "Admin"

  initial_password {
    value     = var.default_admin_password
    temporary = false
  }
}

# Assign admin role to admin user
resource "keycloak_user_roles" "admin_user_roles" {
  provider  = keycloak
  realm_id  = keycloak_realm.grafana_realm.id
  user_id   = keycloak_user.admin_user.id

  role_ids = [
    keycloak_role.grafana_admin_role.id
  ]
}

# Create a default viewer user
resource "keycloak_user" "viewer_user" {
  provider   = keycloak
  realm_id   = keycloak_realm.grafana_realm.id
  username   = "grafana-viewer"
  enabled    = true
  email      = "viewer@cloudfiftytwo.com"
  first_name = "Grafana"
  last_name  = "Viewer"

  initial_password {
    value     = var.default_viewer_password
    temporary = false
  }
}

# Assign viewer role to viewer user
resource "keycloak_user_roles" "viewer_user_roles" {
  provider  = keycloak
  realm_id  = keycloak_realm.grafana_realm.id
  user_id   = keycloak_user.viewer_user.id

  role_ids = [
    keycloak_role.grafana_viewer_role.id
  ]
}

# Create a Keycloak client for Grafana
resource "keycloak_openid_client" "grafana_client" {
  provider = keycloak
  realm_id            = keycloak_realm.grafana_realm.id
  client_id           = var.grafana_oauth_client_id
  name                = "Grafana"
  enabled             = true
  access_type         = "CONFIDENTIAL"
  standard_flow_enabled = true

  valid_redirect_uris = [
    "https://${var.grafana_url}/login/generic_oauth"
  ]

  web_origins = [
    "https://${var.grafana_url}",
    "+"
  ]

  # Set client secret directly in the client configuration
  client_secret = var.grafana_oauth_client_secret
}

# Create Keycloak mapper for Grafana roles
resource "keycloak_openid_user_attribute_protocol_mapper" "grafana_roles_mapper" {
  provider = keycloak
  realm_id    = keycloak_realm.grafana_realm.id
  client_id   = keycloak_openid_client.grafana_client.id
  name        = "grafana-roles"
  user_attribute = "grafana_roles"
  claim_name  = "roles"
  claim_value_type = "String"
  multivalued = true
}

# Get the existing grafana-config ConfigMap
data "kubernetes_config_map" "existing_grafana_config" {
  provider = kubernetes
  metadata {
    name      = "grafana-config"
    namespace = var.grafana_namespace
  }
}

# Use local-exec to check if the ConfigMap exists and update it
resource "null_resource" "update_grafana_config" {
  triggers = {
    grafana_oauth_client_id     = var.grafana_oauth_client_id
    grafana_oauth_client_secret = var.grafana_oauth_client_secret
    keycloak_realm              = var.keycloak_realm
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Create a temporary file with the updated content
      cat > /tmp/grafana-config-update.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-config
  namespace: ${var.grafana_namespace}
data:
  grafana.ini: |
    [server]
    domain = grafana.cloudfiftytwo.com
    root_url = https://grafana.cloudfiftytwo.com

    [analytics]
    reporting_enabled = false
    check_for_updates = false

    [security]
    admin_user = admin

    [auth.generic_oauth]
    name = Keycloak
    enabled = true
    allow_sign_up = true
    client_id = ${var.grafana_oauth_client_id}
    client_secret = ${var.grafana_oauth_client_secret}
    scopes = openid profile email
    auth_url = https://keycloak-rad.cloudfiftytwo.com/realms/${var.keycloak_realm}/protocol/openid-connect/auth
    token_url = https://keycloak-rad.cloudfiftytwo.com/realms/${var.keycloak_realm}/protocol/openid-connect/token
    api_url = https://keycloak-rad.cloudfiftytwo.com/realms/${var.keycloak_realm}/protocol/openid-connect/userinfo
    role_attribute_path = contains(roles[*], 'grafana-admin') && 'Admin' || contains(roles[*], 'grafana-editor') && 'Editor' || 'Viewer'
    use_pkce = true
    allow_assign_grafana_admin = true
EOF

      # Apply the update using kubectl
      kubectl apply -f /tmp/grafana-config-update.yaml

      # Clean up temporary file
      rm /tmp/grafana-config-update.yaml
    EOT

    interpreter = ["/bin/bash", "-c"]
  }
}
