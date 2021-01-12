variable "additional_ssm_bootstrap_list" {
  description = "A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples.<br><br>(DEPRECATED) This variable will be removed in future releases in favor of the `ssm_bootstrap_list` variable."
  type        = list(map(string))
  default     = []
}

variable "additional_tags" {
  description = "Additional tags to be added to the ASG instance(s). Format: list of maps. Please see usage.tf.example in this repo for examples.<br><br>(DEPRECATED) This variable will be removed in future releases in favor of the `tags` and `tags_asg` variables."
  type        = list(map(string))
  default     = []
}

variable "alb_target_value" {
  description = "Enter the target value for 'Application Load Balancer request count per target' metric for Target Tracking Policy."
  type        = string
  default     = "50"
}

variable "asg_count" {
  description = "Number of identical ASG's to deploy"
  type        = string
  default     = "1"
}

variable "asg_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out."
  type        = string
  default     = "10m"
}

variable "backup_tag_value" {
  description = "Value of the 'Backup' tag, used to assign te EBSSnapper configuration"
  type        = string
  default     = "False"
}

variable "cloudwatch_log_retention" {
  description = "The number of days to retain Cloudwatch Logs for this instance."
  type        = string
  default     = "30"
}

variable "cpu_target_value" {
  description = "nter the target value for 'Average CPU Utilization' metric for Target Tracking Policy."
  type        = string
  default     = "50"
}

variable "custom_cw_agent_config_ssm_param" {
  description = "SSM Parameter Store name that contains a custom CloudWatch agent configuration that you would like to use as an alternative to the default provided."
  type        = string
  default     = ""
}

variable "cw_high_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = string
  default     = "3"
}

variable "cw_high_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers."
  type        = string
  default     = "GreaterThanThreshold"
}

variable "cw_high_period" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = string
  default     = "60"
}

variable "cw_high_threshold" {
  description = "The value against which the specified statistic is compared."
  type        = string
  default     = "60"
}

variable "cw_low_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = string
  default     = "3"
}

variable "cw_low_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers."
  type        = string
  default     = "LessThanThreshold"
}

variable "cw_low_period" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = string
  default     = "300"
}

variable "cw_low_threshold" {
  description = "The value against which the specified statistic is compared."
  type        = string
  default     = "30"
}

variable "cw_scaling_metric" {
  description = "The metric to be used for scaling."
  type        = string
  default     = "CPUUtilization"
}

variable "detailed_monitoring" {
  description = "Enable Detailed Monitoring? true or false"
  type        = bool
  default     = true
}

variable "disable_scale_in" {
  description = "Disable scale in to create only a scale-out policy in Target Tracking Policy."
  type        = bool
  default     = false
}

variable "ec2_os" {
  description = "Intended Operating System/Distribution of Instance. Valid inputs are: `amazon`, `amazon2`, `amazoneks`, `amazonecs`, `rhel6`, `rhel7`, `rhel8`, `centos6`, `centos7`, `ubuntu14`, `ubuntu16`, `ubuntu18`, `windows2012r2`, `windows2016`, `windows2019`"
  type        = string
}

variable "ec2_scale_down_adjustment" {
  description = "Number of EC2 instances to scale down by at a time. Positive numbers will be converted to negative."
  type        = string
  default     = "-1"
}

variable "ec2_scale_down_cool_down" {
  description = "Time in seconds before any further trigger-related scaling can occur."
  type        = string
  default     = "60"
}

variable "ec2_scale_up_adjustment" {
  description = "Number of EC2 instances to scale up by at a time."
  type        = string
  default     = "1"
}

variable "ec2_scale_up_cool_down" {
  description = "Time in seconds before any further trigger-related scaling can occur."
  type        = string
  default     = "60"
}

variable "enable_ebs_optimization" {
  description = "Use EBS Optimized? true or false"
  type        = bool
  default     = false
}

