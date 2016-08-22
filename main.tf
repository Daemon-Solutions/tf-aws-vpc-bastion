# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.name}-vpc"
  }
}

resource "aws_vpc_dhcp_options" "vpc" {
  domain_name         = "${var.domain}"
  domain_name_servers = ["${split(",", var.domain_name_servers)}"]

  tags {
    Name = "${var.name}"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc.id}"
}

# Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(split(",", var.public_subnets))}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone       = "${element(split(",", var.aws_zones), count.index)}"
  map_public_ip_on_launch = "false"

  tags {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table" "public" {
  depends_on = ["aws_internet_gateway.igw"]
  vpc_id     = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-public-route"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.public_subnets))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Private Subnets
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.aws_zones), count.index)}"
  count             = "${length(split(",", var.private_subnets))}"

  tags {
    Name = "${var.name}-private"
  }
}

resource "aws_route_table" "private" {
  count      = "${length(split(",", var.private_subnets))}"
  vpc_id     = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-private-route"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",", var.private_subnets))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# Lambda

resource "aws_lambda_permission" "bastion_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.attach_eip.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.bastion_asg.arn}"
}

resource "aws_sns_topic_subscription" "bastion_asg" {
  topic_arn = "${aws_sns_topic.bastion_asg.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.attach_eip.arn}"
}

resource "aws_lambda_function" "attach_eip" {
  filename         = "./include/associateEIP.zip"
  source_code_hash = "${base64sha256(file("./include/associateEIP.zip"))}"
  function_name    = "${var.name}-lambda-function"
  role             = "${aws_iam_role.bastion_lambda_role.arn}"
  handler          = "associateEIP.lambda_handler"
  runtime          = "python2.7"
}

resource "aws_iam_role" "bastion_lambda_role" {
  name = "${var.name}-lambda-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_lambda_ec2_describe" {
  name = "${var.name}-lambda-ec2-describe"

  role = "${aws_iam_role.bastion_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "cloudwatch:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_lambda_cloudwatch_all" {
  name = "${var.name}-lambda-cloudwatch-all"

  role = "${aws_iam_role.bastion_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_lambda_eip_associate" {
  name = "${var.name}-lambda-eip-associate"

  role = "${aws_iam_role.bastion_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_lambda_routes" {
  name = "${var.name}-lambda-routes"

  role = "${aws_iam_role.bastion_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateRoute",
        "ec2:DeleteRoute"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.name}-profile"
  roles = ["${aws_iam_role.bastion_role.name}"]
}

resource "aws_iam_role" "bastion_role" {
  name = "${var.name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_describe" {
  name = "${var.name}-ec2_describe"

  role = "${aws_iam_role.bastion_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_attach" {
  name = "${var.name}-ec2_attach"

  role = "${aws_iam_role.bastion_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Attach*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_readonly" {
  name = "${var.name}-s3_readonly"

  role = "${aws_iam_role.bastion_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:List*",
        "s3:Get*"
      ],
      "Effect": "Allow",
      "Resource": [ "arn:aws:s3:::*" ]
    }
  ]
}
EOF
}

# Elastic IP
resource "aws_eip" "bastion_eip" {
  count = "${length(split(",", var.aws_zones))}"
  vpc   = "true"
}

# Userdata Configuration
resource "template_file" "bastion_userdata" {
  lifecycle {
    create_before_destroy = "true"
  }

  template = "${var.bastion_userdata}"
  vars {
    envtype    = "${var.envtype}"
    envname    = "${var.envname}"
    profile    = "${var.profile}"
    aws_region = "${var.aws_region}"
    domain     = "${var.domain}"
  }
}

# Launch Configuration
resource "aws_launch_configuration" "lc" {
  lifecycle {
    create_before_destroy = true
  }

  security_groups = ["${aws_security_group.bastion_external.id}","${aws_security_group.bastion_internal.id}"]
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion_instance_profile.id}"
  key_name = "${var.key_name}"
  user_data = "${template_file.bastion_userdata.rendered}"
  associate_public_ip_address = "false"
  enable_monitoring = "${var.detailed_monitoring}"
}

# Auto-Scaling Group Configuration

resource "aws_sns_topic" "bastion_asg" {
  name = "${var.name}-sns-topic"
}

resource "aws_autoscaling_notification" "bastion_notifications" {
  group_names = [
    "${aws_autoscaling_group.asg.name}",
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
  ]
  topic_arn = "${aws_sns_topic.bastion_asg.arn}"
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.name}"
  availability_zones = ["${split(",", var.aws_zones)}"]
  vpc_zone_identifier = ["${join(",", aws_subnet.public.*.id)}"]

  launch_configuration = "${aws_launch_configuration.lc.name}"

  min_size = "${length(split(",", var.aws_zones))}"
  max_size = "${length(split(",", var.aws_zones))}"

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type = "${var.health_check_type}"

  tag { key = "Name" value = "${var.name}" propagate_at_launch = true }
  tag { key = "Environment" value = "${var.envname}" propagate_at_launch = true }
  tag { key = "EnvType" value = "${var.envtype}" propagate_at_launch = true }
  tag { key = "Service" value = "${var.profile}" propagate_at_launch = true }
  tag { key = "expected_EIPs" value = "${join(",", aws_eip.bastion_eip.*.public_ip)}" propagate_at_launch = true }
  tag { key = "private_subnets" value = "${join(",", aws_subnet.private.*.id)}" propagate_at_launch = true }

}

# External Security Group
resource "aws_security_group" "bastion_external" {
  name = "${var.name}-external-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  description = "Bastion security group"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.bastion_ssh_cidrs)}"]
  }
}

# Internal Security Group
resource "aws_security_group" "bastion_internal" {
  name = "${var.name}-internal-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  description = "Bastion security group"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
  }
}
