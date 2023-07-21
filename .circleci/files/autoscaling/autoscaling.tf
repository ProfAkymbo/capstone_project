#  VPC data

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "myvpc"
  }
}


# Availabiltiy Zone configuration

data "aws_availability_zones" "available" {
  state = "available"
}

#  Subnet configuration

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.pub_sub_cidr[count.index]
  count                   = 2
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
}


#  Security Group Configuration

resource "aws_security_group" "security_group" {
  name        = "security-group"
  description = "Security Group"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTPS from web"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
  tags = {
    Name = "security_group"
  }
}


# Internet Gateway Configuration 

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "internet_gateway"
  }
}


# public route table configuration

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  }




#  EC2 Instance 

resource "aws_launch_configuration" "launch_config" {
  name_prefix     = "launch-config"
  image_id        = "ami-0d925fac3dbba7ca2"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.security_group.id]

}

resource "aws_autoscaling_group" "project_asg" {

  vpc_zone_identifier       = [for i in aws_subnet.public_subnet[*] : i.id]
  launch_configuration      = aws_launch_configuration.launch_config.name
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 30
  health_check_type         = "EC2"

  tag {
    key                 = "Name"
    value               = "ec2 instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
}