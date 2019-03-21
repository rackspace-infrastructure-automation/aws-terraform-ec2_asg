/**
 * # aws-terraform-ec2_asg
 *
 *This module creates one or more autoscaling groups.
 *
 *## Basic Usage
 *
 *```
 *module "asg" {
 *  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg//?ref=v0.0.11"
 *
 *  ec2_os              = "amazon"
 *  subnets             = ["${module.vpc.private_subnets}"]
 *  image_id            = "${var.image_id}"
 *  resource_name       = "my_asg"
 *  security_group_list = ["${module.sg.private_web_security_group_id}"]
 *}
 *```
 *
 * Full working references are available at [examples](examples)
 */

locals {
  cw_config_parameter_name = "CWAgent-${var.resource_name}"

  # This is a list of ssm main steps
  default_ssm_cmd_list = [
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
        "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-BusyWait",
        "documentType": "SSMDocument"
        },
        "name": "BusyWait",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AWS-ConfigureAWSPackage",
          "documentParameters": {
            "action": "Install",
            "name": "AmazonCloudWatchAgent"
          },
          "documentType": "SSMDocument"
        },
        "name": "InstallCWAgent",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AmazonCloudWatch-ManageAgent",
          "documentParameters": {
            "action": "configure",
            "optionalConfigurationSource": "ssm",
            "optionalConfigurationLocation": "${var.provide_custom_cw_agent_config ? var.custom_cw_agent_config_ssm_param : local.cw_config_parameter_name}",
            "optionalRestart": "yes",
            "name": "AmazonCloudWatchAgent"
          },
          "documentType": "SSMDocument"
        },
        "name": "ConfigureCWAgent",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-ConfigureAWSTimeSync",
          "documentType": "SSMDocument"
        },
        "name": "SetupTimeSync",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_ScaleFT",
          "documentType": "SSMDocument"
        },
        "name": "SetupPassport",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
          "documentParameters": {
            "Packages": "sysstat ltrace strace iptraf tcpdump"
          },
          "documentType": "SSMDocument"
        },
        "name": "DiagnosticTools",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-SetMotd",
          "documentType": "SSMDocument"
        },
        "name": "SetMotd",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AWS-UpdateSSMAgent",
          "documentType": "SSMDocument"
        },
        "name": "UpdateSSMAgent",
        "timeoutSeconds": 300
      }
