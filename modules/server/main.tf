resource "aws_security_group" "this" {
  name = "public_instance_sg"
  description = "Allows http from all and ssh from My Ip"
  vpc_id = var.vpc_id

}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4 = var.my_ip
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
}

resource "aws_instance" "server" {
  instance_type = var.instance_type
  ami = var.ami
  associate_public_ip_address = true
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [ aws_security_group.this ]
}