
# 🚀 WordPress Terraform Project

This project uses **Terraform** to create an automated infrastructure with **WordPress**, a **MySQL** database, and **Auto Scaling** in AWS. It covers the creation of VPCs, launch templates, autoscaling groups, and using S3 as a backend for Terraform state management.

---

## 📋 Project Setup

### Step 1: Destroy Your Manually Created Resources 🗑️

Before starting, ensure you destroy any manually created resources like **Auto Scaling Groups** and associated instances, but **keep the custom WordPress image**.

1. Go to your AWS Console and manually delete the Auto Scaling Group and any EC2 instances that were part of it.
2. Make sure the custom WordPress image (AMI) is saved in your account for later use.

### Step 2: Create a Terraform Script ✨

The following Terraform configuration is divided into several tasks:

---

### A. **Create a VPC with 2 Subnets (Private and Public) 🌐**

The first part of the script will create a **VPC** with two subnets:
- One **public subnet** (for the load balancer and external resources)
- One **private subnet** (for the database and internal instances)

```hcl
resource "aws_vpc" "maged-terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "maged-terraform-vpc"
  }
}

resource "aws_subnet" "maged-public-subnet" {
  vpc_id = aws_vpc.maged-terraform-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "maged-private-subnet" {
  vpc_id = aws_vpc.maged-terraform-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}
```

---

### B. **Create a Launch Template Containing Your WordPress Image 🎨**

This part of the script creates a **launch template** using the custom WordPress image (AMI). 

```hcl
resource "aws_launch_template" "maged-wordpress-launch-template" {
  name = "maged-wordpress-launch-template"
  image_id = "ami-xxxxxx"  # Replace with your custom WordPress AMI
  instance_type = "t3.small"
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Commands to install WordPress and configure
    # (Including setting wp-config.php, nginx config, etc.)
  EOF)

  tags = {
    Name = "maged-wordpress-launch-template"
  }
}
```

---

### C. **Create an Auto Scaling Group with Scaling Policy 📈**

This step creates an **Auto Scaling Group** with 2 EC2 instances (`t3.small`) and adds a scaling policy that increases the number of instances if CPU usage exceeds 50%.

```hcl
resource "aws_autoscaling_group" "maged-wordpress-autoscaling" {
  name = "maged-wordpress-autoscaling"
  min_size = 1
  max_size = 5
  desired_capacity = 2
  vpc_zone_identifier = [aws_subnet.maged-public-subnet.id]

  launch_template {
    id = aws_launch_template.maged-wordpress-launch-template.id
  }

  health_check_type = "EC2"
  health_check_grace_period = 200

  tag {
    key = "Name"
    value = "maged-wordpress-instance"
    propagate_at_launch = true
  }

  scaling_policies {
    name = "scale-up-policy"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown = 300
    metric_aggregation_type = "Average"
    estimated_instance_warmup = 180
  }

  target_tracking_configuration {
    target_value = 50
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}
```

---

### D. **Create a MySQL 8 Database Instance 💾**

Create a **MySQL** database instance in the private subnet:

```hcl
resource "aws_db_instance" "maged-wordpress-db" {
  identifier = "maged-wordpress-db"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "wordpress_db"
  username = "wp_user"
  password = "maged500"
  vpc_security_group_ids = [aws_security_group.maged-wordpress-terraform-sg.id]
  db_subnet_group_name = aws_db_subnet_group.maged-db-subnet-group.name

  tags = {
    Name = "maged-wordpress-db"
  }
}
```

---

### E. **Add Your Terraform Script to a Private GitHub Repo 🔐**

- Create a new private GitHub repository.
- Add your Terraform files to the repository.
- Commit and push the changes.

---

### F. **Use S3 as Backend for Terraform State 📦**

Store Terraform state files in **S3** for remote backend management:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key = "terraform.tfstate"
    region = "us-west-2"
  }
}
```

---

### G. **Separate Functions into Abstract Modules 🧩**

- Create separate modules for VPC, launch templates, auto scaling, MySQL, and others.
- Reference each module in the main Terraform script.
- This ensures a clean and reusable codebase.

Example of how to use the modules:

```hcl
module "vpc" {
  source = "./modules/vpc"
}

module "autoscaling" {
  source = "./modules/autoscaling"
  vpc_id = module.vpc.id
}

module "db" {
  source = "./modules/db"
  vpc_id = module.vpc.id
}
```

---

## 🛠️ How to Use

1. Clone this repository to your local machine.
2. Install Terraform: https://www.terraform.io/downloads.html
3. Initialize the Terraform working directory:
   ```bash
   terraform init
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

---

## 🎉 Congratulations!

You’ve now automated the infrastructure for a **WordPress** website with a **MySQL database** using **Terraform**!

---

## 🚧 Troubleshooting

If you encounter issues, try the following:

- Check the **AWS Console** for any failed resources.
- Run `terraform plan` to check for misconfigurations.
- Verify that your **AWS credentials** are set up correctly.

---

Happy Terraforming! 🌱