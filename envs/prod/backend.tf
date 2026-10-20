terraform {
  backend "s3" {
    bucket = ""
    key = "prod/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = ""
    encrypt = true
  }
}