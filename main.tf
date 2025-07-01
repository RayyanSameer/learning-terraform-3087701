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

module  "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
 
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  subnet_id = modules.blog_vpc.public_subnets[0]

  tags = {
    Name = "HelloWorld"
  }
  
  vpc_groups_ids = [aws_security_group.blog.id]

resource aws_security_group "TerraformSecurityGroup" {
  name = "TerraformSecurityGroup"
  vpc.id = modules.blog_vpc.public_subnets
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
