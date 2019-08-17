#### VARIABLES ####

variable "availability_zone" {
  type = string
  default = "us-east-1a"
}

variable "aws_ebs_volume" {
  type = map
  default = {
    size = 16
  }
}

variable "aws_instance" {
  type = map
  default = {
    key_name = "multi_wordpress"
  }
}

#### END ####

#### MAIN ####

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "this" {
  name = "SG-multi_wordpress"
  description = "Security group for multi_wordpress project"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "http"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "ssh"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "icmp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "multi_wordpress"
  }
}

resource "aws_ebs_volume" "this" {
  # needs to persist
  lifecycle {
    prevent_destroy = true
  }

  availability_zone = var.availability_zone

  # NOTE: When changing the size, iops or type of an instance, there are considerations to be aware of that Amazon have written about this.

  size = var.aws_ebs_volume.size
  type = "gp2"
  # iops = 

  encrypted = false
  # kms_key_id = 
  tags = {
    Name = "multi_wordpress"
  }
}

resource "aws_volume_attachment" "this" {
  # refer to https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html#available-ec2-device-names
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.this.id}"
  instance_id = "${aws_instance.this.id}"
}

resource "aws_eip" "this" {
  vpc = true
  instance = aws_instance.this.id
  tags = {
    Name = "multi_wordpress"
  }
}

resource "aws_instance" "this" {
  ami = "ami-035b3c7efe6d061d5" # Amazon Linux 2018
  instance_type = "t2.micro"
  availability_zone = var.availability_zone
  key_name = var.aws_instance.key_name
  tags = {
    Name = "multi_wordpress"
  }
}

#### END ####