# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                  = local.virtual_network_name
  address_space         = [local.address_space]
  location              = var.location
  resource_group_name   = var.resource_group_name

  tags = {
    environment = var.environment
  }
}

# Subnets
resource "azurerm_subnet" "public_subnets" {
  for_each             = local.public_subnets

  name                 = "${var.environment}-public-subnet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.cidr_block]
}

resource "azurerm_subnet" "private_subnets" {
  for_each             = local.private_subnets

  name                 = "${var.environment}-private-subnet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.cidr_block]
}

# Public IP for the NAT Gateway
resource "azurerm_public_ip" "nat_gw_ip" {
  name                = "${var.environment}-nat-gateway-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NAT Gateway
resource "azurerm_nat_gateway" "nat_gw" {
  name                = "${var.environment}-nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gw_ip_association" {
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat_gw_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "private_subnet_nat_association" {
  for_each = azurerm_subnet.private_subnets

  subnet_id     = each.value.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = local.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = local.ingress_rules
    content {
      name                       = "Allow-${security_rule.key}"
      priority                   = 100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.key
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }
}

# Associate NSG to public subnets
resource "azurerm_subnet_network_security_group_association" "public_subnet_nsg_association" {
  for_each = azurerm_subnet.public_subnets

  subnet_id = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Define route table
resource "azurerm_route_table" "public_rt" {
    name                = local.routing_table_name
    location            = var.location
    resource_group_name = var.resource_group_name
    
    route {
        name                   = "default-route"
        address_prefix         = local.routing_table_cidr
        next_hop_type          = "Internet"
    }
}

resource "azurerm_subnet_route_table_association" "public_subnet_rt_association" {
    for_each = azurerm_subnet.public_subnets

    subnet_id      = each.value.id
    route_table_id = azurerm_route_table.public_rt.id
}