terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example: Assign Reader and Contributor roles to two groups across two subscriptions
module "cloud_access_role" {
  source = "./../.."

  # Replace with actual Entra (Azure AD) group object IDs
  group_ids = [
    "12345678-1234-1234-1234-123456789abc", # Development Team
    "87654321-4321-4321-4321-cba987654321"  # Operations Team
  ]

  # Replace with actual subscription IDs
  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000", # Dev Subscription
    "/subscriptions/11111111-1111-1111-1111-111111111111"  # Prod Subscription
  ]

  # Azure built-in role names
  role_names = [
    "Reader",
    "Contributor"
  ]

  # Custom role definitions
  custom_roles = [
    {
      name              = "Custom VM Operator"
      display_name      = "Custom VM Operator"
      description       = "Custom role for managing virtual machines with limited permissions"
      actions           = [
        "Microsoft.Compute/virtualMachines/read",
        "Microsoft.Compute/virtualMachines/start/action",
        "Microsoft.Compute/virtualMachines/restart/action",
        "Microsoft.Compute/virtualMachines/powerOff/action"
      ]
      not_actions       = []
      data_actions      = []
      not_data_actions  = []
      assignable_scopes = [
        "/subscriptions/00000000-0000-0000-0000-000000000000",
        "/subscriptions/11111111-1111-1111-1111-111111111111"
      ]
    }
  ]
}

# Output the created role assignments
output "role_assignments" {
  description = "Details of all created role assignments"
  value       = module.cloud_access_role.role_assignments
}

output "role_assignment_ids" {
  description = "IDs of all created role assignments"
  value       = module.cloud_access_role.role_assignment_ids
}

output "custom_role_definitions" {
  description = "Details of custom role definitions created"
  value       = module.cloud_access_role.custom_role_definitions
}
