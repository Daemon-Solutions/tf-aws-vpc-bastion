## External Security Group
resource "aws_security_group" "bastion_external" {
  name        = "${var.name}-${var.envname}-bastion-external"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "Bastion security group"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "bastion_external_ssh" {
  type        = "ingress"
  from_port   = "22"
  to_port     = "22"
  protocol    = "tcp"
  cidr_blocks = ["${var.bastion_ssh_cidrs}"]
  security_group_id = "${aws_security_group.bastion_external.id}"
}

resource "aws_security_group_rule" "bastion_external_rdp" {
  count       = "${var.enable_windows}"
  type        = "ingress"
  from_port   = "3389"
  to_port     = "3389"
  protocol    = "tcp"
  cidr_blocks = ["${var.bastion_ssh_cidrs}"]
  security_group_id = "${aws_security_group.bastion_external.id}"
}

resource "aws_security_group_rule" "bastion_external_wirm_http" {
  count       = "${var.enable_windows}"
  type        = "ingress"
  from_port   = "5985"
  to_port     = "5985"
  protocol    = "tcp"
  cidr_blocks = ["${var.bastion_ssh_cidrs}"]
  security_group_id = "${aws_security_group.bastion_external.id}"
}

resource "aws_security_group_rule" "bastion_external_wirm_https" {
  count       = "${var.enable_windows}"
  type        = "ingress"
  from_port   = "5986"
  to_port     = "5986"
  protocol    = "tcp"
  cidr_blocks = ["${var.bastion_ssh_cidrs}"]
  security_group_id = "${aws_security_group.bastion_external.id}"
}

## Internal Security Group
resource "aws_security_group" "bastion_internal" {
  name        = "${var.name}-${var.envname}-bastion-internal"
  vpc_id      = "${aws_vpc.vpc.id}"
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
