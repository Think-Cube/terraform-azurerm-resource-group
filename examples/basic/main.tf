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

module "resource_group" {
  # Outside this repository:
  # source = "git::https://github.com/Think-Cube/terraform-azurerm-resource-group.git?ref=v1.0.0"
  source = "../.."

  name     = "rg-example-weu"
  location = var.location
}
