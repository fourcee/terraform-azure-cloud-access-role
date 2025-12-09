locals {
  # Create a list of all combinations of group_id, scope, and role_name
  role_assignments = flatten([
    for group_id in var.group_ids : [
      for scope in var.scopes : [
        for role_name in var.role_names : {
          group_id  = group_id
          scope     = scope
          role_name = role_name
          # Create a unique key for each assignment
          key = "${group_id}-${scope}-${role_name}"
        }
      ]
    ]
  ])

  # Convert the list to a map for use with for_each
  role_assignments_map = {
    for assignment in local.role_assignments :
    assignment.key => assignment
  }
}

# Lookup role definition IDs by role name
data "azurerm_role_definition" "role" {
  for_each = toset(var.role_names)
  name     = each.value
}

# Create role assignments for all combinations
resource "azurerm_role_assignment" "assignment" {
  for_each = local.role_assignments_map

  scope                = each.value.scope
  role_definition_id   = data.azurerm_role_definition.role[each.value.role_name].id
  principal_id         = each.value.group_id
  skip_service_principal_aad_check = true
}
