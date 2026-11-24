output "resource_group_id" {
  description = "ID of the resource group."
  value       = module.resource_group.id
}

output "role_assignment_ids" {
  description = "IDs of the role assignments, by key."
  value       = module.resource_group.role_assignment_ids
}
