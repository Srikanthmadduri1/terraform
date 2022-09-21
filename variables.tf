
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

# Linux 18.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-05fa00d4c63e32376"
    us-east-2 = "ami-05fa00d4c63e32376"
  }
}