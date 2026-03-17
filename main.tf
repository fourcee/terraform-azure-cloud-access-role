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

  # Combined map of role definition IDs (built-in and custom)
  role_definition_ids = merge(
    { for name, role in data.azurerm_role_definition.role : name => role.id },
    { for name, role in azurerm_role_definition.custom : name => role.role_definition_resource_id }
  )

  # Role management policies are defined per scope + role definition
  role_policies = flatten([
    for scope in var.scopes : [
      for role_name in local.all_role_names : {
        scope     = scope
        role_name = role_name
        key       = "${scope}::${role_name}"
      }
    ]
  ])

  role_policies_map = {
    for policy in local.role_policies :
    policy.key => policy
  }
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
  for_each = var.jit_enabled ? {} : local.role_assignments_map

  scope                            = each.value.scope
  role_definition_id               = local.role_definition_ids[each.value.role_name]
  principal_id                     = each.value.group_id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_management_policy" "jit" {
  for_each = var.jit_enabled ? local.role_policies_map : {}

  scope              = each.value.scope
  role_definition_id = local.role_definition_ids[each.value.role_name]

  activation_rules {
    maximum_duration      = format("PT%vS", var.jit_max_activation_duration_seconds)
    require_justification = var.jit_require_justification
    require_approval      = length(var.jit_approval_group_ids) > 0

    dynamic "approval_stage" {
      for_each = length(var.jit_approval_group_ids) > 0 ? [1] : []
      content {
        dynamic "primary_approver" {
          for_each = toset(var.jit_approval_group_ids)
          content {
            object_id = primary_approver.value
            type      = "Group"
          }
        }
      }
    }
  }
}

resource "azurerm_pim_eligible_role_assignment" "assignment" {
  for_each = var.jit_enabled ? local.role_assignments_map : {}

  scope              = each.value.scope
  role_definition_id = local.role_definition_ids[each.value.role_name]
  principal_id       = each.value.group_id
}
