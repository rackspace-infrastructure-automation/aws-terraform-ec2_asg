output "asg_name_list" {
  description = "List of ASG names"
  value       = ["${aws_autoscaling_group.autoscalegrp.*.name}"]
}

output "iam_role" {
  description = "Name of the created IAM Instance role."
  value       = "${aws_iam_role.mod_ec2_instance_role.id}"
}
