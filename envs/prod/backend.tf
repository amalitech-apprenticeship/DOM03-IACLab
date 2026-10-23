terraform {
  backend "s3" {
    bucket = "lab3-state-backend-6yjsux"
    key = "prod/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "tf-state"
    encrypt = true
  }
}