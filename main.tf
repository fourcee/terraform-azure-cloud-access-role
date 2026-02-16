locals {
  # Combine built-in role names with custom role names
  all_role_names = concat(var.role_names, [for role in var.custom_roles : role.name])

  # Create a list of all combinations of group_id, scope, and role_name
  role_assignments = flatten([
    for group_id in var.group_ids : [
      for scope in var.scopes : [
        for role_name in local.all_role_names : {
          group_id  = group_id
          scope     = scope
          role_name = role_name
          # Create a unique key for each assignment using :: as separator to avoid collisions
          key = "${group_id}::${scope}::${role_name}"
        }
      ]
    ]
  ])

  # Convert the list to a map for use with for_each
  role_assignments_map = {
    for assignment in local.role_assignments :
    assignment.key => assignment
  }

  # Map of custom role names for lookup
  custom_role_names = { for role in var.custom_roles : role.name => role }
}

# Create custom role definitions
resource "azurerm_role_definition" "custom" {
  for_each = local.custom_role_names

  name        = each.value.name
  scope       = each.value.assignable_scopes[0]
  description = each.value.description

  permissions {
    actions          = each.value.actions
    not_actions      = each.value.not_actions
    data_actions     = each.value.data_actions
    not_data_actions = each.value.not_data_actions
  }

  assignable_scopes = each.value.assignable_scopes
}

# Lookup role definition IDs by role name (for built-in roles only)
data "azurerm_role_definition" "role" {
  for_each = toset(var.role_names)
  name     = each.value
}

# Create role assignments for all combinations
resource "azurerm_role_assignment" "assignment" {
  for_each = local.role_assignments_map

  scope                            = each.value.scope
  role_definition_id               = contains(keys(local.custom_role_names), each.value.role_name) ? azurerm_role_definition.custom[each.value.role_name].role_definition_resource_id : data.azurerm_role_definition.role[each.value.role_name].id
  principal_id                     = each.value.group_id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true
}
