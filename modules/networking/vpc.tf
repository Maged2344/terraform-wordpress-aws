# create vpc
resource "aws_vpc" "maged-terraform-vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  tags = {
    Name = "maged-terraform-vpc"
  }
}

# create internet gateway
resource "aws_internet_gateway" "maged-terraform-gw" {
  vpc_id = aws_vpc.maged-terraform-vpc.id
  tags = {
    Name = "maged-terraform-gw"
  }
}

# create public route table
resource "aws_route_table" "maged-terraform-public-route" {
  vpc_id = aws_vpc.maged-terraform-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.maged-terraform-gw.id
  }
  tags = {
    Name = "maged-terraform-route-public"
  }
}

# create public-route-table-association
resource "aws_route_table_association" "maged-terraform-route-1a" {
  subnet_id      = aws_subnet.maged-public-subnet-1a.id
  route_table_id = aws_route_table.maged-terraform-public-route.id
}
resource "aws_route_table_association" "maged-terraform-route-1b" {
  subnet_id      = aws_subnet.maged-public-subnet-1b.id
  route_table_id = aws_route_table.maged-terraform-public-route.id
}

resource "aws_eip" "lb" {
  domain = "vpc"
}

resource "aws_nat_gateway" "maged-terraform-nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.maged-public-subnet-1a.id
  tags = {
    Name = "maged-terraform-nat"
  }

}
# create private route table

resource "aws_route_table" "maged-terraform-route-private" {
  vpc_id = aws_vpc.maged-terraform-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.maged-terraform-nat.id
  }
  tags = {
    Name = "maged-terraform-route-private"
  }
}

# create private route-table-association
resource "aws_route_table_association" "maged-terraform-route-private-1a" {
  subnet_id      = aws_subnet.maged-private-subnet-1a.id
  route_table_id = aws_route_table.maged-terraform-route-private.id
}
