data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default"{
  default = true
}
resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  tags = {
    Name = "HelloWorld"
  }
  
  vpc_groups_ids = [aws_security_group.blog.id]

resource aws_security_group "TerraformSecurityGroup" {
  name = "TerraformSecurityGroup"
  vpc.id = data.aws_vpc.default.id
}


resource "aws_security_group_rule" "blog.https.out"{
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"]
  aws_security_group.id = aws_security_group.blog.id


}

resource "aws_security_group_rule" "blog.https.in"{
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = tcp
  cidr_blocks = ["0.0.0.0/0"]
  aws_security_group.id = aws_security_group.blog.id


}
