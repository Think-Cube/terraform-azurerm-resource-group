terraform {
  required_version = ">= 1.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "resource_group" {
  # Outside this repository:
  # source = "git::https://github.com/Think-Cube/terraform-azurerm-resource-group.git?ref=v1.0.0"
  source = "../.."

  name     = "rg-example-prod-weu"
  location = "westeurope"

  tags = {
    environment = "production"
    owner       = "platform-team"
  }

  lock = {
    kind  = "CanNotDelete"
    notes = "Production resources. Remove the lock in code before deleting the group."
  }

  role_assignments = {
    deployer_reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
}

output "resource_group_id" {
  description = "ID of the resource group."
  value       = module.resource_group.id
}

output "role_assignment_ids" {
  description = "IDs of the role assignments."
  value       = module.resource_group.role_assignment_ids
}
