terraform {
  required_version = ">=0.12"
}
provider "aws" {
  access_key = "AKIAZPIIRQKEXTFJ3AC6"
  secret_key = "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"
  region = "us-east-1"
}
resource "aws_vpc" "srikanth" {
    cidr_block ="10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      "name" = "srikanth"
    }
}
resource "aws_internet_gateway" "srikanth-igw" {
    vpc_id = aws_vpc.srikanth.id
}
resource "aws_route" "srikanth-route" {
    route_table_id = aws_vpc.srikanth.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.srikanth-igw.id

  
}
resource "aws_subnet" "public-subnet-1" {
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    vpc_id = aws_vpc.srikanth.id
    map_public_ip_on_launch = true
    tags = {
      "public-subnet-1" = "public-subnet-1"
    }
}
resource "aws_subnet" "private-subnet-2" {
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    vpc_id = aws_vpc.srikanth.id
    map_public_ip_on_launch = false
    tags = {
      "private-subnet-2" = "private-subnet-2"
    }

}
resource "aws_subnet" "public-subnet-3" {
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1b"
    vpc_id = aws_vpc.srikanth.id
    map_public_ip_on_launch = true
    tags = {
      "public-subnet-3" = "public-subnet-3"
    }
}
resource "aws_subnet" "private-subnet-4" {
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    vpc_id = aws_vpc.srikanth.id
    map_public_ip_on_launch = false
    tags = {
      "private-subnet-4" = "private-subnet-4"
    }
    
}
resource "aws_security_group" "srikanth-security-groups-elb" {
    vpc_id = aws_vpc.srikanth.id
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # outbound internet access
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Our srikanth-t-vpc security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "srikanth-security-ssh" {
  description = "Used in the terraform"
  vpc_id      = aws_vpc.srikanth.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_route_table" "srikanth-route" {
    vpc_id = aws_vpc.srikanth.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.srikanth-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.srikanth-igw.id
  }
}
resource "aws_instance" "srikanth-instance" {
    connection {
      type = "ssh"
      user = "ami-05fa00d4c63e32376"
      host = self.public_ip
    }
    instance_type = "t2.micro"
    ami = var.aws_amis[var.aws_region]
    key_name = aws_key_pair.auth.id
    vpc_security_group_ids = [ aws_security_group.srikanth-security-ssh.id]
    subnet_id = aws_subnet.public-subnet-1.id

}
resource "aws_key_pair" "auth" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUneEEFNId/sI76At+U4ImJ6yUjxGfRRlBvoDGulRtLogN4BDTPmiaYCAsbdNpgpdLGKXcqpNUfw9QApMmDMyqyPwsa++XxX7yVpGK23uo5QNaEmY9g6NT2ejP09SQaahKcIvsGJCF3wmM3ra0H6/jQo0hVjJ7iZIwEVMUIo1FHWMn0xibmGYnEvWIffjK/UzWvShkLVcSD3mdBBglreqLHGS3W736sMEQk+eolGQReNpN+lkvjHTz4xdncvF49CaA2so1aKv4Ribcs6I2PeBLH6fA4vyjJWdSvTAqGereRe4Kp7Li5S/ndAOb09TOnfbuhkdiSkQ/UtSYQK+CWVT7 rsa-key-20220920"
}
resource "aws_instance" "srikanth-instance-1" {
    connection {
      type = "ssh"
      user = "ami-05fa00d4c63e32376"
      host = self.public_ip
    }
    instance_type = "t2.micro"
    ami = var.aws_amis[var.aws_region]
    key_name = aws_key_pair.auth.id
    vpc_security_group_ids = [ aws_security_group.srikanth-security-ssh.id]
    subnet_id = aws_subnet.private-subnet-2.id
}
resource "aws_instance" "srikanth-instance-2" {
    connection {
      type = "ssh"
      user = "ami-05fa00d4c63e32376"
      host = self.public_ip
    }
    instance_type = "t2.micro"
    ami = var.aws_amis[var.aws_region]
    key_name = aws_key_pair.auth.id
    vpc_security_group_ids = [ aws_security_group.srikanth-security-ssh.id]
    subnet_id = aws_subnet.public-subnet-3.id
}
