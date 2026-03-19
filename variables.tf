variable "group_ids" {
  description = "List of Entra (Azure AD) group object IDs to assign access to"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.group_ids) > 0 || length(var.user_ids) > 0
    error_message = "At least one principal ID must be provided via group_ids and/or user_ids."
  }

  validation {
    condition = alltrue([
      for id in var.group_ids : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "All group IDs must be valid UUIDs in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "user_ids" {
  description = "List of Entra (Azure AD) user object IDs to assign access to"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.user_ids : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "All user IDs must be valid UUIDs in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
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

variable "predefined_roles" {
  description = "List of Azure built-in role assignments to create, each with optional condition settings"
  type = list(object({
    name              = string
    condition         = optional(string)
    condition_version = optional(string)
  }))
  default     = []

  validation {
    condition = alltrue([
      for role in var.predefined_roles : length(trimspace(role.name)) > 0
    ])
    error_message = "Predefined role names cannot be empty or contain only whitespace."
  }

  validation {
    condition = length(distinct([
      for role in var.predefined_roles : lower(trimspace(role.name))
    ])) == length(var.predefined_roles)
    error_message = "Predefined role names must be unique (case-insensitive comparison)."
  }

  validation {
    condition = alltrue([
      for role in var.predefined_roles :
      (
        (try(role.condition, null) == null && try(role.condition_version, null) == null) ||
        (length(trimspace(try(role.condition, ""))) > 0 && length(trimspace(try(role.condition_version, ""))) > 0)
      )
    ])
    error_message = "Predefined roles condition and condition_version must either both be set (non-empty) or both be omitted."
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
    condition         = optional(string)
    condition_version = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for role in var.custom_roles : length(trimspace(role.name)) > 0
    ])
    error_message = "Custom role names cannot be empty or contain only whitespace."
  }

  validation {
    condition = length(distinct([
      for role in var.custom_roles : lower(trimspace(role.name))
    ])) == length(var.custom_roles)
    error_message = "Custom role names must be unique (case-insensitive comparison)."
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

  validation {
    condition = alltrue([
      for role in var.custom_roles :
      (
        (try(role.condition, null) == null && try(role.condition_version, null) == null) ||
        (length(trimspace(try(role.condition, ""))) > 0 && length(trimspace(try(role.condition_version, ""))) > 0)
      )
    ])
    error_message = "Custom roles condition and condition_version must either both be set (non-empty) or both be omitted."
  }

  validation {
    condition = length(setintersection(
      toset([for role in var.custom_roles : lower(trimspace(role.name))]),
      toset([for role in var.predefined_roles : lower(trimspace(role.name))])
    )) == 0
    error_message = "Custom role names must not overlap with predefined role names (case-insensitive comparison)."
  }
}

variable "jit_enabled" {
  description = "Enable Azure PIM eligible role assignments instead of regular role assignments"
  type        = bool
  default     = false
}

variable "jit_require_justification" {
  description = "Require justification when activating a JIT role assignment"
  type        = bool
  default     = false
}

variable "jit_approval_group_ids" {
  description = "List of Entra group object IDs used as JIT activation approvers"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.jit_approval_group_ids : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "All JIT approval group IDs must be valid UUIDs in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "jit_approval_user_ids" {
  description = "List of Entra user object IDs used as JIT activation approvers"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.jit_approval_user_ids : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "All JIT approval user IDs must be valid UUIDs in the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx."
  }
}

variable "jit_max_activation_duration_seconds" {
  description = "Maximum JIT activation duration in seconds"
  type        = number
  default     = null

  validation {
    condition     = var.jit_enabled ? try(var.jit_max_activation_duration_seconds > 0, false) : true
    error_message = "jit_max_activation_duration_seconds must be set to a value greater than 0 when jit_enabled is true."
  }

  validation {
    condition     = try(var.jit_max_activation_duration_seconds == floor(var.jit_max_activation_duration_seconds), true)
    error_message = "jit_max_activation_duration_seconds must be a whole number of seconds."
  }
}
