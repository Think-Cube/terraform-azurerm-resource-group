mock_provider "azurerm" {}

variables {
  name     = "rg-test-weu"
  location = "westeurope"
}

run "defaults" {
  command = plan

  assert {
    condition     = azurerm_resource_group.this.name == "rg-test-weu" && azurerm_resource_group.this.location == "westeurope"
    error_message = "The resource group must use the given name and location."
  }

  assert {
    condition     = length(azurerm_management_lock.this) == 0 && length(azurerm_role_assignment.this) == 0
    error_message = "No lock or role assignment may be created by default."
  }
}

run "lock_and_role_assignments" {
  command = plan

  variables {
    tags = { environment = "test" }
    lock = { kind = "CanNotDelete" }
    role_assignments = {
      readers = {
        role_definition_id_or_name = "Reader"
        principal_id               = "00000000-0000-0000-0000-000000000001"
        principal_type             = "Group"
      }
      custom = {
        role_definition_id_or_name = "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
        principal_id               = "00000000-0000-0000-0000-000000000002"
      }
    }
  }

  assert {
    condition     = azurerm_resource_group.this.tags["environment"] == "test"
    error_message = "Tags must be applied."
  }

  assert {
    condition     = azurerm_management_lock.this[0].lock_level == "CanNotDelete" && azurerm_management_lock.this[0].name == "lock-CanNotDelete"
    error_message = "The lock must use the given kind and the default name."
  }

  assert {
    condition     = azurerm_role_assignment.this["readers"].role_definition_name == "Reader" && azurerm_role_assignment.this["readers"].principal_type == "Group"
    error_message = "A role name must be passed as role_definition_name."
  }

  assert {
    condition     = azurerm_role_assignment.this["custom"].role_definition_id == "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    error_message = "A role definition ID must be passed as role_definition_id."
  }
}

run "rejects_invalid_name" {
  command = plan

  variables {
    name = "rg-ends-with-period."
  }

  expect_failures = [var.name]
}

run "rejects_invalid_lock" {
  command = plan

  variables {
    lock = { kind = "DoNotDelete" }
  }

  expect_failures = [var.lock]
}

run "rejects_invalid_principal_type" {
  command = plan

  variables {
    role_assignments = {
      device = {
        role_definition_id_or_name = "Reader"
        principal_id               = "00000000-0000-0000-0000-000000000001"
        principal_type             = "Device"
      }
    }
  }

  expect_failures = [var.role_assignments]
}
