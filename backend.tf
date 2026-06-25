terraform {
  backend "s3" {
    bucket         = "pavan-poc18-state"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "pavan-lock"
  }
}
