# Fixed variables

variable "aws_region" {
    description = "Region"
    default = "us-east-1"
}

variable "aws_used_availability_zone" {
    description = "Region"
    default = "us-east-1a"
}

variable "aws_ami" {
    description = "EC2 images"
    default = "ami-042e8287309f5df03"
}

variable "aws_instance_type" {
    description = "EC2 instance type"
    default = "t2.medium"
}

variable "aws_pem_key_name" {
    description = "EC2 instance type"
    default = "terraform_tests_key"
}

variable "environment" {
    description = "Environment"
    default = "production"
}

variable "domain" {
    description = "Environment"
    default = "leonardobozcaitano.com"
}

variable "route53_zone_id" {
    description = "Route 53 Zone ID"
}

# Necessary variables

variable "aws_access_key" {
    description = "Access Key"
}

variable "aws_secret_access_key" {
    description = "Secret Access Key"
}