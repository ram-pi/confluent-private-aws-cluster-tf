output "display_name" {
  value = confluent_kafka_cluster.k_cluster.display_name
}

output "rest_endpoint" {
  value = confluent_kafka_cluster.k_cluster.bootstrap_endpoint
}

output "kafka_api_key" {
  value = confluent_api_key.kafka-api-key.id
}

output "kafka_api_key_secret" {
  value     = confluent_api_key.kafka-api-key.secret
  sensitive = true
}

# output "sr_api_key" {
#   value = confluent_api_key.sr-api-key.id
# }

# output "sr_api_key_secret" {
#   value     = confluent_api_key.sr-api-key.secret
#   sensitive = true
# }

# output "sr_rest_endpoint" {
#   value = confluent_schema_registry_cluster.sr_cluster.rest_endpoint
# }

output "public_subnet_cidr_block" {
  value = aws_subnet.my_subnet.cidr_block
}

output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.my_ec2.private_ip
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "private_link_domain_name" {
  value = confluent_network.my_private_link.dns_domain
}

output "private_link_endpoint_service" {
  value = confluent_network.my_private_link.aws[0].private_link_endpoint_service
}

output "private_link_endpoints" {
  value = aws_vpc_endpoint.my_vpc_endpoint.dns_entry
}
