resource "aws_vpc" "main" {
    cidr_block              = local.vpc_cidr

    tags = {
        Name                = "${local.env}-vpc"
    }

    enable_dns_support      = true
    enable_dns_hostnames    = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name    = "${local.env}-igw"
    }
}

resource "aws_eip" "nat" {
    domain      = "vpc"

    tags = {
        Name    = "${local.env}-nat-eip"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id   = aws_eip.nat.id
    subnet_id       = aws_subnet.public[keys(aws_subnet.public)[0]].id

    tags = {
        Name        = "${local.env}-nat-gateway"
    }

    depends_on      = [aws_internet_gateway.igw]
}

resource "aws_security_group" "web_sg" {
    vpc_id      = aws_vpc.main.id
    name        = "${local.env}-web-sg"
    description = "Security group for web servers"

    dynamic "ingress" {
        for_each = local.ingress_rules
        
        content {
            from_port   = ingress.key
            to_port     = ingress.key
            protocol    = "tcp"
            cidr_blocks = [ingress.value]
        }
    }
}

// Route Tables
resource "aws_route_table" "public" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name    = "${local.env}-public-rtb"
    }

    route {
        cidr_block              = local.rtb_cider
        gateway_id              = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public" {
    for_each       = local.public_subnets // Create an association for each public subnet

    subnet_id      = aws_subnet.public[each.key].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name    = "${local.env}-private-rtb"
    }

    route {
        cidr_block              = local.rtb_cider
        nat_gateway_id          = aws_nat_gateway.nat.id
    }
}

resource "aws_route_table_association" "private" {
    for_each        = local.private_subnets // Create an association for each private subnet map entry

    subnet_id       = aws_subnet.private[each.key].id
    route_table_id  = aws_route_table.private.id
}

// Subnets
resource "aws_subnet" "public" {
    for_each                = local.public_subnets

    vpc_id                  = aws_vpc.main.id
    cidr_block              = each.value.cidr
    availability_zone       = each.value.az
    map_public_ip_on_launch = true

    tags = {
        Name                = "${local.env}-public-subnet-${each.value.az}"
    }
}

resource "aws_subnet" "private" {
    for_each                = local.private_subnets

    vpc_id                  = aws_vpc.main.id
    cidr_block              = each.value.cidr
    availability_zone       = each.value.az

    tags = {
        Name                = "${local.env}-private-subnet-${each.value.az}"
    }
}

resource "aws_subnet" "isolated_zone_1" {
    count                   = local.create_isolated_subnets ? 1 : 0 // Create isolated subnets only if the flag is true

    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.128.0/19"
    availability_zone       = "us-east-2a"

    tags = {
        Name                = "${local.env}-isolated-subnet-us-east-2a"
    }
}

resource "aws_subnet" "isolated_zone_2" {
    count                   = local.create_isolated_subnets ? 1 : 0

    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.160.0/19"
    availability_zone       = "us-east-2b"

    tags = {
        Name                = "${local.env}-isolated-subnet-us-east-2b"
    }
}