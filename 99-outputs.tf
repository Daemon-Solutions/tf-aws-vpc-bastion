## VPC Ouputs
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "availability_zones" {
  value = ["${aws_subnet.public.*.availability_zone}"]
}

## Subnet Outputs
output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_route_tables" {
  value = ["${aws_route_table.public.*.id}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "private_route_tables" {
  value = ["${aws_route_table.private.*.id}"]
}

## Userdata Ouputs
output "bastion_userdata_redndered" {
  value = "${template_file.bastion_userdata.rendered}"
}

## IAM Outputs
output "bastion_iam_profile_id" {
  value = "${aws_iam_instance_profile.bastion_instance_profile.id}"
}

output "bastion_iam_role_id" {
  value = "${aws_iam_role.bastion_role.id}"
}

## EIP Outputs
output "bastion_eip_ids" {
  value = ["${aws_eip.bastion_eip.*.id}"]
}

output "bastion_eips" {
  value = ["${aws_eip.bastion_eip.*.public_ip}"]
}

## Launch Config Outputs
output "launch_config_id" {
  value = "${aws_launch_configuration.lc.id}"
}

## Autoscaling Group Outputs
output "asg_id" {
  value = "${aws_autoscaling_group.asg.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.asg.name}"
}

## Lambda Outputs
output "lambda_arn" {
  value = "aws_lambda_function.attach_eip.arn"
}

output "lambda_iam_role_id" {
  value = "${aws_iam_role.bastion_lambda_role.id}"
}

## SNS Outputs
output "bastion_sns_arn" {
  value = "${aws_sns_topic.bastion_asg.arn}"
}

output "bastion_sns_id" {
  value = "${aws_sns_topic.bastion_asg.id}"
}

output "bastion_sns_subscription_arn" {
  value = "${aws_sns_topic_subscription.bastion_asg.arn}"
}

output "bastion_sns_subscription_id" {
  value = "${aws_sns_topic_subscription.bastion_asg.id}"
}

## Security Group Outputs
output "bastion_external_sg_id" {
  value = "${aws_security_group.bastion_external.id}"
}

output "bastion_internal_sg_id" {
  value = "${aws_security_group.bastion_internal.id}"
}
