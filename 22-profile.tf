## IAM Instance Profile
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name  = "${var.name}-${var.envname}-bastion"
  roles = ["${aws_iam_role.bastion_role.name}"]
}

resource "aws_iam_role" "bastion_role" {
  name = "${var.name}-${var.envname}-bastion"

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
  name = "${var.name}-${var.envname}-bastion-ec2-describe"

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
  name = "${var.name}-bastion-ec2-attach"

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
  name = "${var.name}-bastion-s3-readonly"

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
