provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.6"

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

resource "aws_sqs_queue" "ec2-asg-test_sqs" {
  name = "${random_string.sqs_rstring.result}-my-example-queue"
}

module "sns_sqs" {
  source     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.0.2"
  topic_name = "${random_string.sqs_rstring.result}-ec2-asg-test-topic"

  create_subscription_1 = true
  protocol_1            = "sqs"
  endpoint_1            = "${aws_sqs_queue.ec2-asg-test_sqs.arn}"
}

module "ec2_asg" {
  source    = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_asg?ref=v0.0.11"
  ec2_os    = "centos7"
  asg_count = "2"

  load_balancer_names                    = ["${aws_elb.my_elb.name}"]
  cw_low_operator                        = "LessThanThreshold"
  instance_role_managed_policy_arns      = ["${aws_iam_policy.test_policy_1.arn}", "${aws_iam_policy.test_policy_2.arn}"]
  instance_role_managed_policy_arn_count = "2"
  environment                            = "Development"
  ssm_association_refresh_rate           = "rate(1 day)"
  cw_scaling_metric                      = "CPUUtilization"
  enable_ebs_optimization                = "False"
  scaling_min                            = "1"
  cloudwatch_log_retention               = "30"
  secondary_ebs_volume_size              = "60"
  rackspace_managed                      = true
  cw_high_period                         = "60"
  enable_scaling_notification            = true
  subnets                                = ["${element(module.vpc.public_subnets, 0)}", "${element(module.vpc.public_subnets, 1)}"]
  secondary_ebs_volume_iops              = "0"
  ec2_scale_down_adjustment              = "1"
  image_id                               = "${data.aws_ami.amazon_centos_7.image_id}"
  cw_low_period                          = "300"
  key_pair                               = "my_ec2_key_name"
  tenancy                                = "default"
  backup_tag_value                       = "False"
  ec2_scale_down_cool_down               = "60"
  instance_type                          = "t2.micro"

  # If ALB target groups are being used, one can specify ARNs like the commented line below.
  #target_group_arns                      = ["${aws_lb_target_group.my_tg.arn}"]
  secondary_ebs_volume_type = "gp2"

  ec2_scale_up_adjustment    = "1"
  cw_high_threshold          = "60"
  scaling_notification_topic = "${aws_sns_topic.my_test_sns.arn}"
  cw_low_threshold           = "30"
  resource_name              = "my_test_instance"
  ec2_scale_up_cool_down     = "60"
  ssm_patching_group         = "MyPatchGroup1"
  health_check_grace_period  = "300"
  security_group_list        = ["${module.vpc.default_sg}"]
  perform_ssm_inventory_tag  = "True"
  terminated_instances       = "30"
  health_check_type          = "EC2"
  cw_low_evaluations         = "3"
  cw_high_evaluations        = "3"
  primary_ebs_volume_iops    = "0"
  detailed_monitoring        = "True"
  primary_ebs_volume_type    = "gp2"
  primary_ebs_volume_size    = "60"
  scaling_max                = "2"
  cw_high_operator           = "GreaterThanThreshold"
  install_codedeploy_agent   = "False"

  addtional_ssm_bootstrap_list = [
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

  addtional_ssm_bootstrap_step_count = "2"

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

  encrypt_secondary_ebs_volume  = "False"
  asg_wait_for_capacity_timeout = "10m"
}
