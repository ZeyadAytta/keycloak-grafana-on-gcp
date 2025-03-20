# modules/grafana-keycloak/main.tf

terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Create the realm if it doesn't exist
resource "keycloak_realm" "app_realm" {
  realm                    = var.realm_id
  enabled                  = true
  display_name             = var.realm_display_name != "" ? var.realm_display_name : var.realm_id
  display_name_html        = "<div class=\"kc-logo-text\"><span>${var.realm_display_name != "" ? var.realm_display_name : var.realm_id}</span></div>"
  login_theme              = "keycloak"
  access_token_lifespan    = "300s"
  ssl_required             = "external"
  registration_allowed     = false
  reset_password_allowed   = true
  remember_me              = true
  verify_email             = false
  login_with_email_allowed = true
  duplicate_emails_allowed = false
}

# Create a client for Grafana
resource "keycloak_openid_client" "grafana_client" {
  realm_id                     = keycloak_realm.app_realm.id
  client_id                    = var.grafana_oauth_client_id
  name                         = "Grafana"
  description                  = "Client for Grafana integration"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  service_accounts_enabled     = true
  valid_redirect_uris          = ["https://${var.grafana_url}/login/generic_oauth"]
  web_origins                  = ["https://${var.grafana_url}"]
  client_secret                = var.grafana_oauth_client_secret
  root_url                     = "https://${var.grafana_url}"
}

# Add default scopes to the client
resource "keycloak_openid_client_default_scopes" "grafana_default_scopes" {
  realm_id  = keycloak_realm.app_realm.id
  client_id = keycloak_openid_client.grafana_client.id
  default_scopes = [
    "profile",
    "email",
    "roles"
  ]
}

# Add optional scopes to the client
resource "keycloak_openid_client_optional_scopes" "grafana_optional_scopes" {
  realm_id  = keycloak_realm.app_realm.id
  client_id = keycloak_openid_client.grafana_client.id
  optional_scopes = [
    "offline_access"
  ]
}

# Create mapper for username
resource "keycloak_openid_user_attribute_protocol_mapper" "username_mapper" {
  realm_id            = keycloak_realm.app_realm.id
  client_id           = keycloak_openid_client.grafana_client.id
  name                = "username"
  user_attribute      = "username"
  claim_name          = "preferred_username"
  claim_value_type    = "String"
  add_to_id_token     = true
  add_to_access_token = true
  add_to_userinfo     = true
}

# Create mapper for email
resource "keycloak_openid_user_attribute_protocol_mapper" "email_mapper" {
  realm_id            = keycloak_realm.app_realm.id
  client_id           = keycloak_openid_client.grafana_client.id
  name                = "email"
  user_attribute      = "email"
  claim_name          = "email"
  claim_value_type    = "String"
  add_to_id_token     = true
  add_to_access_token = true
  add_to_userinfo     = true
}

# Create mapper for groups
resource "keycloak_openid_group_membership_protocol_mapper" "groups_mapper" {
  realm_id            = keycloak_realm.app_realm.id
  client_id           = keycloak_openid_client.grafana_client.id
  name                = "groups"
  claim_name          = "groups"
  full_path           = false
  add_to_id_token     = true
  add_to_access_token = true
  add_to_userinfo     = true
}

# Create user groups
resource "keycloak_group" "admins_group" {
  realm_id = keycloak_realm.app_realm.id
  name     = "Grafana Admins"
}

resource "keycloak_group" "editors_group" {
  realm_id = keycloak_realm.app_realm.id
  name     = "Grafana Editors"
}

resource "keycloak_group" "viewers_group" {
  realm_id = keycloak_realm.app_realm.id
  name     = "Grafana Viewers"
}

# Create test users if enabled
resource "keycloak_user" "admin_user" {
  count      = var.create_test_users ? 1 : 0
  realm_id   = keycloak_realm.app_realm.id
  username   = "grafana-test-admin"
  enabled    = true
  email      = "admin@example.com"
  first_name = "Test"
  last_name  = "Admin"

  initial_password {
    value     = var.test_users_password
    temporary = false
  }
}

resource "keycloak_user" "editor_user" {
  count      = var.create_test_users ? 1 : 0
  realm_id   = keycloak_realm.app_realm.id
  username   = "grafana-test-editor"
  enabled    = true
  email      = "editor@example.com"
  first_name = "Test"
  last_name  = "Editor"

  initial_password {
    value     = var.test_users_password
    temporary = false
  }
}

resource "keycloak_user" "viewer_user" {
  count      = var.create_test_users ? 1 : 0
  realm_id   = keycloak_realm.app_realm.id
  username   = "grafana-test-viewer"
  enabled    = true
  email      = "viewer@example.com"
  first_name = "Test"
  last_name  = "Viewer"

  initial_password {
    value     = var.test_users_password
    temporary = false
  }
}

# Assign users to groups
resource "keycloak_user_groups" "admin_user_groups" {
  count     = var.create_test_users ? 1 : 0
  realm_id  = keycloak_realm.app_realm.id
  user_id   = keycloak_user.admin_user[0].id
  group_ids = [keycloak_group.admins_group.id]
}

