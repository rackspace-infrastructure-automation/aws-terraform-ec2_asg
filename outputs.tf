output "asg_name_list" {
  description = "List of ASG names"
  value       = ["${aws_autoscaling_group.autoscalegrp.*.name}"]
}
