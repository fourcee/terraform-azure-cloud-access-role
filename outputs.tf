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
