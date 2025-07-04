terraform {
	required_providers {
    	aws = {
     		source  = "hashicorp/aws"
        	version = "~> 5.0"
     	}
  	}
}

provider "aws" {
  	region = "ap-southeast-1"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  sensitive   = true
}

data "aws_ssm_parameter" "debian12_ami" {
	name = "/aws/service/debian/release/bookworm/latest/amd64"
}

resource "aws_key_pair" "runemaster_key" {
	key_name   = "runemaster-key"
	public_key = var.ssh_public_key
}

resource "aws_security_group" "ssh_access" {
	name_prefix = "ssh-access-"
	description = "Allow SSH access"

	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "runemaster" {
	ami           = data.aws_ssm_parameter.debian12_ami.value
	instance_type = "t2.micro"
	key_name      = aws_key_pair.runemaster_key.key_name
	vpc_security_group_ids = [aws_security_group.ssh_access.id]

  	tags = {
    	Name = "runemaster-vm"
   	}
}

output "ip" {
	value = aws_instance.runemaster.public_ip
}
