## Lambda
resource "aws_lambda_permission" "bastion_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.attach_eip.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.bastion_asg.arn}"
}

resource "aws_sns_topic_subscription" "bastion_asg" {
  topic_arn = "${aws_sns_topic.bastion_asg.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.attach_eip.arn}"
}

resource "aws_lambda_function" "attach_eip" {
  filename         = "${path.module}/include/associateEIP.zip"
  source_code_hash = "${base64sha256(file("${path.module}/include/associateEIP.zip"))}"
  function_name    = "${var.name}-${var.envname}-bastion"
  role             = "${aws_iam_role.bastion_lambda_role.arn}"
  handler          = "associateEIP.lambda_handler"
  runtime          = "python2.7"
  timeout          = "6"
}

resource "aws_iam_role" "bastion_lambda_role" {
  name = "${var.name}-${var.envname}-lambda"

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
  name = "${var.name}-${var.envname}-lambda-ec2-describe"

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

resource "aws_iam_role_policy" "bastion_lambda_asg_describe" {
  name = "${var.name}-${var.envname}-lambda-asg-describe"

  role = "${aws_iam_role.bastion_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_lambda_logs" {
  name = "${var.name}-${var.envname}-lambda-cloudwatch-logs"

  role = "${aws_iam_role.bastion_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_lambda_eip_associate" {
  name = "${var.name}-${var.envname}-lambda-eip-associate"

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
  name = "${var.name}-${var.envname}-lambda-routes"

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
