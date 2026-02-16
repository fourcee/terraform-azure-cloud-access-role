# Terraform Azure Cloud Access Role

Terraform module for creating Azure IAM role assignments to Entra (Azure AD) groups across multiple scopes and roles.

## Overview

This module simplifies the process of assigning Azure roles to Entra groups by automatically creating role assignments for all combinations of:
- Entra group IDs (principals)
- Scopes (subscription IDs, resource groups, etc.)
- Role names (Azure built-in or custom roles)

## Features

- ✅ Assign multiple roles to multiple groups across multiple scopes
- ✅ Uses Azure built-in role names (e.g., "Reader", "Contributor")
- ✅ Supports custom role names
- ✅ Create custom role definitions with granular permissions
- ✅ Flexible scope definition (subscriptions, resource groups, resources)
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

  scopes = [
    "/subscriptions/00000000-0000-0000-0000-000000000000",
    "/subscriptions/11111111-1111-1111-1111-111111111111"
  ]

  role_names = [
    "Reader",
    "Contributor"
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

  role_names = [
    "Virtual Machine Contributor"
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

  role_names = [
    "Reader"
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
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| group_ids | List of Entra (Azure AD) group object IDs to assign access to | `list(string)` | yes |
| scopes | List of scopes where the role assignments will be created (e.g., subscription IDs in format '/subscriptions/{subscription-id}') | `list(string)` | yes |
| role_names | List of Azure built-in or custom role names to assign | `list(string)` | yes |
| custom_roles | List of custom role definitions to create and include as part of the assignment | `list(object)` | no |

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

## Outputs

| Name | Description |
|------|-------------|
| role_assignment_ids | Map of role assignment IDs, keyed by 'group_id::scope::role_name' |
| role_assignments | Map of role assignment details including id, principal_id, role_name, and scope |
| custom_role_definition_ids | Map of custom role definition IDs, keyed by role name |
| custom_role_definitions | Map of custom role definition details |

## Notes

- The module creates N×M×R role assignments where:
  - N = number of group IDs
  - M = number of scopes
  - R = number of role names (built-in + custom)
- Group IDs must be valid Entra (Azure AD) group object IDs
- Scopes must be in the format: `/subscriptions/{id}` or `/subscriptions/{id}/resourceGroups/{name}` or more specific resource paths
- Role names must be valid Azure built-in or custom role names
- Custom roles defined in `custom_roles` are automatically created and assigned to the specified groups and scopes

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
