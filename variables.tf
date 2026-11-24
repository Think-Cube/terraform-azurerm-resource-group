variable "name" {
  description = "Name of the resource group. Changing it creates a new resource group."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[-\\w.()]{0,89}[-\\w()]$", var.name))
    error_message = "The name must be 1-90 letters, digits, underscores, hyphens, periods or parentheses, and must not end with a period."
  }
}

variable "location" {
  description = "Azure region of the resource group, such as `westeurope`. Changing it creates a new resource group."
  type        = string
  nullable    = false
}

variable "managed_by" {
  description = "ID of the resource that manages this resource group, if any."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags assigned to the resource group. Resources in the group do not inherit them."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "lock" {
  description = <<-EOT
    Management lock on the resource group:
    - `kind`: `CanNotDelete` or `ReadOnly`.
    - `name`: lock name; defaults to `lock-<kind>`.
    - `notes`: why the lock exists.
  EOT
  type = object({
    kind  = string
    name  = optional(string)
    notes = optional(string)
  })
  default = null

  validation {
    condition     = var.lock == null || contains(["CanNotDelete", "ReadOnly"], try(var.lock.kind, ""))
    error_message = "lock.kind must be CanNotDelete or ReadOnly."
  }
}

variable "role_assignments" {
  description = <<-EOT
    Role assignments on the resource group, keyed by any name that stays stable:
    - `role_definition_id_or_name`: built-in role name such as `Reader`, or a role definition ID starting with `/`.
    - `principal_id`: object ID of the user, group, service principal or managed identity.
    - `principal_type`: `User`, `Group` or `ServicePrincipal`. Set it for principals created in the same run to avoid replication delays.
    - `description`, `condition`, `condition_version`: optional description and ABAC condition.
    - `skip_service_principal_aad_check`: skip the Entra ID check for a service principal created in the same run.
    - `delegated_managed_identity_resource_id`: managed identity for cross-tenant scenarios.
  EOT
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    principal_type                         = optional(string)
    description                            = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
    delegated_managed_identity_resource_id = optional(string)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for assignment in values(var.role_assignments) :
      assignment.principal_type == null || contains(["User", "Group", "ServicePrincipal"], coalesce(assignment.principal_type, "-"))
    ])
    error_message = "principal_type must be User, Group or ServicePrincipal."
  }
}
