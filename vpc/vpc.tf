resource "aws_vpc" "apci_main_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-vpc"
  })
}

# CREAT INTERNET GATEWAY .....................................................................................................................

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.apci_main_vpc.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-iwg"
  })
}

# CREAT FRONTEND SUBNET.....................................................................................................................

resource "aws_subnet" "apci_frontend_subnet_az_1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.frontend_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend-subnet-az-1a"
  }
}
resource "aws_subnet" "apci_frontend_subnet_az_1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.frontend_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend-subnet-az-1b"
  }
}

# CREAT BACKEND SUBNET.....................................................................................................................

resource "aws_subnet" "apci_backend_subnet_az_1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend-subnet-az-1a"
  }
}
resource "aws_subnet" "apci_backend_subnet_az_1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend-subnet-az-1b"
  }
}

# CREAT DB SUBNET.....................................................................................................................

resource "aws_subnet" "apci_db_subnet_az_1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.db_cidr_block[0]
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1a"
  }
}
resource "aws_subnet" "apci_db_subnet_az_1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.db_cidr_block[1]
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1b"
  }
}

# PUBLIC ROUTE TABLE ......................................................................................................
resource "aws_route_table" "apci_public_rt" {
  vpc_id = aws_vpc.apci_main_vpc.id
  route {
    cidr_block =  "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_rt"
  })
}

# PUBLIC ROUTE TABLE ASSOCIATION......................................................................................................
resource "aws_route_table_association" "apci_public_rta1" {
  route_table_id = aws_route_table.apci_public_rt.id
  subnet_id = aws_subnet.apci_frontend_subnet_az_1a.id
}

resource "aws_route_table_association" "apci_public_rta2" {
  route_table_id = aws_route_table.apci_public_rt.id
  subnet_id = aws_subnet.apci_frontend_subnet_az_1b.id
}

# ELASTIC IP AZ1A......................................................................................................
resource "aws_eip" "apci_nat_eip_az1a" {
  domain = "vpc"
   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az1a"
  })
}

# NAT GATEWAY AZ1A......................................................................................................
resource "aws_nat_gateway" "apci_nat_gateway_az1a" {
  allocation_id = aws_eip.apci_nat_eip_az1a.id
  subnet_id = aws_subnet.apci_frontend_subnet_az_1a.id
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gateway_az1a"
  })
  depends_on = [aws_subnet.apci_frontend_subnet_az_1a]
}

# PRIVATE ROUTE TABLE ASSOCIATION  AZ1A......................................................................................................
resource "aws_route_table" "apci_private_rt_az1a" {
  vpc_id = aws_vpc.apci_main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.apci_nat_gateway_az1a.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az1a"
  })
}

# PRIVATE ROUTE TABLE ASSOCIATION  FOR AZ1A......................................................................................................
resource "aws_route_table_association" "apci_private_rt_az1a_a1" {
  route_table_id = aws_route_table.apci_private_rt_az1a.id
  subnet_id = aws_subnet.apci_backend_subnet_az_1a.id
  depends_on = [aws_nat_gateway.apci_nat_gateway_az1a]
}

resource "aws_route_table_association" "apci_private_rt_az1a_a2" {
  route_table_id = aws_route_table.apci_private_rt_az1a.id
  subnet_id = aws_subnet.apci_db_subnet_az_1a.id
  depends_on = [aws_nat_gateway.apci_nat_gateway_az1a]
}


# ELASTIC IP AZ1B......................................................................................................
resource "aws_eip" "apci_nat_eip_az1b" {
  domain = "vpc"
   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az1a"
  })
}

# NAT GATEWAY AZ1B......................................................................................................
resource "aws_nat_gateway" "apci_nat_gateway_az1b" {
  allocation_id = aws_eip.apci_nat_eip_az1b.id
  subnet_id = aws_subnet.apci_frontend_subnet_az_1b.id
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gateway_az1b"
  })
  depends_on = [aws_subnet.apci_frontend_subnet_az_1b]
}

# PRIVATE ROUTE TABLE AZ1B......................................................................................................
resource "aws_route_table" "apci_private_rt_az1b" {
  vpc_id = aws_vpc.apci_main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.apci_nat_gateway_az1b.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az1b"
  })
}

# PRIVATE ROUTE TABLE ASSOCIATION  FOR AZ1B......................................................................................................
resource "aws_route_table_association" "apci_private_rt_az1b_a1" {
  route_table_id = aws_route_table.apci_private_rt_az1b.id
  subnet_id = aws_subnet.apci_backend_subnet_az_1b.id
  depends_on = [aws_nat_gateway.apci_nat_gateway_az1b]
}

resource "aws_route_table_association" "apci_private_rt_az1b_a2" {
  route_table_id = aws_route_table.apci_private_rt_az1b.id
  subnet_id = aws_subnet.apci_db_subnet_az_1b.id
  depends_on = [aws_nat_gateway.apci_nat_gateway_az1b]
}
