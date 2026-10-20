module "network" {
  source = "../../modules/network"
}
module "server" {
  source = "../../modules/server"
  my_ip = var.my_ip
  ami = var.ami
  public_subnet_id = module.network.public_subnet_id
  vpc_id = module.network.vpc_id
}

