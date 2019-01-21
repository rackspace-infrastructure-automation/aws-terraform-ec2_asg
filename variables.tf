#
# Instance/ASG Attributes
#

variable "additional_tags" {
  description = "Additional tags to be added to the ASG instance(s). Format: list of maps. Please see usage.tf.example in this repo for examples."
  type        = "list"
  default     = []
}

variable "asg_count" {
  description = "Number of identical ASG's to deploy"
  type        = "string"
  default     = "1"
}

variable "asg_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out."
  type        = "string"
  default     = "10m"
}

variable "detailed_monitoring" {
  description = "Enable Detailed Monitoring? true or false"
  type        = "string"
  default     = true
}

variable "ec2_os" {
  description = "Intended Operating System/Distribution of Instance. Valid inputs are ('amazon', 'rhel6', 'rhel7', 'centos6', 'centos7', 'ubuntu14', 'ubuntu16', 'windows2008', 'windows2012R2', 'windows2016')"
  type        = "string"
}

variable "enable_rolling_updates" {
  description = "Should this autoscaling group be targeted by the ASG Instance Replacement tool to ensure all instances are using thelatest launch configuration."
  type        = "string"
  default     = true
}

variable "environment" {
  description = "Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test"
  type        = "string"
  default     = "Development"
}

variable "health_check_type" {
  description = "Define the type of healthcheck for the AutoScaling group."
  type        = "string"
  default     = "EC2"
}

variable "image_id" {
  description = "The AMI ID to be used to build the EC2 Instance. If not provided, an AMI ID will be queried with an OS specified in variable ec2_os."
  type        = "string"
  default     = ""
}

variable "install_codedeploy_agent" {
  description = "Install codedeploy agent on instance(s)? true or false"
  type        = "string"
  default     = false
}

variable "instance_type" {
  description = "EC2 Instance Type e.g. 't2.micro'"
  type        = "string"
  default     = "t2.micro"
}

variable "key_pair" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = "string"
  default     = ""
}

variable "resource_name" {
  description = "Name to be used for the provisioned EC2 instance(s), ASG(s), and other resources provisioned in this module"
  type        = "string"
}

variable "scaling_max" {
  description = "The maximum size of the Auto Scaling group."
  type        = "string"
  default     = "2"
}

variable "scaling_min" {
  description = "The minimum count of EC2 instances in the Auto Scaling group."
  type        = "string"
  default     = "1"
}

variable "security_group_list" {
  description = "A list (type list, not string) of EC2 security IDs to assign to this resource."
  type        = "list"
}

variable "tenancy" {
  description = "The placement tenancy for EC2 devices. e.g. host, default, dedicated"
  type        = "string"
  default     = "default"
}

#
# Scaling
#

variable "ec2_scale_down_cool_down" {
  description = "Time in seconds before any further trigger-related scaling can occur."
  type        = "string"
  default     = "60"
}

variable "ec2_scale_down_adjustment" {
  description = "Number of EC2 instances to scale down by at a time. Positive numbers will be converted to negative."
  type        = "string"
  default     = "-1"
}

variable "ec2_scale_up_adjustment" {
  description = "Number of EC2 instances to scale up by at a time."
  type        = "string"
  default     = "1"
}

variable "ec2_scale_up_cool_down" {
  description = "Time in seconds before any further trigger-related scaling can occur."
  type        = "string"
  default     = "60"
}

variable "health_check_grace_period" {
  description = "Number of seconds grace during which no autoscaling actions will be taken."
  type        = "string"
  default     = "300"
}

variable "enable_scaling_notification" {
  description = "true or false. If 'scaling_notification_topic' is set to a non-empty string, this must be set to true. Otherwise, set to false. This variable exists due to a terraform limitation with using count and computed values as conditionals"
  type        = "string"
  default     = false
}

variable "scaling_notification_topic" {
  description = "SNS Topic ARN to notify if there are any scaling operations. OPTIONAL"
  type        = "string"
  default     = ""
}

#
# EC2 Network
#

variable "subnets" {
  description = "List of subnets for Application. e.g. ['subnet-8da92df7', 'subnet-9e5dc5f6', 'subnet-497eaf33']"
  type        = "list"
}

#
# EBS Attributes
#
variable "backup_tag_value" {
  description = "Value of the 'Backup' tag, used to assign te EBSSnapper configuration"
  type        = "string"
  default     = "False"
}

variable "enable_ebs_optimization" {
  description = "Use EBS Optimized? true or false"
  type        = "string"
  default     = false
}

