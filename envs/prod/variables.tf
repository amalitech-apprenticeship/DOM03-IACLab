variable "region" {
  type = string
  description = "Region where the resources will be deployed"
  default = "eu-west-1"
}
variable "my_ip" {
  type = string
  description = "The IP address of the currrent user"
}
variable "ami" {
  type = string
}
