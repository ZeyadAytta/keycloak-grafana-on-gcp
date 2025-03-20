# modules/keycloak-group-management/variables.tf

variable "realm_id" {
  description = "The ID of the Keycloak realm"
  type        = string
}

variable "client_id" {
  description = "The client ID in Keycloak"
  type        = string
}

variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "Application"
}

variable "app_prefix" {
  description = "Prefix to use for group and role names"
  type        = string
  default     = "app"
}

# Group names
variable "admin_group_name" {
  description = "Name for the admin group"
  type        = string
  default     = "Admins"
}

variable "editor_group_name" {
  description = "Name for the editor group"
  type        = string
  default     = "Editors"
}

variable "viewer_group_name" {
  description = "Name for the viewer group"
  type        = string
  default     = "Viewers"
}

# Role names
variable "admin_role_name" {
  description = "Name for the admin role"
  type        = string
  default     = "admin"
}

variable "editor_role_name" {
  description = "Name for the editor role"
  type        = string
  default     = "editor"
}

variable "viewer_role_name" {
  description = "Name for the viewer role"
  type        = string
  default     = "viewer"
}

# Composite role
variable "create_composite_role" {
  description = "Whether to create a composite role"
  type        = bool
  default     = false
}

variable "composite_role_name" {
  description = "Name for the composite role"
  type        = string
  default     = "app-access"
}

# Test users
variable "create_test_users" {
  description = "Whether to create test users"
  type        = bool
  default     = false
}

variable "test_users_password" {
  description = "Password for test users"
  type        = string
  sensitive   = true
  default     = "Test123!"
}
