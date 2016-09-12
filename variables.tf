## Global Configuration
variable "name" {}

variable "envname" {}

variable "envtype" {}

variable "profile" {
  default = "bastion"
}

variable "domain" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_zones" {
  default = {
    eu-west-1 = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}


## VPC Variables
variable "vpc_cidr" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "domain_name_servers" {
  default = "127.0.0.1, AmazonProvidedDNS"
}


## Userdata Variables
variable "bastion_userdata" {}


## Launch Configuration Variables
variable "ami_id" {}

variable "instance_type" {
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
  default = "88.97.72.136/32,54.76.122.23/32,195.102.251.16/28,195.8.68.130/32"
}
