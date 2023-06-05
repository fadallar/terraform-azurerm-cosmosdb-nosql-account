resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = local.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = merge(var.default_tags, var.extra_tags)
  offer_type          = "Standard" ## Only options available

  enable_multiple_write_locations = var.enable_multiple_write_locations

  key_vault_key_id = var.key_vault_key_id

  default_identity_type = var.default_identity_type
  kind                  = "GlobalDocumentDB"

  # Hardcoded to false to resolve CKV_AZURE_132: 
  # "Ensure Cosmos DB does not allow privileged escalation by restricting management plane changes"
  access_key_metadata_writes_enabled = false
  local_authentication_disabled      = var.local_authentication_disabled

  dynamic "analytical_storage" {
    for_each = var.analytical_storage_type != null ? ["enabled"] : []
    content {
      schema_type = var.analytical_storage_type
    }
  }

  dynamic "capacity" {
    for_each = var.total_throughput_limit != null ? ["enabled"] : []
    content {
      total_throughput_limit = var.total_throughput_limit
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? ["enabled"] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  consistency_policy {
    consistency_level       = var.consistency_policy_level
    max_interval_in_seconds = var.consistency_policy_max_interval_in_seconds
    max_staleness_prefix    = var.consistency_policy_max_staleness_prefix
  }

  dynamic "geo_location" {
    for_each = var.geo_locations
    content {
      location          = geo_location.value["geo_location"]
      failover_priority = geo_location.value["failover_priority"]
      zone_redundant    = geo_location.value["zone_redundant"]
    }
  }

  enable_free_tier = var.enable_free_tier

  analytical_storage_enabled = var.analytical_storage_enabled

  enable_automatic_failover = var.enable_automatic_failover


  #------------- Network and Filtering
  # Hardcoded to false to resolve CKV_AZURE_99: "Ensure Cosmos DB accounts have restricted access"
  public_network_access_enabled         = var.public_network_access_enabled
  is_virtual_network_filter_enabled     = var.is_virtual_network_filter_enabled
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  ip_range_filter                       = join(",", var.allowed_cidrs)
  network_acl_bypass_ids                = var.network_acl_bypass_ids

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rule != null ? toset(var.virtual_network_rule) : []
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }

  #------------------------------------

  dynamic "capabilities" {
    for_each = toset(var.capabilities)
    content {
      name = capabilities.key
    }
  }

  dynamic "backup" {
    for_each = var.backup != null ? ["enabled"] : []
    content {
      type                = lookup(var.backup, "type", null)
      interval_in_minutes = lookup(var.backup, "interval_in_minutes", null)
      retention_in_hours  = lookup(var.backup, "retention_in_hours", null)
    }
  }


  lifecycle {
    precondition {
      condition     = var.public_network_access_enabled || (var.allowed_cidrs != null && var.allowed_cidrs != "")
      error_message = "allowed_cidrs cannot be empty or null if public_network_access is true."
    }
  }
}
