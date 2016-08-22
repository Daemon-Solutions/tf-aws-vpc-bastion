# Global Configuration
variable "name" { }
variable "envname" { }
variable "envtype" { }
variable "profile" { default = "bastion" }
variable "domain" { }
variable "aws_region" { }
variable "aws_zones" { }

# VPC Variables
variable "vpc_cidr" { }
variable "public_subnets" { }
variable "private_subnets" { }
variable "domain_name_servers" { default = "127.0.0.1, AmazonProvidedDNS" }

# Userdata Variables
variable "bastion_userdata" { }

# Launch Configuration Variables
variable "ami_id" { }
variable "instance_type" { default = "t2.micro" }
variable "key_name" { default = "bashton" }
variable "detailed_monitoring" { default = false }

# Auto-Scaling Group
variable "health_check_type" { default = "EC2" }
variable "health_check_grace_period" { default = 300 }

# Security Groups Variables
variable "bastion_ssh_cidrs" { default = "88.97.72.136/32,54.76.122.23/32" }
