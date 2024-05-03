terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specifies the source of the provider. The hashicorp/aws source refers to the official HashiCorp AWS provider. This is where Terraform will download the provider plugin from
      version = "~> 5.0"
    }
  }
  backend "s3" {                       # Specifies the backend type. In this case, it's set to "s3" indicating that Terraform will use Amazon S3 as the backend for storing state
    bucket  = "da7-terraform-state"    # S3 bucket where Terraform state will be stored
    key     = "3641-terraform.tfstate" # Name of the state file within the S3 bucket
    region  = "eu-central-1"           # AWS region where the S3 bucket is located
    encrypt = true
    profile = "data_academy"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "eu-central-1"
  profile = "data_academy"
}