variable "encrypt_secondary_ebs_volume" {
  description = "Encrypt secondary EBS Volume? true or false"
  type        = "string"
  default     = false
}

variable "primary_ebs_volume_iops" {
  description = "Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size"
  type        = "string"
  default     = "0"
}

variable "primary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = "string"
  default     = "60"
}

variable "primary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = "string"
  default     = "gp2"
}

variable "secondary_ebs_volume_iops" {
  description = "Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size"
  type        = "string"
  default     = "0"
}

variable "secondary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = "string"
  default     = ""
}

variable "secondary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = "string"
  default     = "gp2"
}

#
# Load Balancing and Target groups
#

variable "load_balancer_names" {
  description = "A list of Classic load balancers associated with this Auto Scaling group."
  type        = "list"
  default     = []
}

variable "target_group_arns" {
  description = "A list of Amazon Resource Names (ARN) of target groups to associate with the Auto Scaling group."
  type        = "list"
  default     = []
}

#
# Roles and Policies
#

variable "instance_profile_override" {
  description = "Optionally provide an instance profile. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required."
  type        = "string"
  default     = false
}

variable "instance_profile_override_name" {
  description = "Provide an instance profile name. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required. To use this set `instance_profile_override` to `true`."
  type        = "string"
  default     = ""
}

variable "instance_role_managed_policy_arns" {
  description = "List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole']"
  type        = "list"
  default     = []
}

variable "instance_role_managed_policy_arn_count" {
  description = "The number of policy ARNs provided/set in variable 'instance_role_managed_policy_arns'"
  type        = "string"
  default     = "0"
}

#
# SSM and Associations
#

variable "addtional_ssm_bootstrap_list" {
  description = "A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples."
  type        = "list"
  default     = []
}

variable "addtional_ssm_bootstrap_step_count" {
  description = "Count of steps added for input 'addtional_ssm_bootstrap_list'. This is required since 'addtional_ssm_bootstrap_list' is a list of maps"
  type        = "string"
  default     = "0"
}

variable "perform_ssm_inventory_tag" {
  description = "Determines whether Instance is tracked via System Manager Inventory."
  type        = "string"
  default     = "True"
}

variable "ssm_association_refresh_rate" {
  description = "A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string."
  type        = "string"
  default     = "rate(1 day)"
}

variable "ssm_patching_group" {
  description = "Group ID to be used by System Manager for Patching"
  type        = "string"
  default     = ""
}

#
# CloudWatch and Logs
#

variable "cloudwatch_log_retention" {
  description = "The number of days to retain Cloudwatch Logs for this instance."
  type        = "string"
  default     = "30"
}

variable "cw_high_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = "string"
  default     = "3"
}

variable "cw_high_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers."
  type        = "string"
  default     = "GreaterThanThreshold"
}

variable "cw_high_period" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = "string"
  default     = "60"
}

variable "cw_high_threshold" {
  description = "The value against which the specified statistic is compared."
  type        = "string"
  default     = "60"
}

variable "cw_low_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = "string"
  default     = "3"
}

variable "cw_low_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers."
  type        = "string"
  default     = "LessThanThreshold"
}

variable "cw_low_period" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = "string"
  default     = "300"
}

variable "cw_low_threshold" {
  description = "The value against which the specified statistic is compared."
  type        = "string"
  default     = "30"
}

variable "cw_scaling_metric" {
  description = "The metric to be used for scaling."
  type        = "string"
  default     = "CPUUtilization"
}

variable "notification_topic" {
  description = "List of SNS Topic ARNs to use for customer notifications."
  type        = "list"
  default     = []
}

variable "rackspace_managed" {
  description = "Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents."
  type        = "string"
  default     = true
}

variable "rackspace_alarms_enabled" {
  description = "Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace_managed is set to false."
  type        = "string"
  default     = false
}

variable "terminated_instances" {
  description = "Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm."
  type        = "string"
  default     = "30"
}

variable "initial_userdata_commands" {
  description = "Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install."
  type        = "string"
  default     = ""
}

variable "final_userdata_commands" {
  description = "Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install."
  type        = "string"
  default     = ""
}

variable "provide_custom_cw_agent_config" {
  description = "Set to true if a custom cloudwatch agent configuration has been provided in variable custom_cw_agent_config_ssm_param."
  type        = "string"
  default     = false
}

variable "custom_cw_agent_config_ssm_param" {
  description = "SSM Parameter Store name that contains a custom CloudWatch agent configuration that you would like to use as an alternative to the default provided."
  type        = "string"
  default     = ""
}
