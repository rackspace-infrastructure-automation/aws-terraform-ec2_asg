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
| terraform | >= 0.12 |
| aws | >= 2.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| group_terminating_instances | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6 |  |

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/data-sources/ami) |
| [aws_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/autoscaling_group) |
| [aws_autoscaling_notification](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/autoscaling_notification) |
| [aws_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/autoscaling_policy) |
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/data-sources/caller_identity) |
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/cloudwatch_log_group) |
| [aws_cloudwatch_metric_alarm](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/cloudwatch_metric_alarm) |
| [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/iam_instance_profile) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/iam_role_policy_attachment) |
| [aws_launch_configuration](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/launch_configuration) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/data-sources/region) |
| [aws_ssm_association](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/ssm_association) |
| [aws_ssm_document](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/ssm_document) |
| [aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/2.1.0/docs/resources/ssm_parameter) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_ssm\_bootstrap\_list | A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples.<br><br>(DEPRECATED) This variable will be removed in future releases in favor of the `ssm_bootstrap_list` variable. | `list(map(string))` | `[]` | no |
| additional\_tags | Additional tags to be added to the ASG instance(s). Format: list of maps. Please see usage.tf.example in this repo for examples.<br><br>(DEPRECATED) This variable will be removed in future releases in favor of the `tags` and `tags_asg` variables. | `list(map(string))` | `[]` | no |
| alb\_resource\_label | Enter the ALB and Target group in this format : app/load-balancer-name/load-balancer-id/targetgroup/target-group-name/target-group-id | `string` | `null` | no |
| asg\_count | Number of identical ASG's to deploy | `string` | `"1"` | no |
| asg\_wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. | `string` | `"10m"` | no |
| backup\_tag\_value | Value of the 'Backup' tag, used to assign to the AWS Backup configuration | `string` | `"False"` | no |
| cloudwatch\_log\_retention | The number of days to retain Cloudwatch Logs for this instance. | `string` | `"30"` | no |
| custom\_cw\_agent\_config\_ssm\_param | SSM Parameter Store name that contains a custom CloudWatch agent configuration that you would like to use as an alternative to the default provided. | `string` | `""` | no |
| customer\_alarms\_cleared | Specifies whether alarms will notify customers when returning to an OK status. | `bool` | `false` | no |
| customer\_alarms\_enabled | Specifies whether alarms will notify customers.  Automatically enabled if rackspace\_managed is set to false | `bool` | `false` | no |
| cw\_high\_evaluations | The number of periods over which data is compared to the specified threshold. | `string` | `"3"` | no |
| cw\_high\_operator | Math operator used by CloudWatch for alarms and triggers. | `string` | `"GreaterThanThreshold"` | no |
| cw\_high\_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `string` | `"60"` | no |
| cw\_high\_threshold | The value against which the specified statistic is compared. | `string` | `"60"` | no |
| cw\_low\_evaluations | The number of periods over which data is compared to the specified threshold. | `string` | `"3"` | no |
| cw\_low\_operator | Math operator used by CloudWatch for alarms and triggers. | `string` | `"LessThanThreshold"` | no |
| cw\_low\_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | `string` | `"300"` | no |
| cw\_low\_threshold | The value against which the specified statistic is compared. | `string` | `"30"` | no |
| cw\_scaling\_metric | The metric to be used for scaling. | `string` | `"CPUUtilization"` | no |
| detailed\_monitoring | Enable Detailed Monitoring? true or false | `bool` | `true` | no |
| disable\_scale\_in | Disable scale in to create only a scale-out policy in Target Tracking Policy. | `bool` | `false` | no |
| ec2\_os | Intended Operating System/Distribution of Instance. Valid inputs are: `amazon2`, `amazoneks`, `amazonecs`, `rhel7`, `rhel8`, `centos7`, `ubuntu18`, `ubuntu20`, `windows2012r2`, `windows2016`, `windows2019` | `string` | n/a | yes |
| ec2\_scale\_down\_adjustment | Number of EC2 instances to scale down by at a time. Positive numbers will be converted to negative. | `string` | `"-1"` | no |
| ec2\_scale\_down\_cool\_down | Time in seconds before any further trigger-related scaling can occur. | `string` | `"60"` | no |
| ec2\_scale\_up\_adjustment | Number of EC2 instances to scale up by at a time. | `string` | `"1"` | no |
| ec2\_scale\_up\_cool\_down | Time in seconds before any further trigger-related scaling can occur. | `string` | `"60"` | no |
| enable\_ebs\_optimization | Use EBS Optimized? true or false | `bool` | `false` | no |
| enable\_rolling\_updates | Should this autoscaling group be targeted by the ASG Instance Replacement tool to ensure all instances are using thelatest launch configuration. | `bool` | `true` | no |
| enable\_scaling\_actions | Should this autoscaling group be configured with scaling alarms to manage the desired count.  Set this variable to false if another process will manage the desired count, such as EKS Cluster Autoscaler. | `bool` | `true` | no |
| enable\_scaling\_notification | true or false. If 'scaling\_notification\_topic' is set to a non-empty string, this must be set to true. Otherwise, set to false. This variable exists due to a terraform limitation with using count and computed values as conditionals | `bool` | `false` | no |
| enabled\_asg\_metrics | List of ASG metrics desired.  This can only contain the following values: `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances`. | `list(string)` | `[]` | no |
| encrypt\_primary\_ebs\_volume | Encrypt root EBS Volume? true or false | `bool` | `false` | no |
| encrypt\_secondary\_ebs\_volume | Encrypt secondary EBS Volume? true or false | `bool` | `false` | no |
| environment | Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | `string` | `"Development"` | no |
| final\_userdata\_commands | Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install. | `string` | `""` | no |
| health\_check\_grace\_period | Number of seconds grace during which no autoscaling actions will be taken. | `string` | `"300"` | no |
| health\_check\_type | Define the type of healthcheck for the AutoScaling group. | `string` | `"EC2"` | no |
| image\_id | The AMI ID to be used to build the EC2 Instance. If not provided, an AMI ID will be queried with an OS specified in variable ec2\_os. | `string` | `""` | no |
| initial\_userdata\_commands | Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install. | `string` | `""` | no |
| install\_codedeploy\_agent | Install codedeploy agent on instance(s)? true or false | `bool` | `false` | no |
| instance\_profile\_override | Optionally provide an instance profile. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required. | `bool` | `false` | no |
| instance\_profile\_override\_name | Provide an instance profile name. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required. To use this set `instance_profile_override` to `true`. | `string` | `""` | no |
| instance\_role\_managed\_policy\_arn\_count | The number of policy ARNs provided/set in variable 'instance\_role\_managed\_policy\_arns' | `string` | `"0"` | no |
| instance\_role\_managed\_policy\_arns | List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole'] | `list(string)` | `[]` | no |
| instance\_type | EC2 Instance Type e.g. 't2.micro' | `string` | `"t2.micro"` | no |
| instance\_warm\_up\_time | Specify the Instance Warm Up time for Target Tracking Policy. | `string` | `"300"` | no |
| key\_pair | Name of an existing EC2 KeyPair to enable SSH access to the instances. | `string` | `""` | no |
| load\_balancer\_names | A list of Classic load balancers associated with this Auto Scaling group. | `list(string)` | `[]` | no |
| name | Name to be used for the provisioned EC2 instance(s), ASG(s), and other resources provisioned in this module | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | `list(string)` | `[]` | no |
| perform\_ssm\_inventory\_tag | Determines whether Instance is tracked via System Manager Inventory. | `string` | `"True"` | no |
| policy\_type | Enter scaling policy type. Allowed values are : SimpleScaling or TargetTrackingScaling | `string` | `"SimpleScaling"` | no |
| primary\_ebs\_volume\_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | `string` | `"0"` | no |
| primary\_ebs\_volume\_size | EBS Volume Size in GB | `string` | `"60"` | no |
| primary\_ebs\_volume\_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | `string` | `"gp2"` | no |
| provide\_custom\_cw\_agent\_config | Set to true if a custom cloudwatch agent configuration has been provided in variable custom\_cw\_agent\_config\_ssm\_param. | `bool` | `false` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false. | `bool` | `false` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| scaling\_max | The maximum size of the Auto Scaling group. | `string` | `"2"` | no |
| scaling\_min | The minimum count of EC2 instances in the Auto Scaling group. | `string` | `"1"` | no |
| scaling\_notification\_topic | SNS Topic ARN to notify if there are any scaling operations. OPTIONAL | `string` | `""` | no |
| secondary\_ebs\_volume\_existing\_id | The Snapshot ID of an existing EBS volume you want to use for the secondary volume. i.e. snap-0ad8580e3ac34a9f1 | `string` | `""` | no |
| secondary\_ebs\_volume\_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | `string` | `"0"` | no |
| secondary\_ebs\_volume\_size | EBS Volume Size in GB | `string` | `""` | no |
| secondary\_ebs\_volume\_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | `string` | `"gp2"` | no |
| security\_groups | A list of EC2 security IDs to assign to this resource. | `list(string)` | n/a | yes |
| ssm\_association\_refresh\_rate | A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string. | `string` | `"rate(1 day)"` | no |
| ssm\_bootstrap\_list | A list of objects consisting of actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples. | `any` | `[]` | no |
| ssm\_patching\_group | Group ID to be used by System Manager for Patching | `string` | `""` | no |
| subnets | List of subnets for Application. e.g. ['subnet-8da92df7', 'subnet-9e5dc5f6', 'subnet-497eaf33'] | `list(string)` | n/a | yes |
| tags | A map of tags to apply to all resources.  These tags will all be propagated to ASG instances and set on all other resources. | `map(string)` | `{}` | no |
| tags\_asg | A map of tags to apply to the ASG itself.  These tags will not be propagated to ASG instances or set on any other resources. | `map(string)` | `{}` | no |
| target\_group\_arns | A list of Amazon Resource Names (ARN) of target groups to associate with the Auto Scaling group. | `list(string)` | `[]` | no |
| target\_value | Enter the target value for Target Scaling Policy metrics. | `string` | `"50"` | no |
| tenancy | The placement tenancy for EC2 devices. e.g. host, default, dedicated | `string` | `"default"` | no |
| terminated\_instances | Specifies the maximum number of instances that can be terminated in a six hour period without generating a Cloudwatch Alarm. | `string` | `"30"` | no |
| tracking\_policy\_metric | Allowed Values are: ASGAverageCPUUtilization, ASGAverageNetworkIn, ASGAverageNetworkOut, ALBRequestCountPerTarget | `string` | `"ASGAverageCPUUtilization"` | no |

## Outputs

| Name | Description |
|------|-------------|
| asg\_arn\_list | List of ASG ARNs |
| asg\_image\_id | Image ID used for EC2 provisioning |
| asg\_name\_list | List of ASG names |
| iam\_role | Name of the created IAM Instance role. |
