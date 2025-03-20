# modules/keycloak-group-management/main.tf

# This module creates and manages Keycloak groups and their role mappings
# specifically designed for application integration

terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.0"
    }
  }
}

# Create groups for different access levels
resource "keycloak_group" "app_admins" {
  realm_id = var.realm_id
  name     = var.admin_group_name
}

resource "keycloak_group" "app_editors" {
  realm_id = var.realm_id
  name     = var.editor_group_name
}

resource "keycloak_group" "app_viewers" {
  realm_id = var.realm_id
  name     = var.viewer_group_name
}

# Create client roles for the application
resource "keycloak_role" "app_admin_role" {
  realm_id    = var.realm_id
  client_id   = var.client_id
  name        = var.admin_role_name
  description = "Administrator role for ${var.app_name}"
}

resource "keycloak_role" "app_editor_role" {
  realm_id    = var.realm_id
  client_id   = var.client_id
  name        = var.editor_role_name
  description = "Editor role for ${var.app_name}"
}

resource "keycloak_role" "app_viewer_role" {
  realm_id    = var.realm_id
  client_id   = var.client_id
  name        = var.viewer_role_name
  description = "Viewer role for ${var.app_name}"
}

# Map client roles to groups
resource "keycloak_group_roles" "admin_group_roles" {
  realm_id = var.realm_id
  group_id = keycloak_group.app_admins.id
  
  role_ids = [
    keycloak_role.app_admin_role.id,
    keycloak_role.app_editor_role.id,
    keycloak_role.app_viewer_role.id
  ]
}

resource "keycloak_group_roles" "editor_group_roles" {
  realm_id = var.realm_id
  group_id = keycloak_group.app_editors.id
  
  role_ids = [
    keycloak_role.app_editor_role.id,
    keycloak_role.app_viewer_role.id
  ]
}

resource "keycloak_group_roles" "viewer_group_roles" {
  realm_id = var.realm_id
  group_id = keycloak_group.app_viewers.id
  
  role_ids = [
    keycloak_role.app_viewer_role.id
  ]
}

# Create test users if requested
resource "keycloak_user" "test_admin_user" {
  count      = var.create_test_users ? 1 : 0
  realm_id   = var.realm_id
  username   = "${var.app_prefix}-test-admin"
  enabled    = true
  email      = "${var.app_prefix}-test-admin@example.com"
  first_name = "Test"
  last_name  = "Admin"
  
  initial_password {
    value     = var.test_users_password
    temporary = false
  }
}

resource "keycloak_user" "test_editor_user" {
  count      = var.create_test_users ? 1 : 0
  realm_id   = var.realm_id
  username   = "${var.app_prefix}-test-editor"
  enabled    = true
  email      = "${var.app_prefix}-test-editor@example.com"
  first_name = "Test"
  last_name  = "Editor"
  
  initial_password {
    value     = var.test_users_password
    temporary = false
  }
}

resource "keycloak_user" "test_viewer_user" {
  count      = var.create_test_users ? 1 : 0
  realm_id   = var.realm_id
  username   = "${var.app_prefix}-test-viewer"
  enabled    = true
  email      = "${var.app_prefix}-test-viewer@example.com"
  first_name = "Test"
  last_name  = "Viewer"
  
  initial_password {
    value     = var.test_users_password
    temporary = false
  }
}

# Assign test users to groups
resource "keycloak_user_groups" "test_admin_groups" {
  count     = var.create_test_users ? 1 : 0
  realm_id  = var.realm_id
  user_id   = keycloak_user.test_admin_user[0].id
  group_ids = [keycloak_group.app_admins.id]
}

resource "keycloak_user_groups" "test_editor_groups" {
  count     = var.create_test_users ? 1 : 0
  realm_id  = var.realm_id
  user_id   = keycloak_user.test_editor_user[0].id
  group_ids = [keycloak_group.app_editors.id]
}

resource "keycloak_user_groups" "test_viewer_groups" {
  count     = var.create_test_users ? 1 : 0
  realm_id  = var.realm_id
  user_id   = keycloak_user.test_viewer_user[0].id
  group_ids = [keycloak_group.app_viewers.id]
}

# Create a composite role for optional permissions
resource "keycloak_role" "app_composite_role" {
  count       = var.create_composite_role ? 1 : 0
  realm_id    = var.realm_id
  name        = var.composite_role_name
  description = "Composite role for ${var.app_name} permissions"
  composite_roles = concat(
    [keycloak_role.app_admin_role.id],
    [keycloak_role.app_editor_role.id],
    [keycloak_role.app_viewer_role.id]
  )
}
