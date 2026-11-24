output "id" {
  description = "ID of the resource group."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region of the resource group."
  value       = azurerm_resource_group.this.location
}

output "resource" {
  description = "The whole `azurerm_resource_group` resource, for attributes without a dedicated output."
  value       = azurerm_resource_group.this
}

output "role_assignment_ids" {
  description = "IDs of the role assignments, by the keys of `role_assignments`."
  value       = { for key, assignment in azurerm_role_assignment.this : key => assignment.id }
}
