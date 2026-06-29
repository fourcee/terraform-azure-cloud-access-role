# Complete Example

This example demonstrates how to use the terraform-azure-cloud-access-role module to assign multiple roles to Entra groups, service principals, and managed identities across multiple Azure subscriptions.

## What This Example Does

This example creates role assignments with the following configuration:
- **Groups**: 2 Entra (Azure AD) groups
- **Workload identities**: 1 service principal and 1 managed identity
- **Scopes**: 2 Azure subscriptions
- **Roles**: 2 roles (Reader and Contributor)
- **Total assignments**: 4 × 2 × 2 = 16 role assignments

## Prerequisites

1. Azure subscription(s)
2. Azure CLI authenticated or Service Principal credentials
3. Entra (Azure AD) groups and workload identities already created
4. Permissions to create role assignments in the target scopes

## Usage

1. Update the `main.tf` file with your actual values:
   - Replace `group_ids` with your Entra group object IDs
   - Replace `service_principals` with your service principal and/or managed identity object IDs
   - Replace `scopes` with your subscription IDs
   - Adjust `predefined_roles` (and optional role conditions) as needed

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Getting Group IDs

To find Entra group object IDs:

```bash
# Using Azure CLI
az ad group list --query "[].{displayName:displayName, objectId:id}" -o table

# For a specific group
az ad group show --group "Group Name" --query id -o tsv
```

## Getting Service Principal and Managed Identity IDs

To find service principal and managed identity object IDs:

```bash
# Using Azure CLI
az ad sp list --query "[].{displayName:displayName, objectId:id, appId:appId}" -o table

# For a specific service principal by application/client ID
az ad sp show --id "Application or client ID" --query "{displayName:displayName, objectId:id, appId:appId}" -o json
```

## Outputs

The example outputs:
- `role_assignments`: Detailed information about each role assignment
- `role_assignment_ids`: The Azure resource IDs of all created assignments

## Clean Up

To remove all role assignments created by this example:

```bash
terraform destroy
```