variable "enable_rolling_updates" {
  description = "Should this autoscaling group be targeted by the ASG Instance Replacement tool to ensure all instances are using thelatest launch configuration."
  type        = bool
  default     = true
}

variable "enable_scaling_actions" {
  description = "Should this autoscaling group be configured with scaling alarms to manage the desired count.  Set this variable to false if another process will manage the desired count, such as EKS Cluster Autoscaler."
  type        = bool
  default     = true
}

variable "enable_scaling_notification" {
  description = "true or false. If 'scaling_notification_topic' is set to a non-empty string, this must be set to true. Otherwise, set to false. This variable exists due to a terraform limitation with using count and computed values as conditionals"
  type        = bool
  default     = false
}

variable "enabled_asg_metrics" {
  description = "List of ASG metrics desired.  This can only contain the following values: `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`."
  type        = list(string)
  default     = []
}

variable "encrypt_primary_ebs_volume" {
  description = "Encrypt root EBS Volume? true or false"
  type        = bool
  default     = false
}

variable "encrypt_secondary_ebs_volume" {
  description = "Encrypt secondary EBS Volume? true or false"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test"
  type        = string
  default     = "Development"
}

variable "final_userdata_commands" {
  description = "Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install."
  type        = string
  default     = ""
}

variable "health_check_grace_period" {
  description = "Number of seconds grace during which no autoscaling actions will be taken."
  type        = string
  default     = "300"
}

variable "health_check_type" {
  description = "Define the type of healthcheck for the AutoScaling group."
  type        = string
  default     = "EC2"
}

variable "image_id" {
  description = "The AMI ID to be used to build the EC2 Instance. If not provided, an AMI ID will be queried with an OS specified in variable ec2_os."
  type        = string
  default     = ""
}

variable "initial_userdata_commands" {
  description = "Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install."
  type        = string
  default     = ""
}

variable "install_codedeploy_agent" {
  description = "Install codedeploy agent on instance(s)? true or false"
  type        = bool
  default     = false
}

variable "instance_profile_override" {
  description = "Optionally provide an instance profile. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required."
  type        = bool
  default     = false
}

variable "instance_profile_override_name" {
  description = "Provide an instance profile name. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required. To use this set `instance_profile_override` to `true`."
  type        = string
  default     = ""
}

variable "instance_role_managed_policy_arn_count" {
  description = "The number of policy ARNs provided/set in variable 'instance_role_managed_policy_arns'"
  type        = string
  default     = "0"
}

variable "instance_role_managed_policy_arns" {
  description = "List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole']"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "EC2 Instance Type e.g. 't2.micro'"
  type        = string
  default     = "t2.micro"
}

variable "instance_warm_up_time" {
  description = "Specify the Instance Warm Up time for Target Tracking Policy."
  type        = string
  default     = "300"
}

variable "key_pair" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = string
  default     = ""
}

variable "load_balancer_names" {
  description = "A list of Classic load balancers associated with this Auto Scaling group."
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name to be used for the provisioned EC2 instance(s), ASG(s), and other resources provisioned in this module"
  type        = string
}

variable "network_in_target_value" {
  description = "Enter the target value for 'Network In' metric for Target Tracking Policy."
  type        = string
  default     = "50"
}

variable "network_out_target_value" {
  description = "Enter the target value for 'Network Out' metric for Target Tracking Policy."
  type        = string
  default     = "50"
}

variable "notification_topic" {
  description = "List of SNS Topic ARNs to use for customer notifications."
  type        = list(string)
  default     = []
}

variable "perform_ssm_inventory_tag" {
  description = "Determines whether Instance is tracked via System Manager Inventory."
  type        = string
  default     = "True"
}

variable "primary_ebs_volume_iops" {
  description = "Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size"
  type        = string
  default     = "0"
}

variable "primary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = string
  default     = "60"
}

variable "primary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = string
  default     = "gp2"
}

