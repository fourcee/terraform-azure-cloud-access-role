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

## Outputs

| Name | Description |
|------|-------------|
| role_assignment_ids | Map of role assignment IDs, keyed by 'group_id-scope-role_name' |
| role_assignments | Map of role assignment details including id, principal_id, role_name, and scope |

## Notes

- The module creates N×M×R role assignments where:
  - N = number of group IDs
  - M = number of scopes
  - R = number of role names
- Group IDs must be valid Entra (Azure AD) group object IDs
- Scopes must be in the format: `/subscriptions/{id}` or `/subscriptions/{id}/resourceGroups/{name}` or more specific resource paths
- Role names must be valid Azure built-in or custom role names

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
