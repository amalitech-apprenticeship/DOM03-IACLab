resource "aws_vpc" "lab3-vpc" {
    cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "lab3-gw" {
    vpc_id = aws_vpc.lab3-vpc.id
}

resource "aws_route_table" "lab3-rt" {
    vpc_id = aws_vpc.lab3-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab3-gw.id
    }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.lab3-vpc.id
  cidr_block = var.public_subnet_cidr
}