EOF
    },
  ]

  ssm_codedeploy_include = {
    enabled = <<EOF
    {
      "action": "aws:runDocument",
      "inputs": {
        "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_CodeDeploy",
        "documentType": "SSMDocument"
      },
      "name": "InstallCodeDeployAgent"
    }
EOF

    disabled = ""
  }

  codedeploy_install = "${var.install_codedeploy_agent ? "enabled" : "disabled"}"

  ssm_command_count = 6

  ebs_device_map = {
    amazon        = "/dev/sdf"
    amazon2       = "/dev/sdf"
    amazoneks     = "/dev/sdf"
    amazonecs     = "/dev/xvdcz"
    rhel6         = "/dev/sdf"
    rhel7         = "/dev/sdf"
    centos6       = "/dev/sdf"
    centos7       = "/dev/sdf"
    windows2008   = "xvdf"
    windows2012R2 = "xvdf"
    windows2016   = "xvdf"
    ubuntu14      = "/dev/sdf"
    ubuntu16      = "/dev/sdf"
    ubuntu18      = "/dev/sdf"
  }

  cwagent_config = "${var.ec2_os != "windows" ? "linux_cw_agent_param.json" : "windows_cw_agent_param.json"}"

  tags = [
    {
      key                 = "Backup"
      value               = "${var.backup_tag_value}"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.resource_name}"
      propagate_at_launch = true
    },
    {
      key                 = "Patch Group"
      value               = "${var.ssm_patching_group}"
      propagate_at_launch = true
    },
    {
      key                 = "SSMInventory"
      value               = "${var.perform_ssm_inventory_tag}"
      propagate_at_launch = true
    },
    {
      key                 = "ServiceProvider"
      value               = "Rackspace"
      propagate_at_launch = true
    },
    {
      key                 = "SSM Target Tag"
      value               = "Target-${var.resource_name}"
      propagate_at_launch = true
    },
    {
      key                 = "InstanceReplacement"
      value               = "${var.enable_rolling_updates ? "True" : "False"}"
      propagate_at_launch = false
    },
  ]

  user_data_map = {
    amazon        = "amazon_linux_userdata.sh"
    amazon2       = "amazon_linux_userdata.sh"
    amazonecs     = "amazon_linux_userdata.sh"
    amazoneks     = "amazon_linux_userdata.sh"
    rhel6         = "rhel_centos_6_userdata.sh"
    rhel7         = "rhel_centos_7_userdata.sh"
    centos6       = "rhel_centos_6_userdata.sh"
    centos7       = "rhel_centos_7_userdata.sh"
    ubuntu14      = "ubuntu_userdata.sh"
    ubuntu16      = "ubuntu_userdata.sh"
    ubuntu18      = "ubuntu_userdata.sh"
    windows2008   = "windows_userdata.ps1"
    windows2012R2 = "windows_userdata.ps1"
    windows2016   = "windows_userdata.ps1"
  }

  ami_owner_mapping = {
    amazon        = "137112412989"
    amazon2       = "137112412989"
    amazonecs     = "591542846629"
    amazoneks     = "602401143452"
    centos6       = "679593333241"
    centos7       = "679593333241"
    rhel6         = "309956199498"
    rhel7         = "309956199498"
    ubuntu14      = "099720109477"
    ubuntu16      = "099720109477"
    ubuntu18      = "099720109477"
    windows2008   = "801119661308"
    windows2012R2 = "801119661308"
    windows2016   = "801119661308"
  }

  ami_name_mapping = {
    amazon        = "amzn-ami-hvm-2018.03.0.*gp2"
    amazon2       = "amzn2-ami-hvm-2.0.*-ebs"
    amazonecs     = "amzn-ami-2017.09.*-amazon-ecs-optimized"
    amazoneks     = "amazon-eks-node-*"
    centos6       = "CentOS Linux 6 x86_64 HVM EBS*"
    centos7       = "CentOS Linux 7 x86_64 HVM EBS*"
    rhel6         = "RHEL-6.*_HVM_GA-*x86_64*"
    rhel7         = "RHEL-7.*_HVM_GA-*x86_64*"
    ubuntu14      = "*ubuntu-trusty-14.04-amd64-server*"
    ubuntu16      = "*ubuntu-xenial-16.04-amd64-server*"
    ubuntu18      = "ubuntu/images/hvm-ssd/*ubuntu-bionic-18.04-amd64-server*"
    windows2008   = "Windows_Server-2008-R2_SP1-English-64Bit-Base*"
    windows2012R2 = "Windows_Server-2012-R2_RTM-English-64Bit-Base*"
    windows2016   = "Windows_Server-2016-English-Full-Base*"
  }
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "asg_ami" {
  most_recent = true
  owners      = ["${local.ami_owner_mapping[var.ec2_os]}"]

  filter {
    name   = "name"
    values = ["${local.ami_name_mapping[var.ec2_os]}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/text/${lookup(local.user_data_map, var.ec2_os)}")}"

  vars {
    initial_commands = "${var.initial_userdata_commands != "" ? "${var.initial_userdata_commands}" : "" }"
    final_commands   = "${var.final_userdata_commands != "" ? "${var.final_userdata_commands}" : "" }"
  }
}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current_account" {}

#
# IAM policies
#

