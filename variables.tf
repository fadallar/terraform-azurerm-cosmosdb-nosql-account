variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region to use."
  type        = string
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
}

variable "stack" {
  description = "Project stack name."
  type        = string
}

##############################################

#variable "create_mode" {
#    description = "The creation mode for the CosmosDB Account. Possible values are Default and Restore. Changing this forces a new resource to be created."
#    type = string
#    default = "Default"  #Create_mode only works when backup.type is Continuous
#}

variable "default_identity_type" {
  description = "The default identity for accessing Key Vault. Possible values are FirstPartyIdentity, SystemAssignedIdentity, or must start with 'UserAssignedIdentity=' with the Identity ID concatenated."
  default     = null
  type        = string
  validation {
    condition     = try(contains(["FirstPartyIdentity", "SystemAssignedIdentity", regex("^UserAssignedIdentity=*")], var.default_identity_type), true)
    error_message = "Invalid variable: default_identity_type. Allowed values are FirstPartyIdentity, SystemAssignedIdentity, UserAssignedIdentity "
  }
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for this Cosmos DB account."
  type        = bool
  default     = false
}

variable "enable_free_tier" {
  description = "Enable free tier pricing option for this Cosmos DB account. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "enable_multiple_write_locations" {
  description = "Enable multiple write locations for this Cosmos DB account."
  type        = bool
  default     = false
}

variable "key_vault_key_id" {
  description = "A versionless Key Vault Key ID for CMK encryption. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "local_authentication_disabled" {
  description = "Disable local authentication and ensure only MSI and AAD can be used exclusively for authentication. Can be set only when using the SQL API."
  type        = bool
  default     = false
}

variable "geo_locations" {
  description = "List of map of geo locations and other properties to create primary and secodanry databases."
  type        = any
  default = [
    {
      geo_location      = "westeurope"
      failover_priority = 0
      zone_redundant    = false
    },
  ]
}

# https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/how-to-configure-capabilities#available-capabilities
variable "capabilities" {
  type        = list(string)
  description = <<EOD
Configures the capabilities to enable for this Cosmos DB account:
Possible values are
  # TBD 
EOD
  default     = []
}

variable "consistency_policy_level" {
  description = "Consistency policy level. Allowed values are `BoundedStaleness`, `Eventual`, `Session`, `Strong` or `ConsistentPrefix`"
  type        = string
  default     = "Strong"
  validation {
    condition     = try(contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_policy_level), true)
    error_message = "Invalid variable: ${var.consistency_policy_level}. Allowed values are `BoundedStaleness`, `Eventual`, `Session`, `Strong` or `ConsistentPrefix`"
  }
}

variable "consistency_policy_max_interval_in_seconds" {
  description = "When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day). Required when consistency_level is set to BoundedStaleness."
  type        = number
  default     = 5
  validation {
    condition     = var.consistency_policy_max_interval_in_seconds >= 5 && var.consistency_policy_max_interval_in_seconds <= 86400
    error_message = "Invalid variable: ${var.consistency_policy_max_interval_in_seconds}. Allowed range is 5-86400."
  }

}

variable "consistency_policy_max_staleness_prefix" {
  description = "When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness."
  type        = number
  default     = 100
  validation {
    condition     = var.consistency_policy_max_staleness_prefix >= 10 && var.consistency_policy_max_staleness_prefix <= 2147483647
    error_message = "Invalid variable: ${var.consistency_policy_max_staleness_prefix}. Allowed range is 10-2147483647."
  }
}

variable "backup" {
  description = "Backup block with type (Continuous / Periodic), interval_in_minutes and retention_in_hours keys"
  type = object({
    type                = string
    interval_in_minutes = number
    retention_in_hours  = number
  })
  default = {
    type                = "Periodic"
    interval_in_minutes = 3 * 60
    retention_in_hours  = 7 * 24
  }
}

variable "analytical_storage_enabled" {
  description = "Enable Analytical Storage option for this Cosmos DB account. Defaults to `false`. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "analytical_storage_type" {
  description = "The schema type of the Analytical Storage for this Cosmos DB account. Possible values are `FullFidelity` and `WellDefined`."
  type        = string
  default     = null

  validation {
    condition     = try(contains(["FullFidelity", "WellDefined"], var.analytical_storage_type), true)
    error_message = "The `analytical_storage_type` value must be valid. Possible values are `FullFidelity` and `WellDefined`."
  }
}

variable "identity_type" {
  description = "CosmosDB managed identity type. Possible values for type are: `UserAssigned`, `SystemAssigned` and `SystemAssigned, UserAssigned`."
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = try(contains(["UserAssigned", "SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type), true)
    error_message = "Invalid variable: ${var.identity_type}. Allowed values are  `UserAssigned`, `SystemAssigned` and `SystemAssigned, UserAssigned`."
  }
}

variable "identity_ids" {
  description = "CosmosDB identity IDs. Specifies a list of User Assigned Managed Identity IDs to be assigned to this Cosmos Account. To be used when identity_type is UserAssigned"
  type        = list(string)
  default     = null
}

variable "total_throughput_limit" {
  description = "The total throughput limit imposed on this Cosmos DB account (RU/s). Possible values are at least -1. -1 means no limit."
  type        = number
  default     = null
}
