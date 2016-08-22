# tf-aws-vpc-nat

A Terraform module that creates a VPC, public and private subnets,
NAT/Bastion instances and the associated routes from private subnets
to the public subnets and NAT/Bastion instances. The module uses a
Lambda Function to attach EIPs to the NAT/Bastions instances and then
update routing tables accordingly.

The module currently creates two Security Groups, one internal and
one external for SSH access.

## Usage


