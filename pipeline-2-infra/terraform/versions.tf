terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "prince-my-project-s3-bucket-2026"
    key    = "pipeline-2/terraform.tfstate"
    region = "ap-southeast-2"
  }
}
