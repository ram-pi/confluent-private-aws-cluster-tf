terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.27.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "= 2.32.0"
    }
  }
}

# PROVIDERS 

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "confluent" {
  cloud_api_key    = var.api_key # optionally use CONFLUENT_CLOUD_API_KEY env var
  cloud_api_secret = var.secret  # optionally use CONFLUENT_CLOUD_API_SECRET env var
}
