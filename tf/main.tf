
terraform {
  backend "s3" {
    bucket = "stopthatastronaut"
    key    = "ror-aws-demo/demo.state.tfstate"
    region = "ap-southeast-2"
  }

  required_providers {
    circleci = {
      source = "mrolla/circleci"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}



