module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-tf"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0adbc3f247a4e7736"] #replace your SG
  subnet_id = "subnet-0f523ff9e680cb86b" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0adbc3f247a4e7736"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0f523ff9e680cb86b"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")
  tags = {
    Name = "jenkins-agent"
  }
}

# module "nexus" {
#   source  = "terraform-aws-modules/ec2-instance/aws"

#   name = "nexus"

#   instance_type          = "t3.medium"
#   vpc_security_group_ids = ["sg-0adbc3f247a4e7736"]
#   # convert StringList to list and get first element
#   subnet_id = "subnet-0f523ff9e680cb86b"
#   ami = data.aws_ami.nexus_ami_info.id
#   key_name = aws_key_pair.tools.key_name
#   tags = {
#     Name = "nexus"
#   }
# }

resource "aws_instance" "nexus" {
  ami = "ami-0b4f379183e5706b9"
  instance_type = "t3.medium"
  tags = {
    Name = "nexus"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      records = [
        aws_instance.nexus.private_ip
      ]
    }
  ]

}