## Get instance AMI
data "aws_ami" "softserve-ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["softserve-ami*"]
  }
}
