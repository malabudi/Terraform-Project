locals {
    // Resorce names
    virtual_network_name = "myTF-vnet"
    network_security_group_name = "myTF-nsg"
    routing_table_name = "myTF-rt"

    // Network configuration
    availability_zones = ["1", "2"]
    address_space = "10.0.0.0/16"
    routing_table_cidr = "0.0.0.0/0"

    // Dynamically create subnets based on availability zones (az may be removed later)
    public_subnets = {
        for i , az in local.availability_zones :
        "public-subnet-${i + 1}" => {
            name       = "myTF-public-subnet-${i + 1}"
            cidr_block = cidrsubnet(local.address_space, 3, i)
        }
    }

    private_subnets = {
        for i , az in local.availability_zones :
        "private-subnet-${i + 1}" => {
            name       = "myTF-private-subnet-${i + 1}"
            cidr_block = cidrsubnet(local.address_space, 3, i + length(local.availability_zones))
        }
    }

    ingress_rules = {
        22 = "63.10.10.10/32"   # SSH from specific IP
        80 = "0.0.0.0/0"        # HTTP from anywhere
    }
}