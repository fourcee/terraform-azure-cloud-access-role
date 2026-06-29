locals {
  # Predefined and custom role maps with optional assignment conditions
  predefined_roles = {
    for role in var.predefined_roles : role.name => {
      name              = role.name
      condition         = length(try(trimspace(role.condition), "")) > 0 ? try(trimspace(role.condition), "") : null
      condition_version = length(try(trimspace(role.condition_version), "")) > 0 ? try(trimspace(role.condition_version), "") : null
    }
  }

  custom_roles = {
    for role in var.custom_roles : role.name => {
      name              = role.name
      condition         = length(try(trimspace(role.condition), "")) > 0 ? try(trimspace(role.condition), "") : null
      condition_version = length(try(trimspace(role.condition_version), "")) > 0 ? try(trimspace(role.condition_version), "") : null
    }
  }

  all_roles = merge(local.predefined_roles, local.custom_roles)

  principals = concat(
    [for group_id in var.group_ids : {
      principal_id   = group_id
      principal_type = "Group"
      principal_kind = "group"
      display_name   = null
      app_id         = null
    }],
    [for user_id in var.user_ids : {
      principal_id   = user_id
      principal_type = "User"
      principal_kind = "user"
      display_name   = null
      app_id         = null
    }],
    [for principal in var.service_principals : {
      principal_id   = principal.object_id
      principal_type = "ServicePrincipal"
      principal_kind = lower(trimspace(principal.principal_type))
      display_name   = trimspace(principal.display_name)
      app_id         = try(principal.app_id, null)
    }]
  )

  # Create a list of all combinations of principal_id, scope, and role_name
  role_assignments = flatten([
    for principal in local.principals : [
      for scope in var.scopes : [
        for role_name, role in local.all_roles : {
          principal_id      = principal.principal_id
          principal_type    = principal.principal_type
          principal_kind    = principal.principal_kind
          display_name      = principal.display_name
          app_id            = principal.app_id
          scope             = scope
          role_name         = role_name
          condition         = role.condition
          condition_version = role.condition_version
          # Create a unique key for each assignment using :: as separator to avoid collisions
          key = "${principal.principal_type}::${principal.principal_id}::${scope}::${role_name}"
        }
      ]
    ]
  ])

  # Convert the list to a map for use with for_each
  role_assignments_map = {
    for assignment in local.role_assignments :
    assignment.key => assignment
  }

  # Map of custom roles for lookup and creation
  custom_role_names = { for role in var.custom_roles : role.name => role }

  # Combined map of role definition IDs (built-in and custom)
  role_definition_ids = merge(
    { for name, role in data.azurerm_role_definition.role : name => role.id },
    { for name, role in azurerm_role_definition.custom : name => role.role_definition_resource_id }
  )

  # Role management policies are defined per scope + role definition
  role_policies = flatten([
    for scope in var.scopes : [
      for role_name in keys(local.all_roles) : {
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

  jit_approvers = concat(
    [for group_id in var.jit_approval_group_ids : {
      object_id = group_id
      type      = "Group"
    }],
    [for user_id in var.jit_approval_user_ids : {
      object_id = user_id
      type      = "User"
    }]
  )

  jit_approvers_map = {
    for idx, approver in local.jit_approvers :
    tostring(idx) => approver
  }

  jit_max_activation_duration_iso8601 = var.jit_max_activation_duration_seconds == null ? null : format("PT%dS", floor(var.jit_max_activation_duration_seconds))
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
  for_each = toset([for role in var.predefined_roles : role.name])
  name     = each.value
}

# Create role assignments for all combinations
resource "azurerm_role_assignment" "assignment" {
  for_each = var.jit_enabled ? {} : local.role_assignments_map

  scope                            = each.value.scope
  role_definition_id               = local.role_definition_ids[each.value.role_name]
  principal_id                     = each.value.principal_id
  principal_type                   = each.value.principal_type
  skip_service_principal_aad_check = true
  condition                        = each.value.condition
  condition_version                = each.value.condition_version
}

resource "azurerm_role_management_policy" "jit" {
  for_each = var.jit_enabled ? local.role_policies_map : {}

  scope              = each.value.scope
  role_definition_id = local.role_definition_ids[each.value.role_name]

  activation_rules {
    maximum_duration      = local.jit_max_activation_duration_iso8601
    require_justification = var.jit_require_justification
    require_approval      = length(local.jit_approvers) > 0

    dynamic "approval_stage" {
      for_each = length(local.jit_approvers) > 0 ? [1] : []
      content {
        dynamic "primary_approver" {
          for_each = local.jit_approvers_map
          content {
            object_id = primary_approver.value.object_id
            type      = primary_approver.value.type
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
  principal_id       = each.value.principal_id
  condition          = each.value.condition
  condition_version  = each.value.condition_version
}
