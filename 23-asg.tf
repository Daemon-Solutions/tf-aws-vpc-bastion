## Elastic IP
resource "aws_eip" "bastion_eip" {
  count = "${length(split(",",lookup(var.aws_zones,var.aws_region)))*2}"
  vpc   = "true"
}

## Userdata Configuration
resource "template_file" "bastion_userdata" {
  count    = "${var.enable_linux}"
  lifecycle {
    create_before_destroy = "true"
  }

  template = "${var.bastion_userdata}"

  vars {
    customer   = "${var.customer}"
    envtype    = "${var.envtype}"
    envname    = "${var.envname}"
    profile    = "${var.profile}"
    aws_region = "${var.aws_region}"
    domain     = "${var.domain}"
  }
}

resource "template_file" "bastion_win_userdata" {
  count    = "${var.enable_windows}"
  template = "${var.bastion_win_userdata}"

  lifecycle {
    create_before_destroy = "true"
  }

  vars {
    customer   = "${var.customer}"
    envtype    = "${var.envtype}"
    envname    = "${var.envname}"
    profile    = "${var.profile}"
    aws_region = "${var.aws_region}"
    domain     = "${var.domain}"
  }
}

resource "template_file" "bastion_domain_join_ps1" {
  count    = "${var.enable_windows}"
  template = "${path.module}/include/domain_join.ps1.tmpl"

  lifecycle {
    create_before_destroy = true
  }

  vars {
    domain_name     = "${var.domain}"
    domain_password = "${var.domain_password}"
    dns_servers     = "${join(",",var.domain_name_servers)}"
  }
}

## Launch Configuration
resource "aws_launch_configuration" "lc" {
  count    = "${var.enable_linux}"

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.bastion_external.id}", "${aws_security_group.bastion_internal.id}"]
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_instance_profile.id}"
  key_name                    = "${var.key_name}"
  user_data                   = "${template_file.bastion_userdata.rendered}"
  associate_public_ip_address = "false"
  enable_monitoring           = "${var.detailed_monitoring}"
}

resource "aws_launch_configuration" "win_lc" {
  count    = "${var.enable_windows}"

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.bastion_external.id}", "${aws_security_group.bastion_internal.id}"]
  image_id                    = "${var.windows_ami_id}"
  instance_type               = "${var.windows_instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_instance_profile.id}"
  key_name                    = "${var.key_name}"
  user_data                   = "<powershell>${template_file.bastion_domain_join_ps1.rendered}${template_file.bastion_win_userdata.rendered}</powershell><persist>true</persist>"
  associate_public_ip_address = "false"
  enable_monitoring           = "${var.detailed_monitoring}"
}

## Auto-Scaling Group Configuration
resource "aws_sns_topic" "bastion_asg" {
  name = "${var.name}-${var.envname}-bastion"
}

resource "aws_autoscaling_notification" "bastion_notifications" {
  group_names = [
    "${aws_autoscaling_group.asg.name}",
    "${aws_autoscaling_group.win_asg.name}"
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
  ]

  topic_arn = "${aws_sns_topic.bastion_asg.arn}"
}

resource "aws_autoscaling_group" "asg" {
  count    = "${var.enable_linux}"
  name                = "${var.name}-${var.envname}-bastions"
  availability_zones  = ["${split(",",lookup(var.aws_zones,var.aws_region))}"]
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  launch_configuration = "${aws_launch_configuration.lc.name}"

  min_size = "${length(split(",", lookup(var.aws_zones,var.aws_region)))}"
  max_size = "${length(split(",", lookup(var.aws_zones,var.aws_region)))}"

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.envname}-bastion"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.envname}"
    propagate_at_launch = true
  }

  tag {
    key                 = "EnvType"
    value               = "${var.envtype}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Service"
    value               = "${var.profile}"
    propagate_at_launch = true
  }

  tag {
    key                 = "expected_EIPs"
    value               = "${join(",", aws_eip.bastion_eip.*.public_ip)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "private_subnets"
    value               = "${join(",", aws_subnet.private.*.id)}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "win_asg" {
  count               = "${var.enable_windows}"
  name                = "${var.name}-${var.envname}-bastions-win"
  availability_zones  = ["${split(",",lookup(var.aws_zones,var.aws_region))}"]
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  launch_configuration = "${aws_launch_configuration.win_lc.name}"

  min_size = "${length(split(",", lookup(var.aws_zones,var.aws_region)))}"
  max_size = "${length(split(",", lookup(var.aws_zones,var.aws_region)))}"

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.envname}-bastion-win"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.envname}"
    propagate_at_launch = true
  }

  tag {
    key                 = "EnvType"
    value               = "${var.envtype}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Service"
    value               = "${var.profile}"
    propagate_at_launch = true
  }

  tag {
    key                 = "expected_EIPs"
    value               = "${join(",", aws_eip.bastion_eip.*.public_ip)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "private_subnets"
    value               = "${join(",", aws_subnet.private.*.id)}"
    propagate_at_launch = true
  }
}
