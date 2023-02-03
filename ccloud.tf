data "confluent_environment" "c_env" {
  id = var.env
}

data "confluent_service_account" "cc_sa" {
  id = var.service_account
}

data "confluent_schema_registry_region" "sr_region" {
  cloud   = var.sr_cloud_provider
  region  = var.sr_region
  package = var.sr_package
}

data "aws_caller_identity" "current" {}

resource "confluent_network" "my_private_link" {
  display_name     = "${var.owner} Private Link Network"
  cloud            = "AWS"
  region           = var.region
  connection_types = ["PRIVATELINK"]
  zones            = var.aws_azs
  environment {
    id = data.confluent_environment.c_env.id
  }
}

resource "confluent_private_link_access" "my_confluent_private_link_access" {
  display_name = "AWS Private Link Access"
  aws {
    account = data.aws_caller_identity.current.account_id
  }
  environment {
    id = data.confluent_environment.c_env.id
  }
  network {
    id = confluent_network.my_private_link.id
  }
}

resource "aws_vpc_endpoint" "my_vpc_endpoint" {
  vpc_id            = aws_vpc.my_vpc.id
  service_name      = confluent_network.my_private_link.aws[0].private_link_endpoint_service
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.my_security_group.id,
  ]

  subnet_ids          = [aws_subnet.my_subnet.id]
  private_dns_enabled = false

  tags = {
    Name    = "endpoint-${var.owner}"
    "owner" = var.tag_owner
  }

  depends_on = [
    confluent_private_link_access.my_confluent_private_link_access,
  ]
}

resource "aws_route53_zone" "my_route53" {
  name = confluent_network.my_private_link.dns_domain

  vpc {
    vpc_id = aws_vpc.my_vpc.id
  }
}

resource "aws_route53_record" "my_route53_record" {
  #   count   = length(var.aws_azs) == 1 ? 0 : 1
  zone_id = aws_route53_zone.my_route53.zone_id
  name    = "*.${aws_route53_zone.my_route53.name}"
  type    = "CNAME"
  ttl     = "60"
  records = [
    aws_vpc_endpoint.my_vpc_endpoint.dns_entry[0]["dns_name"]
  ]
}


resource "confluent_kafka_cluster" "k_cluster" {
  display_name = "private"
  availability = "MULTI_ZONE"
  cloud        = var.cloud_provider
  region       = var.region
  dedicated {
    cku = 2
  }

  environment {
    id = data.confluent_environment.c_env.id
  }

  network {
    id = confluent_network.my_private_link.id
  }
}

resource "confluent_api_key" "kafka-api-key" {
  display_name = "tf-kafka-api-key"
  description  = "tf-kafka-api-key"

  disable_wait_for_ready = true

  # Set optional `disable_wait_for_ready` attribute (defaults to `false`) to `true` if the machine where Terraform is not run within a private network
  # disable_wait_for_ready = true

  owner {
    id          = data.confluent_service_account.cc_sa.id
    api_version = data.confluent_service_account.cc_sa.api_version
    kind        = data.confluent_service_account.cc_sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.k_cluster.id
    api_version = confluent_kafka_cluster.k_cluster.api_version
    kind        = confluent_kafka_cluster.k_cluster.kind

    environment {
      id = data.confluent_environment.c_env.id
    }
  }
}

# locals {
#   endpoint_prefix = split(".", aws_vpc_endpoint.my_vpc_endpoint.dns_entry[0]["dns_name"])[0]
# }

# resource "aws_route53_record" "my_route53_record_zonal" {
#   for_each = var.aws_azs

#   zone_id = aws_route53_zone.my_route53.zone_id
#   name    = length(var.my_route53) == 1 ? "*" : "*.${each.key}"
#   type    = "CNAME"
#   ttl     = "60"
#   records = [
#     format("%s-%s%s",
#       local.endpoint_prefix,
#       data.aws_availability_zone.privatelink[each.key].name,
#       replace(aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"], local.endpoint_prefix, "")
#     )
#   ]
# }