data "aws_iam_policy_document" "mod_ec2_assume_role_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mod_ec2_instance_role_policies" {
  statement {
    effect    = "Allow"
    actions   = ["cloudformation:Describe"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:CreateAssociation",
      "ssm:DescribeInstanceInformation",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "logs:CreateLogStream",
      "ec2:DescribeTags",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "ssm:GetParameter",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "create_instance_role_policy" {
  count       = "${var.instance_profile_override ? 0 : 1}"
  name        = "InstanceRolePolicy-${var.resource_name}"
  description = "Rackspace Instance Role Policies for EC2"
  policy      = "${data.aws_iam_policy_document.mod_ec2_instance_role_policies.json}"
}

resource "aws_iam_role" "mod_ec2_instance_role" {
  count              = "${var.instance_profile_override ? 0 : 1}"
  name               = "InstanceRole-${var.resource_name}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.mod_ec2_assume_role_policy_doc.json}"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  count      = "${var.instance_profile_override ? 0 : 1}"
  role       = "${aws_iam_role.mod_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "attach_codedeploy_policy" {
  count      = "${var.install_codedeploy_agent && var.instance_profile_override != true ? 1 : 0}"
  role       = "${aws_iam_role.mod_ec2_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "attach_instance_role_policy" {
  count      = "${var.instance_profile_override ? 0 : 1}"
  role       = "${aws_iam_role.mod_ec2_instance_role.name}"
  policy_arn = "${aws_iam_policy.create_instance_role_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "attach_additonal_policies" {
  count      = "${var.instance_profile_override ? 0 : var.instance_role_managed_policy_arn_count}"
  role       = "${aws_iam_role.mod_ec2_instance_role.name}"
  policy_arn = "${element(var.instance_role_managed_policy_arns, count.index)}"
}

resource "aws_iam_instance_profile" "instance_role_instance_profile" {
  count = "${var.instance_profile_override ? 0 : 1}"
  name  = "InstanceRoleInstanceProfile-${var.resource_name}"
  role  = "${aws_iam_role.mod_ec2_instance_role.name}"
  path  = "/"
}

#
# Provisioning of ASG related resources
#

resource "aws_launch_configuration" "launch_config_with_secondary_ebs" {
  name_prefix          = "${join("-",compact(list("LaunchConfigWith2ndEbs", var.resource_name, format("%03d-",count.index+1))))}"
  count                = "${var.secondary_ebs_volume_size != "" ? 1 : 0}"
  user_data_base64     = "${base64encode(data.template_file.user_data.rendered)}"
  enable_monitoring    = "${var.detailed_monitoring}"
  image_id             = "${var.image_id != "" ? var.image_id : data.aws_ami.asg_ami.image_id}"
  key_name             = "${var.key_pair}"
  security_groups      = ["${var.security_group_list}"]
  placement_tenancy    = "${var.tenancy}"
  ebs_optimized        = "${var.enable_ebs_optimization}"
  iam_instance_profile = "${element(coalescelist(aws_iam_instance_profile.instance_role_instance_profile.*.name, list(var.instance_profile_override_name)), 0)}"
  instance_type        = "${var.instance_type}"

  root_block_device {
    volume_type = "${var.primary_ebs_volume_type}"
    volume_size = "${var.primary_ebs_volume_size}"
    iops        = "${var.primary_ebs_volume_type == "io1" ? var.primary_ebs_volume_size : 0}"
  }

  ebs_block_device {
    device_name = "${lookup(local.ebs_device_map, var.ec2_os)}"
    volume_type = "${var.secondary_ebs_volume_type}"
    volume_size = "${var.secondary_ebs_volume_size}"
    iops        = "${var.secondary_ebs_volume_iops}"
    encrypted   = "${var.encrypt_secondary_ebs_volume}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "launch_config_no_secondary_ebs" {
  name_prefix          = "${join("-",compact(list("LaunchConfigNo2ndEbs", var.resource_name, format("%03d-",count.index+1))))}"
  count                = "${var.secondary_ebs_volume_size != "" ? 0 : 1}"
  user_data_base64     = "${base64encode(data.template_file.user_data.rendered)}"
  enable_monitoring    = "${var.detailed_monitoring}"
  image_id             = "${var.image_id != "" ? var.image_id : data.aws_ami.asg_ami.image_id}"
  key_name             = "${var.key_pair}"
  security_groups      = ["${var.security_group_list}"]
  placement_tenancy    = "${var.tenancy}"
  ebs_optimized        = "${var.enable_ebs_optimization}"
  iam_instance_profile = "${element(coalescelist(aws_iam_instance_profile.instance_role_instance_profile.*.name, list(var.instance_profile_override_name)), 0)}"
  instance_type        = "${var.instance_type}"

  root_block_device {
    volume_type = "${var.primary_ebs_volume_type}"
    volume_size = "${var.primary_ebs_volume_size}"
    iops        = "${var.primary_ebs_volume_type == "io1" ? var.primary_ebs_volume_size : 0}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "ec2_scale_up_policy" {
  name                   = "${join("-",compact(list("ec2_scale_up_policy", var.resource_name, format("%03d",count.index+1))))}"
  count                  = "${var.asg_count}"
  scaling_adjustment     = "${var.ec2_scale_up_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.ec2_scale_up_cool_down}"
  autoscaling_group_name = "${element(aws_autoscaling_group.autoscalegrp.*.name, count.index)}"
}

resource "aws_autoscaling_policy" "ec2_scale_down_policy" {
  name                   = "${join("-",compact(list("ec2_scale_down_policy", var.resource_name, format("%03d",count.index+1))))}"
  count                  = "${var.asg_count}"
  scaling_adjustment     = "${var.ec2_scale_down_adjustment > 0 ? 0 - var.ec2_scale_down_adjustment : var.ec2_scale_down_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.ec2_scale_down_cool_down}"
  autoscaling_group_name = "${element(aws_autoscaling_group.autoscalegrp.*.name, count.index)}"
}

resource "aws_autoscaling_group" "autoscalegrp" {
  name_prefix               = "${join("-",compact(list("AutoScaleGrp", var.resource_name, format("%03d-",count.index+1))))}"
  count                     = "${var.asg_count}"
  max_size                  = "${var.scaling_max}"
  min_size                  = "${var.scaling_min}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"

  # coalescelist and list("novalue") were used here due to element not being able to handle empty lists, even if conditional will not allow portion to execute
  launch_configuration      = "${var.secondary_ebs_volume_size != "" ? element(coalescelist(aws_launch_configuration.launch_config_with_secondary_ebs.*.name, list("novalue")), count.index) : element(coalescelist(aws_launch_configuration.launch_config_no_secondary_ebs.*.name, list("novalue")), count.index)}"
  vpc_zone_identifier       = ["${var.subnets}"]
  load_balancers            = ["${var.load_balancer_names}"]
  metrics_granularity       = "1Minute"
  target_group_arns         = ["${var.target_group_arns}"]
  wait_for_capacity_timeout = "${var.asg_wait_for_capacity_timeout}"

  tags = ["${
    concat(
        local.tags,
        var.additional_tags)}"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_ssm_association.ssm_bootstrap_assoc"]
}

resource "aws_autoscaling_notification" "scaling_notifications" {
  count = "${var.enable_scaling_notification ? var.asg_count : 0}"

  group_names = [
    "${element(aws_autoscaling_group.autoscalegrp.*.name, count.index)}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "${var.scaling_notification_topic}"
}

resource "aws_autoscaling_notification" "rs_support_emergency" {
  count = "${var.rackspace_managed ? var.asg_count : 0}"

  group_names = [
    "${element(aws_autoscaling_group.autoscalegrp.*.name, count.index)}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = "arn:aws:sns:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:rackspace-support-emergency"
}

#
# Provisioning of CloudWatch related resources
#
data "null_data_source" "alarm_dimensions" {
  count = "${var.asg_count}"

  inputs = {
    AutoScalingGroupName = "${element(aws_autoscaling_group.autoscalegrp.*.name, count.index)}"
  }
}

module "group_terminating_instances" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_count              = "${var.asg_count}"
  alarm_description        = "Over ${var.terminated_instances} instances terminated in last 6 hours, generating ticket to investigate."
  alarm_name               = "${var.resource_name}-GroupTerminatingInstances}"
  comparison_operator      = "GreaterThanThreshold"
  dimensions               = "${data.null_data_source.alarm_dimensions.*.outputs}"
  evaluation_periods       = 1
  metric_name              = "GroupTerminatingInstances"
  namespace                = "AWS/AutoScaling"
  notification_topic       = "${var.notification_topic}"
  period                   = 21600
  rackspace_alarms_enabled = "${var.rackspace_alarms_enabled}"
  rackspace_managed        = "${var.rackspace_managed}"
  severity                 = "emergency"
  statistic                = "Sum"
  threshold                = "${var.terminated_instances}"
  unit                     = "Count"
}

resource "aws_cloudwatch_metric_alarm" "scale_alarm_high" {
  alarm_name          = "${join("-",compact(list("ScaleAlarmHigh", var.resource_name, format("%03d",count.index+1))))}"
  alarm_description   = "Scale-up if ${var.cw_scaling_metric} ${var.cw_high_operator} ${var.cw_high_threshold}% for ${var.cw_high_period} seconds ${var.cw_high_evaluations} times."
  count               = "${var.asg_count}"
  namespace           = "AWS/EC2"
  period              = "${var.cw_high_period}"
  comparison_operator = "${var.cw_high_operator}"
  statistic           = "Average"
  threshold           = "${var.cw_high_threshold}"
  metric_name         = "${var.cw_scaling_metric}"
  evaluation_periods  = "${var.cw_high_evaluations}"
  alarm_actions       = ["${element(aws_autoscaling_policy.ec2_scale_up_policy.*.arn, count.index)}"]

  dimensions {
    AutoScalingGroupName = "${element(aws_autoscaling_group.autoscalegrp.*.name, count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_alarm_low" {
  alarm_name          = "${join("-",compact(list("ScaleAlarmLow", var.resource_name, format("%03d",count.index+1))))}"
  alarm_description   = "Scale-down if ${var.cw_scaling_metric} ${var.cw_low_operator} ${var.cw_low_threshold}% for ${var.cw_low_period} seconds ${var.cw_low_evaluations} times."
  count               = "${var.asg_count}"
  namespace           = "AWS/EC2"
  period              = "${var.cw_low_period}"
  comparison_operator = "${var.cw_low_operator}"
  statistic           = "Average"
  threshold           = "${var.cw_low_threshold}"
  metric_name         = "${var.cw_scaling_metric}"
  evaluation_periods  = "${var.cw_low_evaluations}"
  alarm_actions       = ["${element(aws_autoscaling_policy.ec2_scale_down_policy.*.arn, count.index)}"]

  dimensions {
    AutoScalingGroupName = "${element(aws_autoscaling_group.autoscalegrp.*.name, count.index)}"
  }
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "${var.resource_name}-SystemsLogs"
  retention_in_days = "${var.cloudwatch_log_retention}"
}

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "${var.resource_name}-ApplicationLogs"
  retention_in_days = "${var.cloudwatch_log_retention}"
}

#
# Provisioning of SSM related resources
#

data "template_file" "ssm_command_docs" {
  template = "$${ssm_cmd_json}"

  count = "${local.ssm_command_count}"

  vars {
    ssm_cmd_json = "${lookup(local.default_ssm_cmd_list[count.index], "ssm_add_step")}"
  }
}

data "template_file" "additional_ssm_docs" {
  template = "$${addtional_ssm_cmd_json}"
  count    = "${var.addtional_ssm_bootstrap_step_count}"

  vars {
    addtional_ssm_cmd_json = "${lookup(var.addtional_ssm_bootstrap_list[count.index], "ssm_add_step")}"
  }
}

data "template_file" "ssm_bootstrap_template" {
  template = "${file("${path.module}/text/ssm_bootstrap_template.json")}"

  vars {
    run_command_list = "${join(",",compact(concat(data.template_file.ssm_command_docs.*.rendered, list(local.ssm_codedeploy_include[local.codedeploy_install]), data.template_file.additional_ssm_docs.*.rendered)))}"
  }
}

resource "aws_ssm_document" "ssm_bootstrap_doc" {
  name            = "SSMDocument-${var.resource_name}"
  document_type   = "Command"
  document_format = "JSON"
  content         = "${data.template_file.ssm_bootstrap_template.rendered}"
}

resource "aws_ssm_parameter" "cwagentparam" {
  count       = "${var.provide_custom_cw_agent_config ? 0 : 1}"
  name        = "${local.cw_config_parameter_name}"
  description = "${var.resource_name} Cloudwatch Agent configuration"
  type        = "String"
  value       = "${replace(replace(file("${path.module}/text/${local.cwagent_config}"),"((SYSTEM_LOG_GROUP_NAME))",aws_cloudwatch_log_group.system_logs.name),"((APPLICATION_LOG_GROUP_NAME))",aws_cloudwatch_log_group.application_logs.name)}"
}

resource "aws_ssm_association" "ssm_bootstrap_assoc" {
  name                = "${aws_ssm_document.ssm_bootstrap_doc.name}"
  schedule_expression = "${var.ssm_association_refresh_rate}"

  targets {
    key    = "tag:SSM Target Tag"
    values = ["Target-${var.resource_name}"]
  }

  depends_on = ["aws_ssm_document.ssm_bootstrap_doc"]
}
