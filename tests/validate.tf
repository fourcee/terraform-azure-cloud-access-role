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
  source = ".."

  group_ids = [
    "00000000-0000-0000-0000-000000000001",
    "00000000-0000-0000-0000-000000000002"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000",
    "/subscriptions/11111111-1111-1111-1111-111111111111"
  ]

  role_names = [
    "Reader",
    "Contributor"
  ]
}

# Validate that outputs are defined
output "test_role_assignment_ids" {
  value = module.test.role_assignment_ids
}

output "test_role_assignments" {
  value = module.test.role_assignments
}
