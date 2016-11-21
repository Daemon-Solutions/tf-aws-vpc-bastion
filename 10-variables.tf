## Global Configuration
variable "name" {}

variable "customer" {}

variable "envname" {}

variable "envtype" {}

variable "enable_windows" {
  default = 0
}
variable "enable_linux" {
  default = 1
}

variable "profile" {
  default = "bastion"
}

variable "domain" {}
variable "domain_password" {
  default = ""
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_zones" {
  type = "map"

  default = {
    eu-west-1 = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}

## VPC Variables
variable "vpc_cidr" {}

variable "public_subnets" {
  type = "list"
}

variable "private_subnets" {
  type = "list"
}

variable "domain_name_servers" {
  default = ["127.0.0.1","AmazonProvidedDNS"]
}

## Userdata Variables
variable "bastion_userdata" {}
variable "bastion_win_userdata" {
  default = ""
}

## Launch Configuration Variables
variable "ami_id" {}
variable "windows_ami_id" {
  default = ""
}

variable "instance_type" {
  default = "t2.micro"
}

variable "windows_instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "bashton"
}

variable "detailed_monitoring" {
  default = false
}

## Auto-Scaling Group
variable "health_check_type" {
  default = "EC2"
}

variable "health_check_grace_period" {
  default = 300
}

## Security Groups Variables
#
# - 195.102.251.16/28 -- LinuxIT Bristol
# - 54.76.122.23/32   -- Bashton OpenVPN
# - 88.97.72.136/32   -- Bashton Office
# - 195.8.68.130/32   -- Claranet London Office
#
variable "bastion_ssh_cidrs" {
  default = ["88.97.72.136/32", "54.76.122.23/32", "195.102.251.16/28", "195.8.68.130/32"]
}
