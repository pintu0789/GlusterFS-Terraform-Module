provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

module "GlusterFS" {
  source  = "./GlusterFS/"
  subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  vpc     = "${aws_vpc.main.id}"
}
