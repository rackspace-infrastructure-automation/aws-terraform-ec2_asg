provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.10"

  vpc_name = "EC2-ASG-BaseNetwork-Test1"
}

data "aws_region" "current_region" {}

data "aws_ami" "amazon_centos_7" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS*"]
  }
}

resource "random_string" "password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "random_string" "sqs_rstring" {
  length  = 18
  upper   = false
  special = false
}

resource "aws_sqs_queue" "ec2_asg_test_sqs" {
  name = "${random_string.sqs_rstring.result}-my-example-queue"
}

module "sns_sqs" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.0.2"

  topic_name = "${random_string.sqs_rstring.result}-ec2-asg-test-topic"

  create_subscription_1 = true
  protocol_1            = "sqs"
  endpoint_1            = "${aws_sqs_queue.ec2_asg_test_sqs.arn}"
}

module "ec2_asg" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg?ref=v0.0.26"

  additional_ssm_bootstrap_step_count    = 2
  asg_count                              = 2
  asg_wait_for_capacity_timeout          = "10m"
  backup_tag_value                       = "False"
  cloudwatch_log_retention               = 30
  custom_cw_agent_config_ssm_param       = "${aws_ssm_parameter.custom_cwagentparam.name}"
  cw_high_evaluations                    = 3
  cw_high_operator                       = "GreaterThanThreshold"
  cw_high_period                         = 60
  cw_high_threshold                      = 60
  cw_low_evaluations                     = 3
  cw_low_operator                        = "LessThanThreshold"
  cw_low_period                          = 300
  cw_low_threshold                       = 30
  cw_scaling_metric                      = "CPUUtilization"
  detailed_monitoring                    = true
  ec2_os                                 = "centos7"
  ec2_scale_down_adjustment              = 1
  ec2_scale_down_cool_down               = 60
  ec2_scale_up_adjustment                = 1
  ec2_scale_up_cool_down                 = 60
  enable_ebs_optimization                = false
  enable_scaling_notification            = true
  encrypt_secondary_ebs_volume           = false
  environment                            = "Development"
  health_check_grace_period              = 300
  health_check_type                      = "EC2"
  image_id                               = "${data.aws_ami.amazon_centos_7.image_id}"
  install_codedeploy_agent               = false
  instance_role_managed_policy_arn_count = 2
  instance_type                          = "t2.micro"
  key_pair                               = "my_ec2_key_name"
  load_balancer_names                    = ["${aws_elb.my_elb.name}"]
  perform_ssm_inventory_tag              = "True"
  primary_ebs_volume_iops                = 0
  primary_ebs_volume_size                = 60
  primary_ebs_volume_type                = "gp2"
  provide_custom_cw_agent_config         = true
  rackspace_managed                      = true
  resource_name                          = "my_test_instance"
  scaling_max                            = 2
  scaling_min                            = 1
  scaling_notification_topic             = "${aws_sns_topic.my_test_sns.arn}"
  secondary_ebs_volume_iops              = 0
  secondary_ebs_volume_size              = 60
  secondary_ebs_volume_type              = "gp2"
  security_group_list                    = ["${module.vpc.default_sg}"]
  ssm_association_refresh_rate           = "rate(1 day)"
  ssm_patching_group                     = "MyPatchGroup1"
  subnets                                = "${slice(module.vpc.public_subnets, 0, 2)}"
  tenancy                                = "default"
  terminated_instances                   = 30

  # using an existing ebs snapshot id instead of creating a new ebs volume
  # secondary_ebs_volume_existing_id = "snap-12393923"


  # If ALB target groups are being used, one can specify ARNs like the commented line below.
  # target_group_arns                      = ["${aws_lb_target_group.my_tg.arn}"]

  additional_ssm_bootstrap_list = [
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
          "documentParameters": {
            "Packages": "bind bindutils"
          },
          "documentType": "SSMDocument"
        },
        "name": "InstallBindAndTools",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AWS-RunShellScript",
          "documentParameters": {
            "commands": ["touch /tmp/myfile"]
          },
          "documentType": "SSMDocument"
        },
        "name": "CreateFile",
        "timeoutSeconds": 300
      }
EOF
    },
  ]
  additional_tags = [
    {
      key                 = "MyTag1"
      value               = "Myvalue1"
      propagate_at_launch = true
    },
    {
      key                 = "MyTag2"
      value               = "Myvalue2"
      propagate_at_launch = true
    },
    {
      key                 = "MyTag3"
      value               = "Myvalue3"
      propagate_at_launch = true
    },
  ]
  instance_role_managed_policy_arns = ["${aws_iam_policy.test_policy_1.arn}", "${aws_iam_policy.test_policy_2.arn}"]
}

resource "random_string" "res_name" {
  length  = 8
  upper   = false
  lower   = true
  special = false
  number  = false
}

resource "aws_ssm_parameter" "custom_cwagentparam" {
  name        = "custom_cw_param-${random_string.res_name.result}"
  description = "Custom Cloudwatch Agent configuration"
  type        = "String"
  value       = "${data.template_file.custom_cwagentparam.rendered}"
}

data "template_file" "custom_cwagentparam" {
  template = "${file("./text/linux_cw_agent_param.json")}"

  vars {
    application_log_group_name = "custom_app_log_group_name"
    system_log_group_name      = "custom_system_log_group_name"
  }
}
