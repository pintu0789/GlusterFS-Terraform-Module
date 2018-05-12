resource "aws_placement_group" "glusterFS" {
  name     = "glusterFS Placement Group"
  strategy = "spread"
}

resource "aws_autoscaling_group" "glusterFS" {
  name = "glusterFS ASG"

  //static sizing to meet minimum requirements but still handle lifecycle management in case a node dies. 
  max_size                  = 3
  min_size                  = 3
  desired_capacity          = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  placement_group           = "${aws_placement_group.glusterFS.id}"
  launch_configuration      = "${aws_launch_configuration.glusterFS_as_conf.id}"
  vpc_zone_identifier       = ["${aws_subnet.main.*.id}"]
}

data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/glusterFS-init.tpl")}"
}

resource "aws_launch_configuration" "glusterFS_as_conf" {
  name          = "glusterFS Launch Config"
  image_id      = "${data.aws_ami.aws_linux.id}"
  instance_type = "${var.size}"
  user_data     = "${data.template_file.init.rendered}"
}

//I hate this bug https://github.com/hashicorp/terraform/issues/12570
//Need to create local varialbe instance for count to be computed properly
locals {
  subnet_count = "${length(var.subnets)}"
}

resource "aws_subnet" "main" {
  //create a subnet for each subnet passed as argument
  count      = "${local.subnet_count}"
  vpc_id     = "${var.vpc}"
  cidr_block = "${element(var.subnets, count.index)}"

  /*
  output "all_subnets" {
    value = "${aws_subnet.main.*.id}"
  }*/
}
