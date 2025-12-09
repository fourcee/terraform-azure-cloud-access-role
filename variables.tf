variable "group_ids" {
  description = "List of Entra (Azure AD) group object IDs to assign access to"
  type        = list(string)
}

variable "scopes" {
  description = "List of scopes where the role assignments will be created (e.g., subscription IDs in format '/subscriptions/{subscription-id}')"
  type        = list(string)
}

variable "role_names" {
  description = "List of Azure built-in or custom role names to assign"
  type        = list(string)
}
