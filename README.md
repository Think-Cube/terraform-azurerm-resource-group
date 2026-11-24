# terraform-azurerm-resource-group

[![CI](https://github.com/Think-Cube/terraform-azurerm-resource-group/actions/workflows/module.yml/badge.svg)](https://github.com/Think-Cube/terraform-azurerm-resource-group/actions/workflows/module.yml)
[![Release](https://img.shields.io/github/v/release/Think-Cube/terraform-azurerm-resource-group)](https://github.com/Think-Cube/terraform-azurerm-resource-group/releases)
[![License](https://img.shields.io/github/license/Think-Cube/terraform-azurerm-resource-group)](LICENSE)

Terraform module for an Azure resource group, with an optional management lock and role assignments.

## Usage

```hcl
module "resource_group" {
  source = "git::https://github.com/Think-Cube/terraform-azurerm-resource-group.git?ref=v1.0.0"

  name     = "rg-app-prod-weu"
  location = "westeurope"

  tags = {
    environment = "production"
  }

  lock = {
    kind = "CanNotDelete"
  }

  role_assignments = {
    app_team_reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = "00000000-0000-0000-0000-000000000000"
      principal_type             = "Group"
    }
  }
}
```

Pin `ref` to a release tag. Dependabot's `terraform` ecosystem proposes new releases of modules sourced this way.

The module does not configure the `azurerm` provider; configure it in your root module. A lock blocks `terraform destroy`, so remove `lock` and apply before deleting the group.

More in [examples](examples):

- [basic](examples/basic): the resource group alone.
- [complete](examples/complete): tags, a lock and a role assignment.

## Development

The module is tested with `terraform test` against a mocked `azurerm` provider, so no Azure subscription is needed:

```bash
terraform fmt -recursive
terraform init -backend=false
terraform test
terraform-docs .
```

Pull requests also run TFLint with the azurerm ruleset, a Trivy misconfiguration scan and the tests on the oldest and newest supported Terraform versions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14 |
| azurerm | >= 5.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 5.0, < 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Azure region of the resource group, such as `westeurope`. Changing it creates a new resource group. | `string` | n/a | yes |
| name | Name of the resource group. Changing it creates a new resource group. | `string` | n/a | yes |
| lock | Management lock on the resource group:<br>- `kind`: `CanNotDelete` or `ReadOnly`.<br>- `name`: lock name; defaults to `lock-<kind>`.<br>- `notes`: why the lock exists. | <pre>object({<br>    kind  = string<br>    name  = optional(string)<br>    notes = optional(string)<br>  })</pre> | `null` | no |
| managed_by | ID of the resource that manages this resource group, if any. | `string` | `null` | no |
| role_assignments | Role assignments on the resource group, keyed by any name that stays stable:<br>- `role_definition_id_or_name`: built-in role name such as `Reader`, or a role definition ID starting with `/`.<br>- `principal_id`: object ID of the user, group, service principal or managed identity.<br>- `principal_type`: `User`, `Group` or `ServicePrincipal`. Set it for principals created in the same run to avoid replication delays.<br>- `description`, `condition`, `condition_version`: optional description and ABAC condition.<br>- `skip_service_principal_aad_check`: skip the Entra ID check for a service principal created in the same run.<br>- `delegated_managed_identity_resource_id`: managed identity for cross-tenant scenarios. | <pre>map(object({<br>    role_definition_id_or_name             = string<br>    principal_id                           = string<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>    delegated_managed_identity_resource_id = optional(string)<br>  }))</pre> | `{}` | no |
| tags | Tags assigned to the resource group. Resources in the group do not inherit them. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the resource group. |
| location | Azure region of the resource group. |
| name | Name of the resource group. |
| resource | The whole `azurerm_resource_group` resource, for attributes without a dedicated output. |
| role_assignment_ids | IDs of the role assignments, by the keys of `role_assignments`. |
<!-- END_TF_DOCS -->

## License

This project is licensed under the [MIT License](LICENSE).
