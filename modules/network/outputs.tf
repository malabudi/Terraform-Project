output "nsg_id" {
	description = "Network Security Group ID"
	value       = azurerm_network_security_group.nsg.id
}

output "vnet_id" {
    description = "Virtual Network ID"
    value       = azurerm_virtual_network.vnet.id
}