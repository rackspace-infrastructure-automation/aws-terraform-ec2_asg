output "asg_name_list" {
  description = "List of ASG names"
  value       = ["${aws_autoscaling_group.autoscalegrp.*.name}"]
}

output "iam_role" {
  description = "Name of the created IAM Instance role."
  value       = "${element(coalescelist(aws_iam_role.mod_ec2_instance_role.*.id, list("none")), 0)}"
}

output "asg_image_id" {
  description = "Image ID used for EC2 provisioning"
  value       = "${var.image_id != "" ? var.image_id : data.aws_ami.asg_ami.image_id}"
}
