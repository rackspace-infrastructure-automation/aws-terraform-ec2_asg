# aws-terraform-ec2\_asg

This module creates one or more autoscaling groups.

## Basic Usage

```HCL
module "asg" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg//?ref=v0.12.16"

  ec2_os          = "amazon2"
  name            = "my_asg"
  security_groups = [module.sg.private_web_security_group_id]
  subnets         = module.vpc.private_subnets
}
```

Full working references are available at [examples](examples)

## Other TF Modules Used

Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
- group\_terminating\_instances

## Terraform 0.12 upgrade

Several changes were required while adding terraform 0.12 compatibility.  The following changes should
made when upgrading from a previous release to version 0.12.0 or higher.

### Module variables

The following module variables were updated to better meet current Rackspace style guides:

- `security_group_list` -> `security_groups`
- `resource_name` -> `name`

The following variables are no longer neccessary and were removed

- `additional_ssm_bootstrap_step_count`
- `install_scaleft_agent`

Several new variables were introduced to provide existing functionality, with a simplified format.  The original formmating was also retained to allow easier transition.

New variables `tags` and `tags_asg` were added to replace the functionality of the `additional_tags` variable.  `tags` allows setting tags on all resources, while `tags_asg` sets tags only on the ASG itself.  `additional_tags` will continue to work as expected, but will be removed in a future release.