resource "keycloak_user_groups" "editor_user_groups" {
  count     = var.create_test_users ? 1 : 0
  realm_id  = keycloak_realm.app_realm.id
  user_id   = keycloak_user.editor_user[0].id
  group_ids = [keycloak_group.editors_group.id]
}

resource "keycloak_user_groups" "viewer_user_groups" {
  count     = var.create_test_users ? 1 : 0
  realm_id  = keycloak_realm.app_realm.id
  user_id   = keycloak_user.viewer_user[0].id
  group_ids = [keycloak_group.viewers_group.id]
}

# Create OAuth config content
locals {
  oauth_config = <<-EOT
    [server]
    domain = ${var.grafana_url}
    root_url = https://${var.grafana_url}
    
    [analytics]
    reporting_enabled = false
    check_for_updates = false
    
    [security]
    admin_user = admin
    
    [auth.generic_oauth]
    enabled = true
    name = Keycloak
    allow_sign_up = true
    client_id = ${var.grafana_oauth_client_id}
    client_secret = ${var.grafana_oauth_client_secret}
    scopes = openid profile email
    auth_url = https://${var.keycloak_auth_url != "" ? var.keycloak_auth_url : var.keycloak_url}/realms/${var.realm_id}/protocol/openid-connect/auth
    token_url = https://${var.keycloak_auth_url != "" ? var.keycloak_auth_url : var.keycloak_url}/realms/${var.realm_id}/protocol/openid-connect/token
    api_url = https://${var.keycloak_auth_url != "" ? var.keycloak_auth_url : var.keycloak_url}/realms/${var.realm_id}/protocol/openid-connect/token
    login_attribute_path = preferred_username
    use_pkce = true
    role_attribute_path = contains(groups[*], 'Grafana Admins') && 'Admin' || contains(groups[*], 'Grafana Editors') && 'Editor' || 'Viewer'
    
    [auth]
    oauth_auto_login = ${var.oauth_auto_login}
    disable_login_form = ${var.disable_login_form}
    
    [users]
    auto_assign_org_role = Viewer
  EOT
}

# Update the ConfigMap using kubectl
resource "null_resource" "update_grafana_config" {
  triggers = {
    oauth_config = local.oauth_config
  }

  provisioner "local-exec" {
    command = <<EOF
# Create a temporary file with the OAuth config
cat > /tmp/grafana.ini <<'EOF_CONFIG'
${local.oauth_config}
EOF_CONFIG

# Check if the ConfigMap exists
if kubectl get configmap grafana-config -n ${var.grafana_namespace} &>/dev/null; then
  # Update existing ConfigMap
  kubectl create configmap grafana-config -n ${var.grafana_namespace} --from-file=grafana.ini=/tmp/grafana.ini --dry-run=client -o yaml | kubectl apply -f -
else
  # Create new ConfigMap
  kubectl create configmap grafana-config -n ${var.grafana_namespace} --from-file=grafana.ini=/tmp/grafana.ini
fi

# Clean up temporary file
rm /tmp/grafana.ini
EOF
  }

  depends_on = [
    keycloak_openid_client.grafana_client,
    keycloak_openid_client_default_scopes.grafana_default_scopes,
    keycloak_openid_group_membership_protocol_mapper.groups_mapper
  ]
}

# Update deployment to mount the ConfigMap
resource "null_resource" "update_grafana_deployment" {
  triggers = {
    oauth_config = local.oauth_config
  }

  provisioner "local-exec" {
    command = <<EOF
# First, update the deployment strategy to avoid PVC issues
kubectl patch deployment grafana -n ${var.grafana_namespace} -p '{"spec":{"strategy":{"type":"Recreate"}}}'

# Check if volumes exist already
VOLUMES=$(kubectl get deployment grafana -n ${var.grafana_namespace} -o json | jq '.spec.template.spec.volumes[] | select(.name == "grafana-config-volume") | .name')

if [ -z "$VOLUMES" ]; then
  # Add volume and volume mount if they don't exist
  kubectl patch deployment grafana -n ${var.grafana_namespace} --type=json -p='[
    {
      "op": "add", 
      "path": "/spec/template/spec/volumes/-", 
      "value": {
        "name": "grafana-config-volume", 
        "configMap": {
          "name": "grafana-config"
        }
      }
    }
  ]'

  # Mount the volume
  kubectl patch deployment grafana -n ${var.grafana_namespace} --type=json -p='[
    {
      "op": "add", 
      "path": "/spec/template/spec/containers/0/volumeMounts/-", 
      "value": {
        "name": "grafana-config-volume", 
        "mountPath": "/etc/grafana/grafana.ini", 
        "subPath": "grafana.ini"
      }
    }
  ]'
fi

# Restart the deployment
kubectl rollout restart deployment grafana -n ${var.grafana_namespace}
EOF
  }

  depends_on = [
    null_resource.update_grafana_config
  ]
}
