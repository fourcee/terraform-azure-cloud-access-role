variable "group_ids" {
  description = "List of Entra (Azure AD) group object IDs to assign access to"
  type        = list(string)

  validation {
    condition     = length(var.group_ids) > 0
    error_message = "At least one group ID must be provided."
  }

  validation {
    condition = alltrue([
      for id in var.group_ids : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "All group IDs must be valid UUIDs in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "scopes" {
  description = "List of scopes where the role assignments will be created (e.g., '/subscriptions/{subscription-id}' or '/providers/Microsoft.Management/managementGroups/{management-group-id}')"
  type        = list(string)

  validation {
    condition     = length(var.scopes) > 0
    error_message = "At least one scope must be provided."
  }

  validation {
    condition = alltrue([
      for scope in var.scopes : can(regex("^(/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(/.*)?|/providers/Microsoft.Management/managementGroups/[a-zA-Z0-9._-]+)$", scope))
    ])
    error_message = "All scopes must be either a subscription scope (/subscriptions/{uuid}[/...]) or a management group scope (/providers/Microsoft.Management/managementGroups/{id})."
  }
}

variable "role_names" {
  description = "List of Azure built-in or custom role names to assign"
  type        = list(string)

  validation {
    condition     = length(var.role_names) > 0
    error_message = "At least one role name must be provided."
  }

  validation {
    condition = alltrue([
      for name in var.role_names : length(trimspace(name)) > 0
    ])
    error_message = "Role names cannot be empty or contain only whitespace."
  }
}

variable "custom_roles" {
  description = "List of custom role definitions to create and include as part of the assignment"
  type = list(object({
    name              = string
    display_name      = string
    description       = string
    actions           = list(string)
    not_actions       = list(string)
    data_actions      = list(string)
    not_data_actions  = list(string)
    assignable_scopes = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for role in var.custom_roles : length(trimspace(role.name)) > 0
    ])
    error_message = "Custom role names cannot be empty or contain only whitespace."
  }

  validation {
    condition = alltrue([
      for role in var.custom_roles : length(trimspace(role.display_name)) > 0
    ])
    error_message = "Custom role display names cannot be empty or contain only whitespace."
  }

  validation {
    condition = alltrue([
      for role in var.custom_roles : length(role.assignable_scopes) > 0
    ])
    error_message = "Custom roles must have at least one assignable scope."
  }
}
