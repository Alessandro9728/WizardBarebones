terraform {
  backend "s3" {
    bucket = "terraformstate-ngom-wizard"
    key    = "my-tf-state/terrafrom.tfstate"
    region = "eu-west-1"
  }
}


provider "aws" {
  region                   = "eu-west-1"
  shared_credentials_files = ["/Users/a.pizzorno/.aws/credentials"]
}

