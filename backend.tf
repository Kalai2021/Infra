// Backend configuration for remote state will be defined here 
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-locks"
  }
}
