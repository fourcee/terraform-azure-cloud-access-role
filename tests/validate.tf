terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.64.0"
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

  user_ids = [
    "00000000-0000-0000-0000-00000000000a"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000",
    "/subscriptions/11111111-1111-1111-1111-111111111111",
    "/providers/Microsoft.Management/managementGroups/my-management-group"
  ]

  predefined_roles = [
    {
      name = "Reader"
    },
    {
      name              = "Contributor"
      condition         = "@Resource[Microsoft.Storage/storageAccounts:Name] StringEqualsIgnoreCase 'stsample'"
      condition_version = "2.0"
    }
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
      condition         = "@Resource[Microsoft.Compute/virtualMachines:Name] StringLike 'vm-*'"
      condition_version = "2.0"
    }
  ]
}

module "test_jit" {
  source = "./.."

  group_ids = [
    "00000000-0000-0000-0000-000000000001"
  ]

  user_ids = [
    "00000000-0000-0000-0000-00000000000b"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000"
  ]

  predefined_roles = [
    {
      name              = "Reader"
      condition         = "@Resource[Microsoft.Authorization/roleAssignments:PrincipalType] StringEqualsIgnoreCase 'Group'"
      condition_version = "2.0"
    }
  ]

  jit_enabled                         = true
  jit_require_justification           = true
  jit_approval_group_ids              = ["00000000-0000-0000-0000-000000000003"]
  jit_approval_user_ids               = ["00000000-0000-0000-0000-00000000000c"]
  jit_max_activation_duration_seconds = 3600
}

module "test_users_only" {
  source = "./.."

  user_ids = [
    "00000000-0000-0000-0000-00000000000d"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000"
  ]

  predefined_roles = [
    {
      name = "Reader"
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

output "test_jit_role_assignment_ids" {
  value = module.test_jit.role_assignment_ids
}

output "test_jit_pim_eligible_role_assignment_ids" {
  value = module.test_jit.pim_eligible_role_assignment_ids
}

output "test_jit_role_management_policy_ids" {
  value = module.test_jit.role_management_policy_ids
}

output "test_users_only_role_assignment_ids" {
  value = module.test_users_only.role_assignment_ids
}
