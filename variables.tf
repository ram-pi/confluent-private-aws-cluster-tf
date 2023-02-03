variable "api_key" {
  description = "Cloud API Key"
}
variable "secret" {
  description = "Cloud API Key Secret"
}
variable "service_account" {}
variable "env" {}
variable "kafka_cluster_name" {}
variable "availability" {
  type = string

  validation {
    condition     = length(regexall("^(SINGLE_ZONE|MULTI_ZONE)$", var.availability)) > 0
    error_message = "ERROR: Valid types are \"SINGLE_ZONE\" and \"MULTI_ZONE\"!"
  }
}
variable "cloud_provider" {
  type = string

  validation {
    condition     = length(regexall("^(AWS|GCP|AZURE)$", var.cloud_provider)) > 0
    error_message = "ERROR: Valid types are \"AWS\", \"GCP\" and \"AZURE\"!"
  }
}

variable "sr_cloud_provider" {
  type = string

  validation {
    condition     = length(regexall("^(AWS|GCP|AZURE)$", var.sr_cloud_provider)) > 0
    error_message = "ERROR: Valid types are \"AWS\", \"GCP\" and \"AZURE\"!"
  }
}

variable "region" {
  type = string
}

variable "sr_region" {
  type = string
}

variable "cku" {
  default = 1
}

variable "sr_package" {
  default = "ESSENTIALS"

  validation {
    condition     = length(regexall("^(ESSENTIALS|ADVANCED)$", var.sr_package)) > 0
    error_message = "ERROR: Valid types are \"ESSENTIALS\" and \"ADVANCED\"!"
  }
}

variable "owner" {}

variable "tag_owner" {
  default = "someone@confluent.io"
}

variable "ami_id" {}
variable "aws_profile" {}
variable "aws_azs" {
  type = list(any)
}
