provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-codestore2"  # Replace with your actual S3 bucket name
    key    = "s3/terraform.tfstate"  
    region = "us-east-1" 
  }
}