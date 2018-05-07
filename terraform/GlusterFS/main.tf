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
  aws_placement_group       = "${aws_placement_group.glusterFS.id}"
  launch_conffiguration     = "${aws_launch_configuration.glusterFS_as_conf.id}"
  vpc_zone_identifier       = "${aws_subnet.main.*}"
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

resource "aws_subnet" "main" {
  //create a subnet for each subnet passed as argument
  count      = "${length(split(",",var.subnets))}"
  vpc_id     = "${var.vpc}"
  cidr_block = "${var.subnets[count.index]}"
}