variable "provide_custom_cw_agent_config" {
  description = "Set to true if a custom cloudwatch agent configuration has been provided in variable custom_cw_agent_config_ssm_param."
  type        = bool
  default     = false
}

variable "rackspace_alarms_enabled" {
  description = "Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace_managed is set to false."
  type        = bool
  default     = false
}

variable "rackspace_managed" {
  description = "Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents."
  type        = bool
  default     = true
}

variable "resource_label" {
  description = "Enter the ALB and Target group in this format : app/<load-balancer-name>/<load-balancer-id>/targetgroup/<target-group-name>/<target-group-id>. If Target Tracking Policy getting configure with 'Application Load Balancer request count per target' metric, then this option is must to use."
  type        = string
  default     = ""
}

variable "scaling_max" {
  description = "The maximum size of the Auto Scaling group."
  type        = string
  default     = "2"
}

variable "scaling_min" {
  description = "The minimum count of EC2 instances in the Auto Scaling group."
  type        = string
  default     = "1"
}

variable "scaling_notification_topic" {
  description = "SNS Topic ARN to notify if there are any scaling operations. OPTIONAL"
  type        = string
  default     = ""
}

variable "secondary_ebs_volume_existing_id" {
  description = "The Snapshot ID of an existing EBS volume you want to use for the secondary volume. i.e. snap-0ad8580e3ac34a9f1"
  type        = string
  default     = ""
}

variable "secondary_ebs_volume_iops" {
  description = "Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size"
  type        = string
  default     = "0"
}

variable "secondary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = string
  default     = ""
}

variable "secondary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = string
  default     = "gp2"
}

variable "security_groups" {
  description = "A list of EC2 security IDs to assign to this resource."
  type        = list(string)
}

variable "ssm_association_refresh_rate" {
  description = "A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string."
  type        = string
  default     = "rate(1 day)"
}

variable "ssm_bootstrap_list" {
  description = "A list of objects consisting of actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples."
  type        = any
  default     = []
}

variable "ssm_patching_group" {
  description = "Group ID to be used by System Manager for Patching"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "List of subnets for Application. e.g. ['subnet-8da92df7', 'subnet-9e5dc5f6', 'subnet-497eaf33']"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to apply to all resources.  These tags will all be propagated to ASG instances and set on all other resources."
  type        = map(string)
  default     = {}
}

variable "tags_asg" {
  description = "A map of tags to apply to the ASG itself.  These tags will not be propagated to ASG instances or set on any other resources."
  type        = map(string)
  default     = {}
}

variable "target_group_arns" {
  description = "A list of Amazon Resource Names (ARN) of target groups to associate with the Auto Scaling group."
  type        = list(string)
  default     = []
}

variable "tenancy" {
  description = "The placement tenancy for EC2 devices. e.g. host, default, dedicated"
  type        = string
  default     = "default"
}

variable "terminated_instances" {
  description = "Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm."
  type        = string
  default     = "30"
}

variable "tracking_policy_alb" {
  description = "Configure Target Tracking Policy with 'ALB Request Count Per Target' metric. If you are using this option make sure you set this 'enable_scaling_actions' option as 'false'. Also you would need to pass 'resource_label' option to pass the Load Balancer information."
  type        = bool
  default     = false
}

variable "tracking_policy_cpu" {
  description = "Configure Target Tracking Policy with 'Average CPU Utilization' metric. If you are using this option make sure you set this 'enable_scaling_actions' option as 'false'."
  type        = bool
  default     = false
}

variable "tracking_policy_network_in" {
  description = "Configure Target Tracking Policy with 'Average Network In' metric. If you are using this option make sure you set this 'enable_scaling_actions' option as 'false'."
  type        = bool
  default     = false
}

variable "tracking_policy_network_out" {
  description = "Configure Target Tracking Policy with 'Average Network Out' metric. If you are using this option make sure you set this 'enable_scaling_actions' option as 'false'."
  type        = bool
  default     = false
}