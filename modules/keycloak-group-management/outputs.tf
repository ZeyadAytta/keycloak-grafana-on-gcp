# modules/keycloak-group-management/outputs.tf

output "admin_group_id" {
  description = "ID of the admin group"
  value       = keycloak_group.app_admins.id
}

output "editor_group_id" {
  description = "ID of the editor group"
  value       = keycloak_group.app_editors.id
}

output "viewer_group_id" {
  description = "ID of the viewer group"
  value       = keycloak_group.app_viewers.id
}

output "admin_role_id" {
  description = "ID of the admin role"
  value       = keycloak_role.app_admin_role.id
}

output "editor_role_id" {
  description = "ID of the editor role"
  value       = keycloak_role.app_editor_role.id
}

output "viewer_role_id" {
  description = "ID of the viewer role"
  value       = keycloak_role.app_viewer_role.id
}

output "composite_role_id" {
  description = "ID of the composite role"
  value       = var.create_composite_role ? keycloak_role.app_composite_role[0].id : null
}

output "test_admin_user_id" {
  description = "ID of the test admin user"
  value       = var.create_test_users ? keycloak_user.test_admin_user[0].id : null
}

output "test_editor_user_id" {
  description = "ID of the test editor user"
  value       = var.create_test_users ? keycloak_user.test_editor_user[0].id : null
}

output "test_viewer_user_id" {
  description = "ID of the test viewer user"
  value       = var.create_test_users ? keycloak_user.test_viewer_user[0].id : null
}
