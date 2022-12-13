/**
 * # aws-terraform-ec2_asg
 *
 * This module creates one or more autoscaling groups.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "asg" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg//?ref=v0.12.16"
 *
 *   ec2_os          = "amazon2"
 *   name            = "my_asg"
 *   security_groups = [module.sg.private_web_security_group_id]
 *   subnets         = module.vpc.private_subnets
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 *
 * ## Other TF Modules Used
 *
 * Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 * - group_terminating_instances
 *
 * ## Terraform 0.12 upgrade
 *
 * Several changes were required while adding terraform 0.12 compatibility.  The following changes should
 * made when upgrading from a previous release to version 0.12.0 or higher.
 *
 * ### Module variables
 *
 * The following module variables were updated to better meet current Rackspace style guides:
 *
 * - `security_group_list` -> `security_groups`
 * - `resource_name` -> `name`
 *
 * The following variables are no longer neccessary and were removed
 *
 * - `additional_ssm_bootstrap_step_count`
 * - `install_scaleft_agent`
 *
 * Several new variables were introduced to provide existing functionality, with a simplified format.  The original formmating was also retained to allow easier transition.
 *
 * New variables `tags` and `tags_asg` were added to replace the functionality of the `additional_tags` variable.  `tags` allows setting tags on all resources, while `tags_asg` sets tags only on the ASG itself.  `additional_tags` will continue to work as expected, but will be removed in a future release.
 *
 * New variable `ssm_bootstrap_list` was added to allow setting the SSM association steps using objects instead of strings, allowing easier linting and formatting of these lines.  The `additional_ssm_bootstrap_list` variable will continue to work, but will be deprecated in a future release.
 */

locals {
  user_data_vars = {
    initial_commands = var.initial_userdata_commands
    final_commands   = var.final_userdata_commands
  }
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = "~> 3.0"
  }
}

