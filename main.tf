# create 2 public subnet , 1 private subnet
module "networking" {
  source                = "./modules/networking"
  cidr                  = "10.0.0.0/16"
  public-subnet-cidr-1a = "10.0.1.0/24"
  public-subnet-cidr-1b = "10.0.2.0/24"
}

module "ec2" {
  source       = "./modules/ec2"
  vpc_id       = module.networking.vpc_id
  subnet_1a_id = module.networking.subnet_1a_id
  subnet_1b_id = module.networking.subnet_1b_id
  template-name = "maged-launch-template"
}

output "dns-name" {
  value = module.ec2.load_balancer_dns
}

# module "cloudflare" {
#   source            = "./modules/cloudflare"
#   cloudflare_zone_id = var.cloudflare_zone_id
#   record_name        = "magedmohamed"
#   record_value       = module.ec2.load_balancer_dns
# }
