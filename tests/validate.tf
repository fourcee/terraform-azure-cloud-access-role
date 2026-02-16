terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Mock provider configuration for validation
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Test the module with sample data
module "test" {
  source = "./.."

  group_ids = [
    "00000000-0000-0000-0000-000000000001",
    "00000000-0000-0000-0000-000000000002"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000",
    "/subscriptions/11111111-1111-1111-1111-111111111111",
    "/providers/Microsoft.Management/managementGroups/my-management-group"
  ]

  role_names = [
    "Reader",
    "Contributor"
  ]

  custom_roles = [
    {
      name              = "Custom VM Reader"
      display_name      = "Custom VM Reader"
      description       = "Custom role for reading virtual machine information"
      actions           = ["Microsoft.Compute/virtualMachines/read"]
      not_actions       = []
      data_actions      = []
      not_data_actions  = []
      assignable_scopes = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
    }
  ]
}

# Validate that outputs are defined
output "test_role_assignment_ids" {
  value = module.test.role_assignment_ids
}

output "test_role_assignments" {
  value = module.test.role_assignments
}

output "test_custom_role_definition_ids" {
  value = module.test.custom_role_definition_ids
}

output "test_custom_role_definitions" {
  value = module.test.custom_role_definitions
}