locals {
  ec2_os = lower(var.ec2_os)

  ec2_os_windows_length_test = length(local.ec2_os) >= 7 ? 7 : length(local.ec2_os)
  ec2_os_windows             = substr(local.ec2_os, 0, local.ec2_os_windows_length_test) == "windows" ? true : false

  # Enforce metrics needed for CW
  asg_metrics = distinct(concat(var.enabled_asg_metrics, ["GroupTerminatingInstances"]))

  cw_config_parameter_name = "CWAgent-${var.name}"

  ssm_doc_content = {
    schemaVersion = "2.2"
    description   = "SSM Document for instance configuration."
    parameters    = {}
    mainSteps     = local.ssm_command_list
  }

  ssm_command_list = concat(
    local.default_ssm_cmd_list,
    local.ssm_codedeploy_include[var.install_codedeploy_agent],
    [for s in var.additional_ssm_bootstrap_list : jsondecode(s.ssm_add_step)],
    var.ssm_bootstrap_list,
  )

  # This is a list of ssm main steps
  default_ssm_cmd_list = [
    {
      action         = "aws:runDocument"
      name           = "BusyWait"
      timeoutSeconds = 300

      inputs = {
        documentPath = "AWS-RunDocument"
        documentType = "SSMDocument"

        documentParameters = {
          documentParameters = {}
          sourceInfo         = "{\"path\": \"https://rackspace-ssm-docs-${data.aws_region.current_region.name}.s3.amazonaws.com/latest/configuration/Rack-BusyWait.json\"}"
          sourceType         = "S3"
        }
      }
    },
    {
      action         = "aws:runDocument"
      name           = "InstallCWAgent"
      timeoutSeconds = 300

      inputs = {
        documentPath = "AWS-ConfigureAWSPackage"
        documentType = "SSMDocument"

        documentParameters = {
          action = "Install"
          name   = "AmazonCloudWatchAgent"
        }
      }
    },
    {
      action         = "aws:runDocument"
      name           = "ConfigureCWAgent"
      timeoutSeconds = 300

      inputs = {
        documentPath = "AmazonCloudWatch-ManageAgent"
        documentType = "SSMDocument"

        documentParameters = {
          action                        = "configure"
          name                          = "AmazonCloudWatchAgent"
          optionalConfigurationLocation = var.provide_custom_cw_agent_config ? var.custom_cw_agent_config_ssm_param : local.cw_config_parameter_name
          optionalConfigurationSource   = "ssm"
          optionalRestart               = "yes"
        }
      }
    },
    {
      action         = "aws:runDocument"
      name           = "SetupTimeSync"
      timeoutSeconds = 300

      inputs = {
        documentPath = "AWS-RunDocument"
        documentType = "SSMDocument"

        documentParameters = {
          documentParameters = {}
          sourceInfo         = "{\"path\": \"https://rackspace-ssm-docs-${data.aws_region.current_region.name}.s3.amazonaws.com/latest/configuration/Rack-ConfigureAWSTimeSync.json\"}"
          sourceType         = "S3"
        }
      }
    },
    {
      action         = "aws:runDocument"
      name           = "DiagnosticTools"
      timeoutSeconds = 300

      inputs = {
        documentPath = "AWS-RunDocument"
        documentType = "SSMDocument"

        documentParameters = {
          documentParameters = { Packages = lookup(local.diagnostic_packages, local.ec2_os, "") }
          sourceInfo         = "{\"path\": \"https://rackspace-ssm-docs-${data.aws_region.current_region.name}.s3.amazonaws.com/latest/configuration/Rack-Install_Package.json\"}"
          sourceType         = "S3"
        }
      }
    },
    {
      action         = "aws:runDocument"
      name           = "SetMotd"
      timeoutSeconds = 300

      inputs = {
        documentPath = "AWS-RunDocument"
        documentType = "SSMDocument"

        documentParameters = {
          documentParameters = {}
          sourceInfo         = "{\"path\": \"https://rackspace-ssm-docs-${data.aws_region.current_region.name}.s3.amazonaws.com/latest/configuration/Rack-SetMotd.json\"}"
          sourceType         = "S3"
        }
      }
    },
  ]

  ssm_codedeploy_include = {
    true = [
      {
        action         = "aws:runDocument"
        name           = "InstallCodeDeployAgent"
        timeoutSeconds = 300

        inputs = {
          documentPath = "AWS-RunDocument"
          documentType = "SSMDocument"

          documentParameters = {
            documentParameters = {}
            sourceInfo         = "{\"path\": \"https://rackspace-ssm-docs-${data.aws_region.current_region.name}.s3.amazonaws.com/latest/configuration/Rack-Install_CodeDeploy.json\"}"
            sourceType         = "S3"
          }
        }
      },
    ]

    false = []
  }

  defaults = {
    diagnostic_packages = {
      amazon = "sysstat ltrace strace iptraf tcpdump"
      rhel   = "sysstat ltrace strace lsof iotop iptraf-ng tcpdump"
      ubuntu = "sysstat iotop iptraf-ng"
      debian = "sysstat iotop iptraf-ng"
    }
  }

  diagnostic_packages = {
    amazon2    = local.defaults["diagnostic_packages"]["amazon"]
    amazon2022 = local.defaults["diagnostic_packages"]["amazon"]
    amazoneks  = local.defaults["diagnostic_packages"]["amazon"]
    amazonecs  = local.defaults["diagnostic_packages"]["amazon"]
    rhel7      = local.defaults["diagnostic_packages"]["rhel"]
    rhel8      = local.defaults["diagnostic_packages"]["rhel"]
    centos7    = local.defaults["diagnostic_packages"]["rhel"]
    ubuntu18   = local.defaults["diagnostic_packages"]["ubuntu"]
    ubuntu20   = local.defaults["diagnostic_packages"]["ubuntu"]
    debian10   = local.defaults["diagnostic_packages"]["debian"]
    debian11   = local.defaults["diagnostic_packages"]["debian"]
  }

  ebs_device_map = {
    amazon2       = "/dev/sdf"
    amazon2022    = "/dev/sdf"
    amazoneks     = "/dev/sdf"
    amazonecs     = "/dev/xvdcz"
    rhel7         = "/dev/sdf"
    rhel8         = "/dev/sdf"
    centos7       = "/dev/sdf"
    ubuntu18      = "/dev/sdf"
    ubuntu20      = "/dev/sdf"
    debian10      = "/dev/sdf"
    debian11      = "/dev/sdf"
    windows2012r2 = "xvdf"
    windows2016   = "xvdf"
    windows2019   = "xvdf"
    windows2022   = "xvdf"
  }

  root_device_map = {
    amazon2       = "/dev/xvda"
    amazon2022    = "/dev/xvda"
    amazoneks     = "/dev/xvda"
    amazonecs     = "/dev/xvda"
    rhel7         = "/dev/sda1"
    rhel8         = "/dev/sda1"
    centos7       = "/dev/sda1"
    ubuntu18      = "/dev/sda1"
    ubuntu20      = "/dev/sda1"
    windows2012r2 = "/dev/sda1"
    windows2016   = "/dev/sda1"
    windows2019   = "/dev/sda1"
    windows2022   = "/dev/sda1"
    debian10      = "/dev/sda1"
    debian11      = "/dev/sda1"
  }

  cwagent_config = local.ec2_os_windows ? "windows_cw_agent_param.json" : "linux_cw_agent_param.json"

  # local.tags can and should be applied to all taggable resources

  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }

  # local.tags_ec2 is applied to the ASG and propagated to all instances

  tags_ec2 = {
    Backup           = var.backup_tag_value
    Name             = var.name
    "Patch Group"    = var.ssm_patching_group
    SSMInventory     = var.perform_ssm_inventory_tag
    "SSM Target Tag" = "Target-${var.name}"
  }

  # local.tags_asg is applied to the ASG but not propagated to the EC2 instances

  tags_asg = {
    InstanceReplacement = var.enable_rolling_updates ? "True" : "False"
  }

  user_data_map = {
    amazon2       = "amazon_linux_userdata.sh"
    amazon2022    = "amazon_linux_userdata.sh"
    amazonecs     = "amazon_linux_userdata.sh"
    amazoneks     = "amazon_linux_userdata.sh"
    rhel7         = "rhel_centos_7_userdata.sh"
    rhel8         = "rhel_centos_8_userdata.sh"
    centos7       = "rhel_centos_7_userdata.sh"
    ubuntu18      = "ubuntu_userdata.sh"
    ubuntu20      = "ubuntu_userdata.sh"
    debian10      = "debian_userdata.sh"
    debian11      = "debian_userdata.sh"
    windows2012r2 = "windows_userdata.ps1"
    windows2016   = "windows_userdata.ps1"
    windows2019   = "windows_userdata.ps1"
    windows2022   = "windows_userdata.ps1"
  }

  ami_owner_mapping = {
    amazon2       = "137112412989"
    amazon2022    = "137112412989"
    amazonecs     = "591542846629"
    amazoneks     = "602401143452"
    centos7       = "125523088429"
    rhel7         = "309956199498"
    rhel8         = "309956199498"
    ubuntu18      = "099720109477"
    ubuntu20      = "099720109477"
    debian10      = "136693071363"
    debian11      = "136693071363"
    windows2012r2 = "801119661308"
    windows2016   = "801119661308"
    windows2019   = "801119661308"
    windows2022   = "801119661308"
  }

  ami_name_mapping = {
    amazon2       = "amzn2-ami-hvm-2.0.*-ebs"
    amazon2022    = "al2022-ami-2022*-kernel-*-x86_64"
    amazonecs     = "amzn2-ami-ecs-hvm-2*-x86_64-ebs"
    amazoneks     = "amazon-eks-node-*"
    centos7       = "CentOS Linux 7 x86_64*"
    rhel7         = "RHEL-7.*_HVM-*x86_64*"
    rhel8         = "RHEL-8.*_HVM-*x86_64*"
    debian10      = "debian-10-amd64-*"
    debian11      = "debian-11-amd64-*"
    ubuntu18      = "ubuntu/images/hvm-ssd/*ubuntu-bionic-18.04-amd64-server*"
    ubuntu20      = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    windows2012r2 = "Windows_Server-2012-R2_RTM-English-64Bit-Base*"
    windows2016   = "Windows_Server-2016-English-Full-Base*"
    windows2019   = "Windows_Server-2019-English-Full-Base*"
    windows2022   = "Windows_Server-2022-English-Full-Base*"
  }

  # Any custom AMI filters for a given OS can be added in this mapping
  image_filter = {
    amazon2       = []
    amazon2022    = []
    amazonecs     = []
    amazoneks     = []
    centos7       = []
    rhel7         = []
    rhel8         = []
    ubuntu18      = []
    ubuntu20      = []
    debian10      = []
    debian11      = []
    windows2012r2 = []
    windows2016   = []
    windows2019   = []
    windows2022   = []
  }

  standard_filters = [
    {
      name   = "virtualization-type"
      values = ["hvm"]
    },
    {
      name   = "root-device-type"
      values = ["ebs"]
    },
    {
      name   = "name"
      values = [local.ami_name_mapping[local.ec2_os]]
    },
  ]
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "asg_ami" {
  most_recent = true
  owners      = [local.ami_owner_mapping[local.ec2_os]]

  dynamic "filter" {
    for_each = concat(local.standard_filters, local.image_filter[local.ec2_os])
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current_account" {}

#
# IAM policies
#

data "aws_iam_policy_document" "mod_ec2_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "mod_ec2_instance_role_policies" {

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ssm:CreateAssociation",
      "ssm:DescribeInstanceInformation",
      "ssm:GetParameter",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::rackspace-*/*"]

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetEncryptionConfiguration",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
  }
}

resource "aws_iam_policy" "create_instance_role_policy" {
  count = var.instance_profile_override ? 0 : 1

  description = "Rackspace Instance Role Policies for EC2"
  name        = "InstanceRolePolicy-${var.name}"
  policy      = data.aws_iam_policy_document.mod_ec2_instance_role_policies.json
}

resource "aws_iam_role" "mod_ec2_instance_role" {
  count = var.instance_profile_override ? 0 : 1

  assume_role_policy = data.aws_iam_policy_document.mod_ec2_assume_role_policy_doc.json
  name               = "InstanceRole-${var.name}"
  path               = "/"
}

resource "aws_iam_role_policy_attachment" "attach_core_ssm_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_cw_ssm_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_ad_ssm_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_codedeploy_policy" {
  count = var.install_codedeploy_agent && var.instance_profile_override != true ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_instance_role_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = aws_iam_policy.create_instance_role_policy[0].arn
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_additonal_policies" {
  count = var.instance_profile_override ? 0 : var.instance_role_managed_policy_arn_count

  policy_arn = element(var.instance_role_managed_policy_arns, count.index)
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_instance_profile" "instance_role_instance_profile" {
  count = var.instance_profile_override ? 0 : 1

  name = "InstanceRoleInstanceProfile-${var.name}"
  path = "/"
  role = aws_iam_role.mod_ec2_instance_role[0].name
}

#
# Provisioning of ASG related resources
#

resource "aws_launch_template" "launch_template_with_secondary_ebs" {
  count = var.secondary_ebs_volume_size != "" ? 1 : 0

  ebs_optimized          = var.enable_ebs_optimization
  image_id               = var.image_id != "" ? var.image_id : data.aws_ami.asg_ami.image_id
  instance_type          = var.instance_type
  key_name               = var.key_pair
  name_prefix            = join("-", compact(["LaunchConfigWith2ndEbs", var.name, format("%03d-", count.index + 1)]))
  vpc_security_group_ids = var.security_groups
  user_data              = base64encode(templatefile("${path.module}/text/${local.user_data_map[local.ec2_os]}", local.user_data_vars))

  # Root block device
  block_device_mappings {
    device_name = local.root_device_map[local.ec2_os]
    ebs {
      iops        = var.primary_ebs_volume_type == "io1" ? var.primary_ebs_volume_size : 0
      volume_size = var.primary_ebs_volume_size
      volume_type = var.primary_ebs_volume_type
      encrypted   = var.encrypt_primary_ebs_volume
    }
  }
  block_device_mappings {
    device_name = local.ebs_device_map[local.ec2_os]
    ebs {
      encrypted   = var.secondary_ebs_volume_existing_id == "" ? var.encrypt_secondary_ebs_volume : false
      iops        = var.secondary_ebs_volume_iops
      snapshot_id = var.secondary_ebs_volume_existing_id
      volume_size = var.secondary_ebs_volume_size
      volume_type = var.secondary_ebs_volume_type
    }
  }
  iam_instance_profile {
    name = element(
      coalescelist(aws_iam_instance_profile.instance_role_instance_profile.*.name,
        [var.instance_profile_override_name],
      ),
      0,
    )
  }
  lifecycle {
    create_before_destroy = true
  }
  monitoring {
    enabled = var.detailed_monitoring
  }
  placement {
    tenancy = var.tenancy
  }
}


resource "aws_launch_template" "launch_template_with_no_secondary_ebs" {
  count = var.secondary_ebs_volume_size != "" ? 0 : 1

  ebs_optimized          = var.enable_ebs_optimization
  image_id               = var.image_id != "" ? var.image_id : data.aws_ami.asg_ami.image_id
  instance_type          = var.instance_type
  key_name               = var.key_pair
  name_prefix            = join("-", compact(["LaunchConfigWith2ndEbs", var.name, format("%03d-", count.index + 1)]))
  vpc_security_group_ids = var.security_groups
  user_data              = base64encode(templatefile("${path.module}/text/${local.user_data_map[local.ec2_os]}", local.user_data_vars))

  # Root block device
  block_device_mappings {
    device_name = local.root_device_map[local.ec2_os]
    ebs {
      iops        = var.primary_ebs_volume_type == "io1" ? var.primary_ebs_volume_size : 0
      volume_size = var.primary_ebs_volume_size
      volume_type = var.primary_ebs_volume_type
      encrypted   = var.encrypt_primary_ebs_volume
    }
  }
  iam_instance_profile {
    name = element(
      coalescelist(aws_iam_instance_profile.instance_role_instance_profile.*.name,
        [var.instance_profile_override_name],
      ),
      0,
    )
  }
  lifecycle {
    create_before_destroy = true
  }
  monitoring {
    enabled = var.detailed_monitoring
  }
  placement {
    tenancy = var.tenancy
  }
}

resource "aws_autoscaling_policy" "ec2_scale_up_policy" {
  count = var.policy_type == "SimpleScaling" && var.enable_scaling_actions == true ? var.asg_count : 0

  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = element(aws_autoscaling_group.autoscalegrp.*.name, count.index)
  cooldown               = var.ec2_scale_up_cool_down
  name                   = join("-", compact(["ec2_scale_up_policy", var.name, format("%03d", count.index + 1)]))
  scaling_adjustment     = var.ec2_scale_up_adjustment
}

resource "aws_autoscaling_policy" "ec2_scale_down_policy" {
  count = var.policy_type == "SimpleScaling" && var.enable_scaling_actions == true ? var.asg_count : 0

  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = element(aws_autoscaling_group.autoscalegrp.*.name, count.index)
  cooldown               = var.ec2_scale_down_cool_down
  name                   = join("-", compact(["ec2_scale_down_policy", var.name, format("%03d", count.index + 1)]))
  scaling_adjustment     = var.ec2_scale_down_adjustment > 0 ? -var.ec2_scale_down_adjustment : var.ec2_scale_down_adjustment
}

resource "aws_autoscaling_policy" "ec2_scale_up_down_target_tracking" {
  count = var.policy_type == "TargetTrackingScaling" ? var.asg_count : 0

  name                      = join("-", compact(["ec2_scale_up_down_target_tracking_policy", var.name, format("%03d", count.index + 1)]))
  autoscaling_group_name    = element(aws_autoscaling_group.autoscalegrp.*.name, count.index)
  estimated_instance_warmup = var.instance_warm_up_time
  policy_type               = var.policy_type
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.tracking_policy_metric
      resource_label         = var.alb_resource_label
    }
    target_value     = var.target_value
    disable_scale_in = var.disable_scale_in
  }
}

resource "aws_autoscaling_group" "autoscalegrp" {
  count = var.asg_count

  enabled_metrics           = local.asg_metrics
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  load_balancers            = var.load_balancer_names
  max_size                  = var.scaling_max
  metrics_granularity       = "1Minute"
  min_size                  = var.scaling_min
  name_prefix               = join("-", compact(["AutoScaleGrp", var.name, format("%03d-", count.index + 1)]))
  target_group_arns         = var.target_group_arns
  vpc_zone_identifier       = var.subnets
  wait_for_capacity_timeout = var.asg_wait_for_capacity_timeout

  launch_template {
    id = element(coalescelist(
      aws_launch_template.launch_template_with_secondary_ebs.*.id,
      aws_launch_template.launch_template_with_no_secondary_ebs.*.id, ),
    count.index)
    version = "$Latest"
  }

  # This block sets tags provided as objects, allowing the propagate at launch field to be set to False
  dynamic "tag" {
    for_each = var.additional_tags

    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = lookup(tag.value, "propagate_at_launch", true)
    }
  }

  # This block sets tags provided as a map in the tags variable (propagated to ASG instances).
  dynamic "tag" {
    for_each = merge(var.tags, local.tags_ec2, local.tags)

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # This block sets tags provided as a map in the tags_asg variable (not propagated to ASG instances).
  dynamic "tag" {
    for_each = merge(var.tags_asg, local.tags_asg)

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }

  depends_on = [aws_ssm_association.ssm_bootstrap_assoc]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_notification" "scaling_notifications" {
  count = var.enable_scaling_notification ? var.asg_count : 0

  group_names = [element(aws_autoscaling_group.autoscalegrp.*.name, count.index)]
  topic_arn   = var.scaling_notification_topic

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}

resource "aws_autoscaling_notification" "rs_support_emergency" {
  count = var.rackspace_managed ? var.asg_count : 0

  group_names = [element(aws_autoscaling_group.autoscalegrp.*.name, count.index)]
  topic_arn   = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-emergency"

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}

#
# Provisioning of CloudWatch related resources
#

locals {
  asg_names = [for n in range(var.asg_count) : element(aws_autoscaling_group.autoscalegrp.*.name, n)]

  alarm_dimensions = tolist([for n in range(var.asg_count) : tomap({ "AutoScalingGroupName" = tostring(local.asg_names[n]) })])
}

module "group_terminating_instances" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.asg_count
  alarm_description        = "Over ${var.terminated_instances} instances terminated in last 6 hours, generating ticket to investigate."
  alarm_name               = "${var.name}-GroupTerminatingInstances"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_cleared  = var.customer_alarms_cleared
  customer_alarms_enabled  = var.customer_alarms_enabled
  dimensions               = local.alarm_dimensions[*]
  evaluation_periods       = 1
  metric_name              = "GroupTerminatingInstances"
  namespace                = "AWS/AutoScaling"
  notification_topic       = var.notification_topic
  period                   = 21600
  rackspace_alarms_enabled = var.rackspace_alarms_enabled
  rackspace_managed        = var.rackspace_managed
  severity                 = "emergency"
  statistic                = "Sum"
  threshold                = var.terminated_instances
  unit                     = "Count"
}

resource "aws_cloudwatch_metric_alarm" "scale_alarm_high" {
  count = var.policy_type == "SimpleScaling" && var.enable_scaling_actions == true ? var.asg_count : 0

  alarm_actions       = [element(aws_autoscaling_policy.ec2_scale_up_policy.*.arn, count.index)]
  alarm_description   = "Scale-up if ${var.cw_scaling_metric} ${var.cw_high_operator} ${var.cw_high_threshold}% for ${var.cw_high_period} seconds ${var.cw_high_evaluations} times."
  alarm_name          = join("-", compact(["ScaleAlarmHigh", var.name, format("%03d", count.index + 1)]))
  comparison_operator = var.cw_high_operator
  evaluation_periods  = var.cw_high_evaluations
  metric_name         = var.cw_scaling_metric
  namespace           = "AWS/EC2"
  period              = var.cw_high_period
  statistic           = "Average"
  threshold           = var.cw_high_threshold

  dimensions = {
    AutoScalingGroupName = element(aws_autoscaling_group.autoscalegrp.*.name, count.index)
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_alarm_low" {
  count = var.policy_type == "SimpleScaling" && var.enable_scaling_actions == true ? var.asg_count : 0

  alarm_actions       = [element(aws_autoscaling_policy.ec2_scale_down_policy.*.arn, count.index)]
  alarm_description   = "Scale-down if ${var.cw_scaling_metric} ${var.cw_low_operator} ${var.cw_low_threshold}% for ${var.cw_low_period} seconds ${var.cw_low_evaluations} times."
  alarm_name          = join("-", compact(["ScaleAlarmLow", var.name, format("%03d", count.index + 1)]))
  comparison_operator = var.cw_low_operator
  evaluation_periods  = var.cw_low_evaluations
  metric_name         = var.cw_scaling_metric
  namespace           = "AWS/EC2"
  period              = var.cw_low_period
  statistic           = "Average"
  threshold           = var.cw_low_threshold

  dimensions = {
    AutoScalingGroupName = element(aws_autoscaling_group.autoscalegrp.*.name, count.index)
  }
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "${var.name}-SystemsLogs"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "${var.name}-ApplicationLogs"
  retention_in_days = var.cloudwatch_log_retention
}

#
# Provisioning of SSM related resources
#

resource "aws_ssm_document" "ssm_bootstrap_doc" {
  content         = jsonencode(local.ssm_doc_content)
  document_format = "JSON"
  document_type   = "Command"
  name            = "SSMDocument-${var.name}"
}

locals {
  cwagentparam_vars = {
    application_log = aws_cloudwatch_log_group.application_logs.name
    system_log      = aws_cloudwatch_log_group.system_logs.name
  }

  cwagentparam_object = jsondecode(templatefile("${path.module}/text/${local.cwagent_config}", local.cwagentparam_vars))
}

resource "aws_ssm_parameter" "cwagentparam" {
  count = var.provide_custom_cw_agent_config ? 0 : 1

  description = "${var.name} Cloudwatch Agent configuration"
  name        = local.cw_config_parameter_name
  type        = "String"
  value       = jsonencode(local.cwagentparam_object)
}

resource "aws_ssm_association" "ssm_bootstrap_assoc" {
  name                = aws_ssm_document.ssm_bootstrap_doc.name
  schedule_expression = var.ssm_association_refresh_rate

  targets {
    key    = "tag:SSM Target Tag"
    values = ["Target-${var.name}"]
  }

  depends_on = [aws_ssm_document.ssm_bootstrap_doc]
}
