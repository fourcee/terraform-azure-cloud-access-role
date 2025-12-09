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
  description = "List of scopes where the role assignments will be created (e.g., subscription IDs in format '/subscriptions/{subscription-id}')"
  type        = list(string)

  validation {
    condition     = length(var.scopes) > 0
    error_message = "At least one scope must be provided."
  }

  validation {
    condition = alltrue([
      for scope in var.scopes : can(regex("^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(/.*)?$", scope))
    ])
    error_message = "All scopes must start with /subscriptions/ followed by a valid subscription UUID, and may optionally include resource group or resource paths."
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
