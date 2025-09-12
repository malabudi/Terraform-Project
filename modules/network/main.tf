resource "aws_vpc" "main" {
    cidr_block              = var.vpc_cider

    tags = {
        Name                = "${var.environment}-vpc"
    }

    enable_dns_support      = true
    enable_dns_hostnames    = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name    = "${var.environment}-igw"
    }
}

// NAT Gateway
resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name    = "${var.environment}-nat-eip"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id   = aws_eip.nat.id
    subnet_id       = aws_subnet.public_zone_1.id // NAT Gateway must be in a public subnet (just one of them)

    tags = {
        Name    = "${var.environment}-nat-gateway"
    }

    depends_on      = [aws_internet_gateway.igw]
}

// Route Tables
resource "aws_route_table" "public" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name    = "${var.environment}-public-rtb"
    }

    route {
        cidr_block              = "0.0.0.0/0"
        gateway_id              = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public_zone_1" {
    subnet_id      = aws_subnet.public_zone_1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zone_2" {
    subnet_id      = aws_subnet.public_zone_2.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name    = "${var.environment}-private-rtb"
    }

    route {
        cidr_block              = "0.0.0.0/0"
        nat_gateway_id          = aws_nat_gateway.nat.id
    }
}

resource "aws_route_table_association" "private_zone_1" {
    subnet_id      = aws_subnet.private_zone_1.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_zone_2" {
    subnet_id      = aws_subnet.private_zone_2.id
    route_table_id = aws_route_table.private.id
}

// Subnets - Public
resource "aws_subnet" "public_zone_1" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.0.0/19"
    availability_zone       = "us-east-2a"
    map_public_ip_on_launch = true

    tags = {
        Name                = "${var.environment}-public-subnet-us-east-2a"
    }
}

resource "aws_subnet" "public_zone_2" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.32.0/19"
    availability_zone       = "us-east-2b"
    map_public_ip_on_launch = true

    tags = {
        Name                = "${var.environment}-public-subnet-us-east-2b"
    }
}

// Subnets - Private
resource "aws_subnet" "private_zone_1" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.64.0/19"
    availability_zone       = "us-east-2a"

    tags = {
        Name                = "${var.environment}-private-subnet-us-east-2a"
    }
}

resource "aws_subnet" "private_zone_2" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.96.0/19"
    availability_zone       = "us-east-2b"

    tags = {
        Name                = "${var.environment}-private-subnet-us-east-2b"
    }
}

// Subnets - Isolated (For database and secure services)
resource "aws_subnet" "isolated_zone_1" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.128.0/19"
    availability_zone       = "us-east-2a"

    tags = {
        Name                = "${var.environment}-isolated-subnet-us-east-2a"
    }
}

resource "aws_subnet" "isolated_zone_2" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.160.0/19"
    availability_zone       = "us-east-2b"

    tags = {
        Name                = "${var.environment}-isolated-subnet-us-east-2b"
    }
}