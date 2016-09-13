## VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name        = "${var.name}-${var.envname}"
    Environment = "${var.envname}"
    EnvType     = "${var.envtype}"
  }
}

resource "aws_vpc_dhcp_options" "vpc" {
  domain_name         = "${var.domain}"
  domain_name_servers = ["${var.domain_name_servers}"]

  tags {
    Name        = "${var.name}-${var.envname}"
    Environment = "${var.envname}"
    EnvType     = "${var.envtype}"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc.id}"
}

## Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.name}-${var.envname}"
    Environment = "${var.envname}"
    EnvType     = "${var.envtype}"
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(var.public_subnets)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  availability_zone       = "${element(split(",",lookup(var.aws_zones,var.aws_region)), count.index)}"
  map_public_ip_on_launch = "false"

  tags {
    Name        = "${var.name}-${var.envname}-public"
    Environment = "${var.envname}"
    EnvType     = "${var.envtype}"
  }
}

resource "aws_route_table" "public" {
  vpc_id     = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name        = "${var.name}-${var.envname}-public"
    Environment = "${var.envname}"
    EnvType     = "${var.envtype}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

## Private Subnets
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(split(",",lookup(var.aws_zones,var.aws_region)), count.index)}"
  count             = "${length(var.private_subnets)}"

  tags {
    Name        = "${var.name}-${var.envname}-private"
    Environment = "${var.envname}"
    EnvType     = "${var.envtype}"
  }
}

resource "aws_route_table" "private" {
  count  = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.name}-${var.envname}-private"
    Environment = "${var.envname}"
    EnvType     = "${var.envtype}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
