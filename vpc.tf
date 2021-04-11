resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.environment
  }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
}
