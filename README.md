# Terraform Azure Cloud Access Role

Terraform module for creating Azure IAM role assignments to Entra (Azure AD) groups and users across multiple scopes and roles.

## Overview

This module simplifies the process of assigning Azure roles to Entra principals by automatically creating role assignments for all combinations of:
- Entra group and/or user IDs (principals)
- Scopes (management groups, subscription IDs, resource groups, etc.)
- Predefined Azure built-in roles and custom roles

## Features

- ✅ Assign multiple roles to multiple users/groups across multiple scopes
- ✅ Uses Azure built-in role names (e.g., "Reader", "Contributor")
- ✅ Supports optional RBAC assignment conditions for predefined and custom roles
- ✅ Create custom role definitions with granular permissions
- ✅ Optional Azure PIM (JIT) eligible role assignments with activation policy
- ✅ Flexible scope definition (management groups, subscriptions, resource groups, resources)
- ✅ Returns detailed output of all created assignments

## Usage

### Basic Example

```hcl
module "cloud_access_role" {
  source = "github.com/fourcee/terraform-azure-cloud-access-role"

  group_ids = [
    "12345678-1234-1234-1234-123456789abc",
    "87654321-4321-4321-4321-cba987654321"
  ]

  user_ids = [
    "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000",
    "/subscriptions/11111111-1111-1111-1111-111111111111"
  ]

  predefined_roles = [
    {
      name = "Reader"
    },
    {
      name = "Contributor"
    }
  ]
}
```

### Management Group Scope Example

```hcl
module "cloud_access_role_mg" {
  source = "github.com/fourcee/terraform-azure-cloud-access-role"

  group_ids = [
    "12345678-1234-1234-1234-123456789abc"
  ]

  user_ids = [
    "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  ]

  scopes = [
    "/providers/Microsoft.Management/managementGroups/my-management-group"
  ]

  predefined_roles = [
    {
      name = "Reader"
    }
  ]
}
```

### Resource Group Scope Example

```hcl
module "cloud_access_role_rg" {
  source = "github.com/fourcee/terraform-azure-cloud-access-role"

  group_ids = [
    "12345678-1234-1234-1234-123456789abc"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group"
  ]

  predefined_roles = [
    {
      name = "Virtual Machine Contributor"
    }
  ]
}
```

### Custom Role Example

```hcl
module "cloud_access_role_custom" {
  source = "github.com/fourcee/terraform-azure-cloud-access-role"

  group_ids = [
    "12345678-1234-1234-1234-123456789abc"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000"
  ]

  predefined_roles = [
    {
      name = "Reader"
    }
  ]

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
        "/subscriptions/00000000-0000-0000-0000-000000000000"
      ]
      condition         = "@Resource[Microsoft.Compute/virtualMachines:Name] StringLike 'vm-*'"
      condition_version = "2.0"
    }
  ]
}
```

### JIT (PIM Eligible) Example

