# aws-terraform-ec2_asg

This module creates one or more autoscaling groups.

## Basic Usage

```
module "asg" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg//?ref=v0.0.2"

 ec2_os              = "amazon"
 subnets             = ["${module.vpc.private_subnets}"]
 image_id            = "${var.image_id}"
 resource_name       = "my_asg"
 security_group_list = ["${module.sg.private_web_security_group_id}"]
}
```

Full working references are available at [examples](examples)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tags | Additional tags to be added to the ASG instance(s). Format: list of maps. Please see usage.tf.example in this repo for examples. | list | `<list>` | no |
| addtional_ssm_bootstrap_list | A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples. | list | `<list>` | no |
| addtional_ssm_bootstrap_step_count | Count of steps added for input 'addtional_ssm_bootstrap_list'. This is required since 'addtional_ssm_bootstrap_list' is a list of maps | string | `0` | no |
| asg_count | Number of identical ASG's to deploy | string | `1` | no |
| asg_wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. | string | `10m` | no |
| backup_tag_value | Value of the 'Backup' tag, used to assign te EBSSnapper configuration | string | `False` | no |
| cloudwatch_log_retention | The number of days to retain Cloudwatch Logs for this instance. | string | `30` | no |
| custom_alarm_sns_topic | If not Rackspace managed, you can use custom SNS topics to send the Alarm actions to. | string | `` | no |
| custom_ok_sns_topic | If not Rackspace managed, you can use custom SNS topics to send the OK actions to. | string | `` | no |
| cw_high_evaluations | The number of periods over which data is compared to the specified threshold. | string | `3` | no |
| cw_high_operator | Math operator used by CloudWatch for alarms and triggers. | string | `GreaterThanThreshold` | no |
| cw_high_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | string | `60` | no |
| cw_high_threshold | The value against which the specified statistic is compared. | string | `60` | no |
| cw_low_evaluations | The number of periods over which data is compared to the specified threshold. | string | `3` | no |
| cw_low_operator | Math operator used by CloudWatch for alarms and triggers. | string | `LessThanThreshold` | no |
| cw_low_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | string | `300` | no |
| cw_low_threshold | The value against which the specified statistic is compared. | string | `30` | no |
| cw_scaling_metric | The metric to be used for scaling. | string | `CPUUtilization` | no |
| detailed_monitoring | Enable Detailed Monitoring? true or false | string | `true` | no |
| ec2_os | Intended Operating System/Distribution of Instance. Valid inputs are ('amazon', 'rhel6', 'rhel7', 'centos6', 'centos7', 'ubuntu14', 'ubuntu16', 'windows2008', 'windows2012R2', 'windows2016') | string | - | yes |
| ec2_scale_down_adjustment | Number of EC2 instances to scale down by at a time. Positive numbers will be converted to negative. | string | `-1` | no |
| ec2_scale_down_cool_down | Time in seconds before any further trigger-related scaling can occur. | string | `60` | no |
| ec2_scale_up_adjustment | Number of EC2 instances to scale up by at a time. | string | `1` | no |
| ec2_scale_up_cool_down | Time in seconds before any further trigger-related scaling can occur. | string | `60` | no |
| enable_custom_alarm_sns_topic | If not Rackspace managed, you can use custom SNS topics to send the Alarm actions to. If you will be providing a custom SNS topic, please set this to true. If not, set to false. | string | `false` | no |
| enable_ebs_optimization | Use EBS Optimized? true or false | string | `false` | no |
| enable_rolling_updates | Should this autoscaling group be targeted by the ASG Instance Replacement tool to ensure all instances are using thelatest launch configuration. | string | `true` | no |
| enable_scaling_notification | true or false. If 'scaling_notification_topic' is set to a non-empty string, this must be set to true. Otherwise, set to false. This variable exists due to a terraform limitation with using count and computed values as conditionals | string | `false` | no |
| encrypt_secondary_ebs_volume | Encrypt secondary EBS Volume? true or false | string | `false` | no |
| environment | Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | string | `Development` | no |
| final_userdata_commands | Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install. | string | `` | no |
| health_check_grace_period | Number of seconds grace during which no autoscaling actions will be taken. | string | `300` | no |
| health_check_type | Define the type of healthcheck for the AutoScaling group. | string | `EC2` | no |
| image_id | The AMI ID to be used to build the EC2 Instance. If not provided, an AMI ID will be queried with an OS specified in variable ec2_os. | string | `` | no |
| initial_userdata_commands | Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install. | string | `` | no |
| install_codedeploy_agent | Install codedeploy agent on instance(s)? true or false | string | `false` | no |
| instance_role_managed_policy_arn_count | The number of policy ARNs provided/set in variable 'instance_role_managed_policy_arns' | string | `0` | no |
| instance_role_managed_policy_arns | List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole'] | list | `<list>` | no |
| instance_type | EC2 Instance Type e.g. 't2.micro' | string | `t2.micro` | no |
| key_pair | Name of an existing EC2 KeyPair to enable SSH access to the instances. | string | `` | no |
| load_balancer_names | A list of Classic load balancers associated with this Auto Scaling group. | list | `<list>` | no |
| perform_ssm_inventory_tag | Determines whether Instance is tracked via System Manager Inventory. | string | `True` | no |
| primary_ebs_volume_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | string | `0` | no |
| primary_ebs_volume_size | EBS Volume Size in GB | string | `60` | no |
| primary_ebs_volume_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | string | `gp2` | no |
| rackspace_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | string | `true` | no |
| resource_name | Name to be used for the provisioned EC2 instance(s), ASG(s), and other resources provisioned in this module | string | - | yes |
| scaling_max | The maximum size of the Auto Scaling group. | string | `2` | no |
| scaling_min | The minimum count of EC2 instances in the Auto Scaling group. | string | `1` | no |
| scaling_notification_topic | SNS Topic ARN to notify if there are any scaling operations. OPTIONAL | string | `` | no |
| secondary_ebs_volume_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | string | `0` | no |
| secondary_ebs_volume_size | EBS Volume Size in GB | string | `` | no |
| secondary_ebs_volume_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | string | `gp2` | no |
| security_group_list | A list (type list, not string) of EC2 security IDs to assign to this resource. | list | - | yes |
| ssm_association_refresh_rate | A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string. | string | `rate(1 day)` | no |
| ssm_patching_group | Group ID to be used by System Manager for Patching | string | `` | no |
| subnets | List of subnets for Application. e.g. ['subnet-8da92df7', 'subnet-9e5dc5f6', 'subnet-497eaf33'] | list | - | yes |
| target_group_arns | A list of Amazon Resource Names (ARN) of target groups to associate with the Auto Scaling group. | list | `<list>` | no |
| tenancy | The placement tenancy for EC2 devices. e.g. host, default, dedicated | string | `default` | no |
| terminated_instances | Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm. | string | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| asg_image_id | Image ID used for EC2 provisioning |
| asg_name_list | List of ASG names |
| iam_role | Name of the created IAM Instance role. |