New variable `ssm_bootstrap_list` was added to allow setting the SSM association steps using objects instead of strings, allowing easier linting and formatting of these lines.  The `additional_ssm_bootstrap_list` variable will continue to work, but will be deprecated in a future release.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_group_terminating_instances"></a> [group\_terminating\_instances](#module\_group\_terminating\_instances) | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm// | v0.12.6 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.autoscalegrp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_notification.rs_support_emergency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_notification) | resource |
| [aws_autoscaling_notification.scaling_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_notification) | resource |
| [aws_autoscaling_policy.ec2_scale_down_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.ec2_scale_up_down_target_tracking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.ec2_scale_up_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_log_group.application_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.system_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.scale_alarm_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.scale_alarm_low](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.instance_role_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.create_instance_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.mod_ec2_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_ad_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_additonal_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_codedeploy_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_core_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_cw_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_instance_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.launch_template_with_no_secondary_ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.launch_template_with_secondary_ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_association.ssm_bootstrap_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association) | resource |
| [aws_ssm_document.ssm_bootstrap_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_ssm_parameter.cwagentparam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.asg_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.mod_ec2_assume_role_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mod_ec2_instance_role_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ssm_bootstrap_list"></a> [additional\_ssm\_bootstrap\_list](#input\_additional\_ssm\_bootstrap\_list) | A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples.<br><br>(DEPRECATED) This variable will be removed in future releases in favor of the `ssm_bootstrap_list` variable. | `list(map(string))` | `[]` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to be added to the ASG instance(s). Format: list of maps. Please see usage.tf.example in this repo for examples.<br><br>(DEPRECATED) This variable will be removed in future releases in favor of the `tags` and `tags_asg` variables. | `list(map(string))` | `[]` | no |
| <a name="input_alb_resource_label"></a> [alb\_resource\_label](#input\_alb\_resource\_label) | Enter the ALB and Target group in this format : app/load-balancer-name/load-balancer-id/targetgroup/target-group-name/target-group-id | `string` | `null` | no |
| <a name="input_asg_count"></a> [asg\_count](#input\_asg\_count) | Number of identical ASG's to deploy | `string` | `"1"` | no |
| <a name="input_asg_wait_for_capacity_timeout"></a> [asg\_wait\_for\_capacity\_timeout](#input\_asg\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. | `string` | `"10m"` | no |
| <a name="input_backup_tag_value"></a> [backup\_tag\_value](#input\_backup\_tag\_value) | Value of the 'Backup' tag, used to assign to the AWS Backup configuration | `string` | `"False"` | no |
| <a name="input_cloudwatch_log_retention"></a> [cloudwatch\_log\_retention](#input\_cloudwatch\_log\_retention) | The number of days to retain Cloudwatch Logs for this instance. | `string` | `"30"` | no |
| <a name="input_custom_cw_agent_config_ssm_param"></a> [custom\_cw\_agent\_config\_ssm\_param](#input\_custom\_cw\_agent\_config\_ssm\_param) | SSM Parameter Store name that contains a custom CloudWatch agent configuration that you would like to use as an alternative to the default provided. | `string` | `""` | no |
| <a name="input_customer_alarms_cleared"></a> [customer\_alarms\_cleared](#input\_customer\_alarms\_cleared) | Specifies whether alarms will notify customers when returning to an OK status. | `bool` | `false` | no |
| <a name="input_customer_alarms_enabled"></a> [customer\_alarms\_enabled](#input\_customer\_alarms\_enabled) | Specifies whether alarms will notify customers.  Automatically enabled if rackspace\_managed is set to false | `bool` | `false` | no |
| <a name="input_cw_high_evaluations"></a> [cw\_high\_evaluations](#input\_cw\_high\_evaluations) | The number of periods over which data is compared to the specified threshold. | `string` | `"3"` | no |
| <a name="input_cw_high_operator"></a> [cw\_high\_operator](#input\_cw\_high\_operator) | Math operator used by CloudWatch for alarms and triggers. | `string` | `"GreaterThanThreshold"` | no |
| <a name="input_cw_high_period"></a> [cw\_high\_period](#input\_cw\_high\_period) | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `string` | `"60"` | no |
| <a name="input_cw_high_threshold"></a> [cw\_high\_threshold](#input\_cw\_high\_threshold) | The value against which the specified statistic is compared. | `string` | `"60"` | no |
| <a name="input_cw_low_evaluations"></a> [cw\_low\_evaluations](#input\_cw\_low\_evaluations) | The number of periods over which data is compared to the specified threshold. | `string` | `"3"` | no |
| <a name="input_cw_low_operator"></a> [cw\_low\_operator](#input\_cw\_low\_operator) | Math operator used by CloudWatch for alarms and triggers. | `string` | `"LessThanThreshold"` | no |
| <a name="input_cw_low_period"></a> [cw\_low\_period](#input\_cw\_low\_period) | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `string` | `"300"` | no |
| <a name="input_cw_low_threshold"></a> [cw\_low\_threshold](#input\_cw\_low\_threshold) | The value against which the specified statistic is compared. | `string` | `"30"` | no |
| <a name="input_cw_scaling_metric"></a> [cw\_scaling\_metric](#input\_cw\_scaling\_metric) | The metric to be used for scaling. | `string` | `"CPUUtilization"` | no |
| <a name="input_detailed_monitoring"></a> [detailed\_monitoring](#input\_detailed\_monitoring) | Enable Detailed Monitoring? true or false | `bool` | `true` | no |
| <a name="input_disable_scale_in"></a> [disable\_scale\_in](#input\_disable\_scale\_in) | Disable scale in to create only a scale-out policy in Target Tracking Policy. | `bool` | `false` | no |
| <a name="input_ec2_os"></a> [ec2\_os](#input\_ec2\_os) | Intended Operating System/Distribution of Instance. Valid inputs are: `amazon2`, `amazoneks`, `amazonecs`, `rhel7`, `rhel8`, `centos7`, `ubuntu18`, `ubuntu20`, `windows2012r2`, `windows2016`, `windows2019` | `string` | n/a | yes |
| <a name="input_ec2_scale_down_adjustment"></a> [ec2\_scale\_down\_adjustment](#input\_ec2\_scale\_down\_adjustment) | Number of EC2 instances to scale down by at a time. Positive numbers will be converted to negative. | `string` | `"-1"` | no |
| <a name="input_ec2_scale_down_cool_down"></a> [ec2\_scale\_down\_cool\_down](#input\_ec2\_scale\_down\_cool\_down) | Time in seconds before any further trigger-related scaling can occur. | `string` | `"60"` | no |
| <a name="input_ec2_scale_up_adjustment"></a> [ec2\_scale\_up\_adjustment](#input\_ec2\_scale\_up\_adjustment) | Number of EC2 instances to scale up by at a time. | `string` | `"1"` | no |
| <a name="input_ec2_scale_up_cool_down"></a> [ec2\_scale\_up\_cool\_down](#input\_ec2\_scale\_up\_cool\_down) | Time in seconds before any further trigger-related scaling can occur. | `string` | `"60"` | no |
| <a name="input_enable_ebs_optimization"></a> [enable\_ebs\_optimization](#input\_enable\_ebs\_optimization) | Use EBS Optimized? true or false | `bool` | `false` | no |
| <a name="input_enable_rolling_updates"></a> [enable\_rolling\_updates](#input\_enable\_rolling\_updates) | Should this autoscaling group be targeted by the ASG Instance Replacement tool to ensure all instances are using thelatest launch configuration. | `bool` | `true` | no |
| <a name="input_enable_scaling_actions"></a> [enable\_scaling\_actions](#input\_enable\_scaling\_actions) | Should this autoscaling group be configured with scaling alarms to manage the desired count.  Set this variable to false if another process will manage the desired count, such as EKS Cluster Autoscaler. | `bool` | `true` | no |
| <a name="input_enable_scaling_notification"></a> [enable\_scaling\_notification](#input\_enable\_scaling\_notification) | true or false. If 'scaling\_notification\_topic' is set to a non-empty string, this must be set to true. Otherwise, set to false. This variable exists due to a terraform limitation with using count and computed values as conditionals | `bool` | `false` | no |
| <a name="input_enabled_asg_metrics"></a> [enabled\_asg\_metrics](#input\_enabled\_asg\_metrics) | List of ASG metrics desired.  This can only contain the following values: `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`. | `list(string)` | `[]` | no |
| <a name="input_encrypt_primary_ebs_volume"></a> [encrypt\_primary\_ebs\_volume](#input\_encrypt\_primary\_ebs\_volume) | Encrypt root EBS Volume? true or false | `bool` | `false` | no |
| <a name="input_encrypt_secondary_ebs_volume"></a> [encrypt\_secondary\_ebs\_volume](#input\_encrypt\_secondary\_ebs\_volume) | Encrypt secondary EBS Volume? true or false | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | `string` | `"Development"` | no |
| <a name="input_final_userdata_commands"></a> [final\_userdata\_commands](#input\_final\_userdata\_commands) | Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install. | `string` | `""` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Number of seconds grace during which no autoscaling actions will be taken. | `string` | `"300"` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Define the type of healthcheck for the AutoScaling group. | `string` | `"EC2"` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The AMI ID to be used to build the EC2 Instance. If not provided, an AMI ID will be queried with an OS specified in variable ec2\_os. | `string` | `""` | no |
| <a name="input_initial_userdata_commands"></a> [initial\_userdata\_commands](#input\_initial\_userdata\_commands) | Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install. | `string` | `""` | no |
| <a name="input_install_codedeploy_agent"></a> [install\_codedeploy\_agent](#input\_install\_codedeploy\_agent) | Install codedeploy agent on instance(s)? true or false | `bool` | `false` | no |
| <a name="input_instance_profile_override"></a> [instance\_profile\_override](#input\_instance\_profile\_override) | Optionally provide an instance profile. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required. | `bool` | `false` | no |
| <a name="input_instance_profile_override_name"></a> [instance\_profile\_override\_name](#input\_instance\_profile\_override\_name) | Provide an instance profile name. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required. To use this set `instance_profile_override` to `true`. | `string` | `""` | no |
| <a name="input_instance_role_managed_policy_arn_count"></a> [instance\_role\_managed\_policy\_arn\_count](#input\_instance\_role\_managed\_policy\_arn\_count) | The number of policy ARNs provided/set in variable 'instance\_role\_managed\_policy\_arns' | `string` | `"0"` | no |
| <a name="input_instance_role_managed_policy_arns"></a> [instance\_role\_managed\_policy\_arns](#input\_instance\_role\_managed\_policy\_arns) | List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole'] | `list(string)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type e.g. 't2.micro' | `string` | `"t2.micro"` | no |
| <a name="input_instance_warm_up_time"></a> [instance\_warm\_up\_time](#input\_instance\_warm\_up\_time) | Specify the Instance Warm Up time for Target Tracking Policy. | `string` | `"300"` | no |
| <a name="input_key_pair"></a> [key\_pair](#input\_key\_pair) | Name of an existing EC2 KeyPair to enable SSH access to the instances. | `string` | `""` | no |
| <a name="input_load_balancer_names"></a> [load\_balancer\_names](#input\_load\_balancer\_names) | A list of Classic load balancers associated with this Auto Scaling group. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used for the provisioned EC2 instance(s), ASG(s), and other resources provisioned in this module | `string` | n/a | yes |
| <a name="input_notification_topic"></a> [notification\_topic](#input\_notification\_topic) | List of SNS Topic ARNs to use for customer notifications. | `list(string)` | `[]` | no |
| <a name="input_perform_ssm_inventory_tag"></a> [perform\_ssm\_inventory\_tag](#input\_perform\_ssm\_inventory\_tag) | Determines whether Instance is tracked via System Manager Inventory. | `string` | `"True"` | no |
| <a name="input_policy_type"></a> [policy\_type](#input\_policy\_type) | Enter scaling policy type. Allowed values are : SimpleScaling or TargetTrackingScaling | `string` | `"SimpleScaling"` | no |
| <a name="input_primary_ebs_volume_iops"></a> [primary\_ebs\_volume\_iops](#input\_primary\_ebs\_volume\_iops) | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | `string` | `"0"` | no |
| <a name="input_primary_ebs_volume_size"></a> [primary\_ebs\_volume\_size](#input\_primary\_ebs\_volume\_size) | EBS Volume Size in GB | `string` | `"60"` | no |
| <a name="input_primary_ebs_volume_type"></a> [primary\_ebs\_volume\_type](#input\_primary\_ebs\_volume\_type) | EBS Volume Type. e.g. gp2, io1, st1, sc1 | `string` | `"gp2"` | no |
| <a name="input_provide_custom_cw_agent_config"></a> [provide\_custom\_cw\_agent\_config](#input\_provide\_custom\_cw\_agent\_config) | Set to true if a custom cloudwatch agent configuration has been provided in variable custom\_cw\_agent\_config\_ssm\_param. | `bool` | `false` | no |
| <a name="input_rackspace_alarms_enabled"></a> [rackspace\_alarms\_enabled](#input\_rackspace\_alarms\_enabled) | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false. | `bool` | `false` | no |
| <a name="input_rackspace_managed"></a> [rackspace\_managed](#input\_rackspace\_managed) | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| <a name="input_scaling_max"></a> [scaling\_max](#input\_scaling\_max) | The maximum size of the Auto Scaling group. | `string` | `"2"` | no |
| <a name="input_scaling_min"></a> [scaling\_min](#input\_scaling\_min) | The minimum count of EC2 instances in the Auto Scaling group. | `string` | `"1"` | no |
| <a name="input_scaling_notification_topic"></a> [scaling\_notification\_topic](#input\_scaling\_notification\_topic) | SNS Topic ARN to notify if there are any scaling operations. OPTIONAL | `string` | `""` | no |
| <a name="input_secondary_ebs_volume_existing_id"></a> [secondary\_ebs\_volume\_existing\_id](#input\_secondary\_ebs\_volume\_existing\_id) | The Snapshot ID of an existing EBS volume you want to use for the secondary volume. i.e. snap-0ad8580e3ac34a9f1 | `string` | `""` | no |
| <a name="input_secondary_ebs_volume_iops"></a> [secondary\_ebs\_volume\_iops](#input\_secondary\_ebs\_volume\_iops) | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | `string` | `"0"` | no |
| <a name="input_secondary_ebs_volume_size"></a> [secondary\_ebs\_volume\_size](#input\_secondary\_ebs\_volume\_size) | EBS Volume Size in GB | `string` | `""` | no |
| <a name="input_secondary_ebs_volume_type"></a> [secondary\_ebs\_volume\_type](#input\_secondary\_ebs\_volume\_type) | EBS Volume Type. e.g. gp2, io1, st1, sc1 | `string` | `"gp2"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of EC2 security IDs to assign to this resource. | `list(string)` | n/a | yes |
| <a name="input_ssm_association_refresh_rate"></a> [ssm\_association\_refresh\_rate](#input\_ssm\_association\_refresh\_rate) | A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string. | `string` | `"rate(1 day)"` | no |
| <a name="input_ssm_bootstrap_list"></a> [ssm\_bootstrap\_list](#input\_ssm\_bootstrap\_list) | A list of objects consisting of actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples. | `any` | `[]` | no |
| <a name="input_ssm_patching_group"></a> [ssm\_patching\_group](#input\_ssm\_patching\_group) | Group ID to be used by System Manager for Patching | `string` | `""` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets for Application. e.g. ['subnet-8da92df7', 'subnet-9e5dc5f6', 'subnet-497eaf33'] | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources.  These tags will all be propagated to ASG instances and set on all other resources. | `map(string)` | `{}` | no |
| <a name="input_tags_asg"></a> [tags\_asg](#input\_tags\_asg) | A map of tags to apply to the ASG itself.  These tags will not be propagated to ASG instances or set on any other resources. | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A list of Amazon Resource Names (ARN) of target groups to associate with the Auto Scaling group. | `list(string)` | `[]` | no |
| <a name="input_target_value"></a> [target\_value](#input\_target\_value) | Enter the target value for Target Scaling Policy metrics. | `string` | `"50"` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The placement tenancy for EC2 devices. e.g. host, default, dedicated | `string` | `"default"` | no |
| <a name="input_terminated_instances"></a> [terminated\_instances](#input\_terminated\_instances) | Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm. | `string` | `"30"` | no |
| <a name="input_tracking_policy_metric"></a> [tracking\_policy\_metric](#input\_tracking\_policy\_metric) | Allowed Values are: ASGAverageCPUUtilization, ASGAverageNetworkIn, ASGAverageNetworkOut, ALBRequestCountPerTarget | `string` | `"ASGAverageCPUUtilization"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_arn_list"></a> [asg\_arn\_list](#output\_asg\_arn\_list) | List of ASG ARNs |
| <a name="output_asg_image_id"></a> [asg\_image\_id](#output\_asg\_image\_id) | Image ID used for EC2 provisioning |
| <a name="output_asg_name_list"></a> [asg\_name\_list](#output\_asg\_name\_list) | List of ASG names |
| <a name="output_iam_role"></a> [iam\_role](#output\_iam\_role) | Name of the created IAM Instance role. |