```hcl
module "cloud_access_role_jit" {
  source = "github.com/fourcee/terraform-azure-cloud-access-role"

  group_ids = [
    "12345678-1234-1234-1234-123456789abc"
  ]

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000"
  ]

  predefined_roles = [
    {
      name              = "Contributor"
      condition         = "@Resource[Microsoft.Authorization/roleAssignments:PrincipalType] StringEqualsIgnoreCase 'Group'"
      condition_version = "2.0"
    }
  ]

  jit_enabled                         = true
  jit_require_justification           = true
  jit_approval_group_ids              = ["22222222-2222-2222-2222-222222222222"] # Set [] for no approval workflow
  jit_approval_user_ids               = ["33333333-3333-3333-3333-333333333333"] # Optional additional approvers
  jit_max_activation_duration_seconds = 3600
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.64.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.64.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| group_ids | List of Entra (Azure AD) group object IDs to assign access to | `list(string)` | no |
| user_ids | List of Entra (Azure AD) user object IDs to assign access to | `list(string)` | no |
| scopes | List of scopes where the role assignments will be created (e.g., '/subscriptions/{subscription-id}' or '/providers/Microsoft.Management/managementGroups/{management-group-id}') | `list(string)` | yes |
| predefined_roles | List of Azure built-in role assignments to create, each with optional condition settings | `list(object)` | no |
| custom_roles | List of custom role definitions to create and include as part of the assignment | `list(object)` | no |
| jit_enabled | Enable Azure PIM eligible role assignments instead of regular role assignments | `bool` | no |
| jit_require_justification | Require justification when activating a JIT role assignment | `bool` | no |
| jit_approval_group_ids | List of Entra group object IDs used as JIT activation approvers | `list(string)` | no |
| jit_approval_user_ids | List of Entra user object IDs used as JIT activation approvers | `list(string)` | no |
| jit_max_activation_duration_seconds | Maximum JIT activation duration in seconds (required when jit_enabled = true) | `number` | no |

### Predefined Roles Object

The `predefined_roles` variable accepts a list of objects with the following fields:

| Field | Description | Type |
|-------|-------------|------|
| name | Azure built-in role name to assign | `string` |
| condition | Optional RBAC condition expression for the assignment | `string` |
| condition_version | Optional RBAC condition version (for example `2.0`) | `string` |

### Custom Roles Object

The `custom_roles` variable accepts a list of objects with the following fields:

| Field | Description | Type |
|-------|-------------|------|
| name | The unique name for the custom role | `string` |
| display_name | The display name for the custom role | `string` |
| description | A description of the custom role | `string` |
| actions | List of allowed actions for the role | `list(string)` |
| not_actions | List of denied actions for the role | `list(string)` |
| data_actions | List of allowed data actions for the role | `list(string)` |
| not_data_actions | List of denied data actions for the role | `list(string)` |
| assignable_scopes | List of scopes where the role can be assigned | `list(string)` |
| condition | Optional RBAC condition expression for assignments created from this custom role | `string` |
| condition_version | Optional RBAC condition version (for example `2.0`) | `string` |

## Outputs

| Name | Description |
|------|-------------|
| role_assignment_ids | Map of role assignment IDs, keyed by 'principal_type::principal_id::scope::role_name' |
| role_assignments | Map of role assignment details including id, principal_id, role_name, and scope |
| custom_role_definition_ids | Map of custom role definition IDs, keyed by role name |
| custom_role_definitions | Map of custom role definition details |
| pim_eligible_role_assignment_ids | Map of PIM eligible role assignment IDs, keyed by 'group_id::scope::role_name' |
| role_management_policy_ids | Map of role management policy IDs, keyed by 'scope::role_name' |

## Notes

- The module creates N×M×R role assignments where:
  - N = number of principal IDs (`group_ids` + `user_ids`)
  - M = number of scopes
  - R = number of role definitions to assign (`predefined_roles` + `custom_roles`)
- When `jit_enabled = true`, the module creates:
  - `azurerm_role_management_policy` for each `scope::role_name`
  - `azurerm_pim_eligible_role_assignment` for each `principal_type::principal_id::scope::role_name`
  - no regular `azurerm_role_assignment` resources
- If both `jit_approval_group_ids` and `jit_approval_user_ids` are empty, no JIT approval workflow is configured
- At least one principal must be provided using `group_ids` and/or `user_ids`
- Group IDs and user IDs must be valid Entra object IDs
- Scopes must be in the format: `/subscriptions/{id}`, `/subscriptions/{id}/resourceGroups/{name}`, `/providers/Microsoft.Management/managementGroups/{id}`, or more specific resource paths
- Predefined role names must be valid Azure built-in role names
- Custom roles defined in `custom_roles` are automatically created and assigned to the specified principals and scopes
- When condition settings are supplied for a role, both `condition` and `condition_version` must be set

## Common Azure Built-in Roles

- Reader
- Contributor
- Owner
- User Access Administrator
- Virtual Machine Contributor
- Storage Account Contributor
- Network Contributor
- Security Admin

For a complete list, see: [Azure built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)

## License

MIT
