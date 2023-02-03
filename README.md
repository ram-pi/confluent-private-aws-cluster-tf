# Confluent Cloud dedicated cluster setup

## Description

Provision of:
- AWS private-link based Confluent Cluster
- AWS VPC, Subnet and ec2 instance for accessing the cluster
- private.pem to ssh into the instance
- firewall rule to open traffic for your external IP

## Prerequisites

- Terraform
- Kafka CLI 
- Existing Confluent Cloud Environment
- Existing Cloud API Key

## Set your variables 

Create the terraform.tfvars file like below
```
api_key            = "****"
secret             = "****"
service_account    = "my-sa"
env                = "my-env"
kafka_cluster_name = "dedicated"
availability       = "MULTI_ZONE"
cloud_provider     = "AWS"
sr_cloud_provider  = "AWS"
region             = "eu-central-1"
sr_region          = "eu-central-1"
cku                = 2
owner              = "****"
tag_owner          = "****"
ami_id             = "ami_id" 
aws_profile        = "****"
aws_azs            = ["euc1-az1", "euc1-az2", "euc1-az3"]
```

## Run

```
alias tf="terraform"
tf init
tf plan --var-file=terraform.tfvars -out=plan.out
tf apply plan.out
```