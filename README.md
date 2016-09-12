# tf-aws-vpc-nat

This module will create the below resources:

- VPC
- IGW
- Public Subnets
- Private Subnets
- Route Tables
- Lambda Function (attach EIPs to Bastion hosts and update the route tables)
- SNS Topic
- Lambda SNS Subscription (for Bastion ASG event notifications)
- Lambda IAM role and associated policies (for EIP attachment and route changes)
- Bastion IAM role and associated policies (to read from S3 yum repos)
- EIPs for attachment to Bastion instances
- Bastion Launch Configuration (defaults to t2.micro)
- Bastion ASG (sends ASG events to SNS to trigger Lambda)
- Internal Bastion SG for access from the VPC
- External Bastion SG for SSH access

Resource numbers will differ based on the number of AZs passed to Terraform.
If you pass three AZs you will have an ASG with three instances, three EIPs,
three of each subnet and so on. If you are in a region such as eu-central-1
with only two zones then the module will handle this and only create two
resources where applicable.

The module assumes you are happy with a set of Bastions per VPC. Using this
module it would be sensible to host all `nonprod` infrastructure in a single
VPC. If you don't do this you will have a lot of Bastions.

## Usage

Call the module:

```
module "bastions" {
  source = "/home/chris/dev/tf-aws-vpc-bastion"

  name              = "projectx"
  envname           = "dev"
  envtype           = "nonprod"
  vpc_cidr          = "172.28.0.0/21"
  public_subnets    = "172.28.0.0/24,172.28.1.0/24,172.28.2.0/24"
  private_subnets   = "172.28.3.0/24,172.28.4.0/24,172.28.5.0/24"
  domain            = "example.com"
  ami_id            = "ami-00000000"
  bastion_userdata  = "${file("./include/bastion_userdata.tmpl")}"
  bastion_ssh_cidrs = "88.97.72.136/32,54.76.122.23/32"
  aws_zones         = "eu-west-1a,eu-west-1b,eu-west-1c"
  aws_region        = "eu-west-1"
}
```

## Variables
- `name` - Used to identify your resources, the project name is sensible
- `envname` - You probably only want a `nonprod` and `prod` VPC
- `envtype` - usually `prod` or `nonprod`
- `vpc_cidr` - CIDR to use for your VPC
- `public_subnets` - The public subnets the bastions will sit in
- `private_subnets` - The private subnets your infrastructure will sit in
- `domain` - The domain for your environment (this is only used in userdata)
- `ami_id` - The AWS AMI to use, should be a Linux image like CentOS or Debian
- `bastion_userdata` - The template file to use for bastion userdata
- `bastion_ssh_cidrs` - IPs allowed SSH access to Bastions from the internet
- `aws_zones` - AWS zones to use
- `aws_region` - AWS region to use

## Outputs
- `vpc_id` - VPC ID
- `vpc_cidr` - VPC CIDR
- `availability_zones` - AWS availability zones in use
- `public_subnets` - Comma separated list of public subnets
- `public_route_tables` - Comma separated list of public subnet route tables
- `private_subnets` - Comma separated list of private subnets
- `private_route_tables` - Comma separated list of private subnet route tables
- `bastion_userdata_redndered` - Rendered version of bastion userdata
- `bastion_iam_profile_id` - Bastion instance IAM profile ID
- `bastion_iam_role_id` - Bastion instance IAM role ID
- `bastion_eip_ids` - Comma separated list of EIP IDs to be attached to bastions
- `bastion_eip` - Comma separated list of EIP IPs to be attached to bastions
- `launch_config_id` Bastion launch configuration ID
- `asg_id` - Bastion ASG ID
- `asg_name` - Bastion ASG name
- `lambda_arn` - Lambda function ARN
- `lambda_iam_role_id` - Lambda IAM role ID
- `bastion_sns_arn` - Bastion ASG notification SNS ARN
- `bastion_sns_id` - Bastion ASG notification SNS ID
- `bastion_sns_subscription_arn` - Bastion ASG notification SNS subscription ARN
- `bastion_sns_subscription_id` - Bastion ASG notification SNS subscription ID
- `bastion_external_sg_id` - Bastion external SG ID
- `bastion_internal_sg_id` - Bastion internal SG ID

