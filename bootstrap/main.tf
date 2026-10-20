terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }

        random = {
            source = "hashicorp/random"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
}

resource "random_string" "random"{
    length = 6
    special = false
    lower = true
    upper = false
}

resource "aws_s3_bucket" "state_backend" {
    bucket = format("lab3-state-backend-${random_string.random.result}")

    lifecycle {
      prevent_destroy = true
    }
    # Only to be used when you want to force delete the bucket with all it's versions
    # force_destroy = true
}

resource "aws_s3_bucket_versioning" "state_backend" {
    bucket = aws_s3_bucket.state_backend.id
    versioning_configuration {
      status = "Enabled"
    }
}


resource "aws_dynamodb_table" "tf_state_lock" {
  name = "tf-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}


output "state_bucket_name" {
  value = aws_s3_bucket.state_backend.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.tf_state_lock.name
}