##### public subnets #####
resource "aws_subnet" "maged-public-subnet-1a" {
  vpc_id                  = aws_vpc.maged-terraform-vpc.id
  cidr_block              = var.public-subnet-cidr-1a
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone-1a
  tags = {
    Name = "maged-public-subnet-1a"
  }
}
resource "aws_subnet" "maged-public-subnet-1b" {
  vpc_id                  = aws_vpc.maged-terraform-vpc.id
  cidr_block              = var.public-subnet-cidr-1b
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone-1b
  tags = {
    Name = "maged-public-subnet-1b"
  }
}

##### private subnets #####

resource "aws_subnet" "maged-private-subnet-1a" {
  vpc_id                  = aws_vpc.maged-terraform-vpc.id
  cidr_block              = var.private-subnet-cidr-1a
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone-1a
  tags = {
    Name = "maged-private-subnet-1a"
  }
}
