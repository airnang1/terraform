provider "aws" {
  region = "ap-southeast-1"
}

# Now is EC2
resource "aws_instance" "jenkins" {
  ami           = "ami-0753e0e42b20e96e3"
  instance_type = "t2.micro"
  # add SG for EC2
  security_groups = [aws_security_group.SG-airnang.name]
  # add public key for EC2
  #   key_name = aws_key_pair.pubkey.key_name
  key_name = "EC2_airnang2"
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"

    # Mention the exact private key name which will be generated 
    private_key = file("key/EC2_airnang.pem")
    timeout     = "4m"
  }

  tags = {
    Name = "t2-jenkins1"
  }
}

# Security Group
resource "aws_security_group" "SG-airnang" {
  name = "Allow all"

  # inbound
  ingress {
    from_port   = 0
    to_port     = 6556
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-airnang"
  }

}

##############################
# add public key
# resource "aws_key_pair" "pubkey" {
#   key_name   = "EC2_airnang"
#   public_key = file("key/EC2_airnang.pem")
# }

# EIP
resource "aws_eip" "elasticip" {
  instance = aws_instance.jenkins.id
}

# ouput EIP
output "eip" {
  value = aws_eip.elasticip.public_ip
}

################################
# create public key 
# variable "key_name" {}

# resource "tls_private_key" "example" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "generated_key" {
#   key_name   = var.key_name
#   public_key = tls_private_key.example.public_key_openssh
# }

# # EIP
# resource "aws_eip" "elasticip" {
#   instance = aws_instance.jenkins.id
# }

# # ouput EIP
# output "eip" {
#     value = aws_eip.elasticip.public_ip
# }

# output "private_key" {
#   value     = tls_private_key.example.private_key_pem
#   sensitive = true
# }
