resource "aws_instance" "private_ec2" {
  ami           = "ami-0c85a129039f55d5e" 
  instance_type = "t2.micro"             

  subnet_id = var.private_subnet_1a_id

  # Optional: Associate a private security group
  security_groups = [aws_security_group.mysql_sg.id]

  tags = {
    Name = "maged-terraform-database"
  }
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-security-group"
  description = "Security group for MySQL database"
  vpc_id      = var.vpc_id

  # Ingress Rule: Allow MySQL access
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with allowed CIDR block
  }

  # Egress Rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL-Security-Group"
  }
}
