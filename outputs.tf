output "role_assignment_ids" {
  description = "Map of role assignment IDs, keyed by 'group_id::scope::role_name'"
  value = {
    for key, assignment in azurerm_role_assignment.assignment :
    key => assignment.id
  }
}

output "role_assignments" {
  description = "Map of role assignment details"
  value = {
    for key, assignment in azurerm_role_assignment.assignment :
    key => {
      id               = assignment.id
      principal_id     = assignment.principal_id
      role_name        = assignment.role_definition_name
      scope            = assignment.scope
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
      id                            = role.id
      role_definition_id            = role.role_definition_id
      role_definition_resource_id   = role.role_definition_resource_id
      name                          = role.name
      scope                         = role.scope
      assignable_scopes             = role.assignable_scopes
    }
  }
}
