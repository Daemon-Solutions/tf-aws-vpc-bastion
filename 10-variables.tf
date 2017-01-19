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
  type = "list"
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

variable "bastion_ssh_cidrs" {
  // 195.102.251.18/32 - Claranet Emersons Green
  // 195.8.68.130/32 - Claranet SHR
  // 195.8.70.0/24 - Claranet SHR
  // 195.157.3.3/32 - Claranet SSL VPN
  // 195.157.3.4/32 - Claranet SSL VPN
  // 195.102.251.7/32 - Claranet Birchwood
  // 195.216.14.9/32 - Claranet Barnwood
  // 54.76.122.23/32 - Bashton EC2 OpenVPN
  type = "list"

  default = ["195.102.251.18/32",
            "195.8.68.130/32",
            "195.8.70.0/24",
            "195.157.3.3/32",
            "195.157.3.4/32",
            "195.102.251.7/32",
            "54.76.122.23/32"
          ]
  }
  
  
  
  default = ["88.97.72.136/32", "54.76.122.23/32", "195.102.251.16/28", "195.8.68.130/32"]
}
