terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
}

provider "random" {
  version = "~> 2.0"
}

data "aws_region" "current_region" {}

locals {
  tags = {
    Environment     = "Test"
    Purpose         = "Testing aws-terraform-ec2_asg"
    ServiceProvider = "Rackspace"
    Terraform       = "true"
  }

  tags_asg = {
    ASG = "true"
  }
}

resource "random_string" "sqs_rstring" {
  length  = 18
  special = false
  upper   = false
}

resource "random_string" "name_rstring" {
  length  = 8
  special = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=master"

  name = "${random_string.name_rstring.result}-ec2-asg-basenetwork-test1"
}

resource "aws_sqs_queue" "ec2_asg_test_sqs" {
  name = "${random_string.sqs_rstring.result}-example-queue"
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=master"

  create_subscription_1 = true
  endpoint_1            = aws_sqs_queue.ec2_asg_test_sqs.arn
  name                  = "${random_string.sqs_rstring.result}-test-topic"
  protocol_1            = "sqs"
}

module "ec2_asg_centos7_encrypted_test" {
  source = "../../module"

  asg_count                    = 1
  ec2_os                       = "centos7"
  enable_scaling_notification  = true
  encrypt_primary_ebs_volume   = true
  encrypt_secondary_ebs_volume = true
  key_pair                     = "CircleCI"
  name                         = "${random_string.name_rstring.result}-ec2_asg_centos7_encrypted"
  scaling_notification_topic   = module.sns.topic_arn
  secondary_ebs_volume_size    = 60
  security_groups              = [module.vpc.default_sg]
  ssm_patching_group           = "Group1Patching"
  subnets                      = slice(module.vpc.public_subnets, 0, 2)

  tags = local.tags

  tags_asg = local.tags_asg
}

module "ec2_asg_centos7_with_codedeploy_test" {
  source = "../../module"

  asg_count                              = 2
  ec2_os                                 = "centos7"
  enable_scaling_notification            = true
  install_codedeploy_agent               = true
  instance_role_managed_policy_arn_count = 3
  key_pair                               = "CircleCI"
  name                                   = "${random_string.name_rstring.result}-ec2_asg_centos7_with_codedeploy"
  scaling_notification_topic             = module.sns.topic_arn
  secondary_ebs_volume_size              = 60
  security_groups                        = [module.vpc.default_sg]
  ssm_patching_group                     = "Group1Patching"
  subnets                                = slice(module.vpc.public_subnets, 0, 2)

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
          Packages = "bind bindutils"
        },
        documentType = "SSMDocument"
      },
      name           = "InstallBindAndTools",
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

  tags = local.tags

  tags_asg = local.tags_asg
}

module "ec2_asg_centos7_no_codedeploy_test" {
  source = "../../module"

  ec2_os                      = "centos7"
  enable_scaling_notification = true
  install_codedeploy_agent    = false
  key_pair                    = "CircleCI"
  name                        = "${random_string.name_rstring.result}-ec2_asg_centos7_no_codedeploy"
  scaling_notification_topic  = module.sns.topic_arn
  secondary_ebs_volume_size   = "60"
  security_groups             = [module.vpc.default_sg]
  ssm_patching_group          = "Group1Patching"
  subnets                     = slice(module.vpc.public_subnets, 0, 2)

  tags = local.tags

  tags_asg = local.tags_asg
}

module "ec2_asg_windows_with_codedeploy_test" {
  source = "../../module"

  ec2_os                                 = "windows2016"
  enable_scaling_actions                 = false
  enable_scaling_notification            = true
  install_codedeploy_agent               = true
  instance_role_managed_policy_arn_count = 3
  key_pair                               = "CircleCI"
  name                                   = "${random_string.name_rstring.result}-ec2_asg_windows_with_codedeploy"
  scaling_notification_topic             = module.sns.topic_arn
  secondary_ebs_volume_size              = 60
  security_groups                        = [module.vpc.default_sg]
  ssm_patching_group                     = "Group1Patching"
  subnets                                = slice(module.vpc.public_subnets, 0, 2)

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  ssm_bootstrap_list = [
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Datadog",
        documentType = "SSMDocument"
      },
      name           = "InstallDataDog",
      timeoutSeconds = 300
    },
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "AWS-RunPowerShellScript",
        documentParameters = {
          commands = ["echo $null >> C:\testfile"]
        },
        documentType = "SSMDocument"
      },
      name           = "CreateFile",
      timeoutSeconds = 300
    },
  ]

  tags = local.tags

  tags_asg = local.tags_asg
}

module "ec2_asg_windows_no_codedeploy_test" {
  source = "../../module"

  ec2_os                      = "windows2016"
  enable_scaling_actions      = false
  enable_scaling_notification = true
  install_codedeploy_agent    = false
  key_pair                    = "CircleCI"
  name                        = "${random_string.name_rstring.result}-ec2_asg_windows_no_codedeploy"
  scaling_notification_topic  = module.sns.topic_arn
  secondary_ebs_volume_size   = 60
  security_groups             = [module.vpc.default_sg]
  ssm_patching_group          = "Group1Patching"
  subnets                     = slice(module.vpc.public_subnets, 0, 2)

  tags = local.tags

  tags_asg = local.tags_asg
}
