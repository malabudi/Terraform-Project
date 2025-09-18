resource "azurerm_resource_group" "rsg" {
  name     = "myTF-rsg"
  location = var.location
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  environment         = var.environment
}
