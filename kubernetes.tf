resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.aws_used_availability_zone
  tags = {
    Name = var.environment
    Type = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.dev.id
  }

  tags = {
    Name = var.environment
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}_allow_web"
  }
}

resource "aws_network_interface" "public1" {
  subnet_id       = aws_subnet.public1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.public.id]
}

resource "aws_eip" "web" {
  vpc                       = true
  network_interface         = aws_network_interface.public1.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.dev]
}

resource "aws_route53_record" "main" {
  zone_id = var.route53_zone_id
  name    = "${var.environment}.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.web.public_ip]
}

resource "aws_instance" "web_server" {
  ami = var.aws_ami
  instance_type = var.aws_instance_type
  availability_zone = var.aws_used_availability_zone
  key_name = var.aws_pem_key_name

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.public1.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo su
              apt update -y
              snap install microk8s --classic --channel=1.16/stable
              microk8s status --wait-ready

              microk8s.enable dns dashboard ingress
              microk8s.enable fluentd

              microk8s.kubectl proxy --accept-hosts=.* --address=0.0.0.0 &
              EOF
  tags = {
    Name = "${var.environment}_cluster_k8s"
  }
}
