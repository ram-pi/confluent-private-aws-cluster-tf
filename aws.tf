data "http" "my_ip" {
  url = "https://ifconfig.me"
}

// create tls private key and store it on local filesystem
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "my_private_key" {
  depends_on = [
    tls_private_key.my_key
  ]
  content         = tls_private_key.my_key.private_key_pem
  filename        = "private.pem"
  file_permission = "0600"
}

resource "local_file" "my_public_key" {
  depends_on = [
    tls_private_key.my_key
  ]
  content         = tls_private_key.my_key.public_key_openssh
  filename        = "public.pem"
  file_permission = "0600"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "owner" = var.tag_owner
    Name    = "vpc-${var.owner}"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "subnet-${var.owner}"
    "owner" = var.tag_owner
  }
}

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    "owner" = var.tag_owner
    Name    = "gateway-${var.owner}"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }
  tags = {
    "owner" = var.tag_owner
    Name    = "route-table-${var.owner}"
  }
}
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_security_group" {
  name        = "security-group-${var.owner}"
  description = "Allow inbound traffic from ${data.http.my_ip.response_body}"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "${data.http.my_ip.response_body} from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block, "${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "allow ${var.owner}"
    "owner" = var.tag_owner
  }
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "key-pair-${var.owner}"
  public_key = local_file.my_public_key.content
}


resource "aws_instance" "my_ec2" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.my_key_pair.key_name
  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = true
  //user_data                   = file("files/web_bootstrap.sh")
  vpc_security_group_ids = [
    aws_security_group.my_security_group.id,
  ]

  tags = {
    Name    = "ec2-${var.owner}"
    "owner" = var.tag_owner
  }
}
