variable "my_ip" {
  type = string
  description = "The IP address of the currrent user"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "ami" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}