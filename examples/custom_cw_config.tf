locals {
  cwagent_vars = {
    application_log_group_name = "custom_app_log_group_name"
    system_log_group_name      = "custom_system_log_group_name"
  }
}

terraform {
  required_version = ">= 0.13.7"
}

provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
}

resource "random_string" "name_rstring" {
  length  = 8
  special = false
}


module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.7"

  name = "${random_string.name_rstring.result}-ec2-asg-basenetwork-example"
}

data "aws_region" "current_region" {}

resource "random_string" "sqs_rstring" {
  length  = 18
  special = false
  upper   = false
}

resource "aws_sqs_queue" "ec2_asg_test_sqs" {
  name = "${random_string.sqs_rstring.result}-my-example-queue"
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.12.2"

  create_subscription_1 = true
  endpoint_1            = aws_sqs_queue.ec2_asg_test_sqs.arn
  name                  = "${random_string.sqs_rstring.result}-ec2-asg-test-topic"
  protocol_1            = "sqs"
}


module "clb" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-clb?ref=v0.12.4"

  name                  = "${random_string.name_rstring.result}-ec2-asg-clb-example"
  security_groups       = [module.vpc.default_sg]
  subnets               = module.vpc.public_subnets
  internal_loadbalancer = false
  create_logging_bucket = false
  rackspace_managed     = false

  tags = {
    Example = "Example-clb"
  }


  listeners = [
    {
      instance_port     = 8000
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
  ]
}

module "ec2_asg" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg?ref=v0.12.23"

  asg_count                              = "2"
  asg_wait_for_capacity_timeout          = "10m"
  backup_tag_value                       = "False"
  cloudwatch_log_retention               = "30"
  custom_cw_agent_config_ssm_param       = aws_ssm_parameter.custom_cwagentparam.name
  cw_high_evaluations                    = "3"
  cw_high_operator                       = "GreaterThanThreshold"
  cw_high_period                         = "60"
  cw_high_threshold                      = "60"
  cw_low_evaluations                     = "3"
  cw_low_operator                        = "LessThanThreshold"
  cw_low_period                          = "300"
  cw_low_threshold                       = "30"
  cw_scaling_metric                      = "CPUUtilization"
  detailed_monitoring                    = true
  ec2_os                                 = "centos7"
  ec2_scale_down_adjustment              = "1"
  ec2_scale_down_cool_down               = "60"
  ec2_scale_up_adjustment                = "1"
  ec2_scale_up_cool_down                 = "60"
  enable_ebs_optimization                = false
  enable_scaling_notification            = true
  encrypt_secondary_ebs_volume           = false
  environment                            = "Development"
  health_check_grace_period              = "300"
  health_check_type                      = "EC2"
  install_codedeploy_agent               = false
  instance_role_managed_policy_arn_count = "2"
  instance_type                          = "t2.micro"
  load_balancer_names                    = [module.clb.name]
  name                                   = "${random_string.name_rstring.result}-ec2-asg-instance-example"
  perform_ssm_inventory_tag              = "True"
  primary_ebs_volume_iops                = "0"
  primary_ebs_volume_size                = "60"
  primary_ebs_volume_type                = "gp2"
  provide_custom_cw_agent_config         = true
  rackspace_managed                      = true
  scaling_max                            = "2"
  scaling_min                            = "1"
  scaling_notification_topic             = module.sns.topic_arn
  secondary_ebs_volume_iops              = "0"
  secondary_ebs_volume_size              = "60"
  secondary_ebs_volume_type              = "gp2"
  security_groups                        = [module.vpc.default_sg]
  ssm_association_refresh_rate           = "rate(1 day)"
  ssm_patching_group                     = "MyPatchGroup1"
  subnets                                = [element(module.vpc.public_subnets, 0), element(module.vpc.public_subnets, 1)]
  tenancy                                = "default"
  terminated_instances                   = "30"

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  ssm_bootstrap_list = [
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
        documentParameters = {
          Packages = "tmux"
        },
        documentType = "SSMDocument"
      },
      name           = "InstallTmux",
      timeoutSeconds = 300
    },
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "AWS-RunShellScript",
        documentParameters = {
          commands = ["touch /tmp/myfile"]
        },
        documentType = "SSMDocument"
      },
      name           = "CreateFile",
      timeoutSeconds = 300
    },
  ]

  tags = {
    MyTag1 = "Myvalue1"
    MyTag2 = "Myvalue2"
    MyTag3 = "Myvalue3"
  }
}

resource "random_string" "res_name" {
  length  = 8
  lower   = true
  number  = false
  special = false
  upper   = false
}

resource "aws_ssm_parameter" "custom_cwagentparam" {
  description = "Custom Cloudwatch Agent configuration"
  name        = "custom_cw_param-${random_string.res_name.result}"
  type        = "String"
  value       = templatefile("./text/linux_cw_agent_param.json", local.cwagent_vars)
}