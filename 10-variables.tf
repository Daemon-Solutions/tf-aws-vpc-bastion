## Global Configuration
variable "name" {
  description = "This will be the first name prefix for resources created by this module, as well as the first name prefix for the 'Name' tag"
  type = "string"
}

variable "customer" {
  description = "This will be the value for the 'customer' tag on resources created by this module"
  type = "string"
}

variable "envname" {
  description = "This will be the second name prefix for resources created by this module, as well as the second name prefix for the 'Name' tag"
  type = "string"
}

variable "envtype" {
  description = "This will be the value for the 'EnvType' tag on resources created by this module"
  type = "string"
}

variable "enable_windows" {
  description = "Bit indicating whether to create Windows Server resources"
  type = "string"
  default = 0
}
variable "enable_linux" {
  description = "Bit indicating whether to create Linux server resources"
  type = "string"
  default = 1
}

variable "profile" {
  description = "Value for the 'profile' and 'service' tags"
  type = "string"
  default = "bastion"
}

variable "domain" {
  description = "The fully qualified Active Directory domain name (Windows userdata only)"
  type = "string"
  default = ""
}

variable "domain_password" {
  description = "The password to join the Active Directory domain (Windows userdata only)"
  type = "string"
  default = ""
}

variable "aws_region" {
  description = "The AWS region in which to place these resources"
  type = "string"
  default = "eu-west-1"
}

variable "aws_zones" {
  description = "Map containing a list of AWS Availability Zones"
  type = "map"
  default = {
    eu-west-1 = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}

## VPC Variables
variable "vpc_cidr" {
  description = "The CIDR block to use for the VPC"
  type = "string"
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets to create inside the VPC"
  type = "list"
}

variable "private_subnets" {
  description = "List of private subnets to create inside the VPC"
  type = "list"
}

variable "domain_name_servers" {
  description = "List of DNS servers for instances to use"
  type = "list"
  default = ["127.0.0.1", "AmazonProvidedDNS"]
}

## Userdata Variables
variable "bastion_userdata" {
  description = "Userdata to launch Linux instances with"
  type = "string"
  default = ""
}

variable "bastion_win_userdata" {
  description = "Userdata to launch Windows instances with"
  type = "string"
  default = ""
}

## Launch Configuration Variables
variable "ami_id" {
  description = "The AMI ID to use for launching Linux instances"
  type = "string"
  default = ""
}

variable "windows_ami_id" {
  description = "The AMI ID to use for launching Windows instances"
  type = "string"
  default = ""
}

variable "instance_type" {
  description = "The instance type to use for Linux instances"
  type = "string"
  default = "t2.micro"
}

variable "windows_instance_type" {
  description = "The instance type to use for Windows instances"
  type = "string"
  default = "t2.micro"
}

variable "key_name" {
  description = "The key pair to associate with instances"
  type = "string"
  default = "bashton"
}

variable "detailed_monitoring" {
  description = "Bool indicating whether to enable detailed monitoring"
  type = "string"
  default = false
}

## Auto-Scaling Group
variable "health_check_type" {
  description = "The type of healthcheck to use to determine health status"
  type = "string"
  default = "EC2"
}

variable "health_check_grace_period" {
  description = "The period (seconds) after an instance spins up before health checking begins"
  type = "string"
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
  description = "The list of remote CIDR blocks to allow access for"
  type = "list"
  default = ["88.97.72.136/32", "54.76.122.23/32", "195.102.251.16/28", "195.8.68.130/32"]
}
