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

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_ssh_cidrs}"]
  }
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
