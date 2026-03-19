output "role_assignment_ids" {
  description = "Map of role assignment IDs, keyed by 'principal_type::principal_id::scope::role_name'"
  value = var.jit_enabled ? {
    for key, assignment in azurerm_pim_eligible_role_assignment.assignment :
    key => assignment.id
    } : {
    for key, assignment in azurerm_role_assignment.assignment :
    key => assignment.id
  }
}

output "role_assignments" {
  description = "Map of role assignment details"
  value = {
    for key, assignment in local.role_assignments_map :
    key => {
      id                 = var.jit_enabled ? azurerm_pim_eligible_role_assignment.assignment[key].id : azurerm_role_assignment.assignment[key].id
      principal_id       = assignment.principal_id
      principal_type     = assignment.principal_type
      role_name          = assignment.role_name
      role_definition_id = local.role_definition_ids[assignment.role_name]
      scope              = assignment.scope
      jit_enabled        = var.jit_enabled
    }
  }
}

output "custom_role_definition_ids" {
  description = "Map of custom role definition IDs, keyed by role name"
  value = {
    for name, role in azurerm_role_definition.custom :
    name => role.role_definition_id
  }
}

output "custom_role_definitions" {
  description = "Map of custom role definition details"
  value = {
    for name, role in azurerm_role_definition.custom :
    name => {
      id                          = role.id
      role_definition_id          = role.role_definition_id
      role_definition_resource_id = role.role_definition_resource_id
      name                        = role.name
      scope                       = role.scope
      assignable_scopes           = role.assignable_scopes
    }
  }
}

output "pim_eligible_role_assignments" {
  value = var.jit_enabled ? {
    for key, assignment in azurerm_pim_eligible_role_assignment.assignment :
    key => {
      scope                         = assignment.scope
      role_definition_id            = assignment.role_definition_id
      eligible_role_assignment_id   = assignment.id
      principal_id                  = assignment.principal_id
    }
  } : {}
}

output "role_management_policy_ids" {
  description = "Map of role management policy IDs, keyed by 'scope::role_name' (empty when jit_enabled is false)"
  value = var.jit_enabled ? {
    for key, policy in azurerm_role_management_policy.jit :
    key => policy.id
  } : {}
}
