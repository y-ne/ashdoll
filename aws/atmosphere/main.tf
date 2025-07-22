terraform {
	required_providers {
		aws = {
    		source  = "hashicorp/aws"
      		version = "~> 5.0"
    	}
  	}
}

variable "db_username" {
	description = "database username"
	type        = string
}

variable "db_password" {
	description = "database password"
	type        = string
	sensitive   = true
}

variable "ssh_public_key" {
	description = "ssh public key"
	type        = string
	sensitive   = true
}

provider "aws" {
	region = "ap-southeast-1"
}

data "aws_security_group" "default" {
	name   = "default"
	vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
	default = true
}

data "aws_ami" "ubuntu_ami" {
	most_recent = true
	owners      = ["099720109477"]
	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
	}
}

resource "aws_security_group_rule" "postgres" {
	type              = "ingress"
	from_port         = 5432
	to_port           = 5432
	protocol          = "tcp"
	cidr_blocks       = ["0.0.0.0/0"]
	security_group_id = data.aws_security_group.default.id
}

resource "aws_security_group_rule" "ssh" {
	type              = "ingress"
	from_port         = 22
	to_port           = 22
	protocol          = "tcp"
	cidr_blocks       = ["0.0.0.0/0"]
	security_group_id = data.aws_security_group.default.id
}

resource "aws_key_pair" "atmosphere_key" {
	key_name   = "yy"
	public_key = var.ssh_public_key
}

resource "aws_instance" "ubuntu" {
	ami           = data.aws_ami.ubuntu_ami.id
	instance_type = "t3.micro"
	key_name      = aws_key_pair.atmosphere_key.key_name
	vpc_security_group_ids = [data.aws_security_group.default.id]

	root_block_device {
		volume_type = "gp3"
   		volume_size = 10
     	encrypted   = true
 	}

  	tags = {
   		Name = "atmosphere ubuntu"
   	}
}

resource "aws_db_instance" "postgres" {
	identifier = "atmosphere-db"

	instance_class         = "db.t3.micro"
	allocated_storage      = 20
	max_allocated_storage  = 20
	storage_type          = "gp2"
	storage_encrypted     = false

	engine         = "postgres"
	engine_version = "17.5"
	username       = var.db_username
	password       = var.db_password

	publicly_accessible = true

	multi_az            = false
	deletion_protection = false
	skip_final_snapshot = true

	backup_retention_period = 7
	backup_window          = "03:00-04:00"
	maintenance_window     = "sun:04:00-sun:05:00"

	tags = {
		Name = "atmosphere psql"
	}
}

output "database_info" {
	description = "database info"
	value = {
    	endpoint = aws_db_instance.postgres.endpoint
     	port     = aws_db_instance.postgres.port
      	username = var.db_username
  	}
}

output "instance_info" {
   description = "instance info"
   value = {
   	public_ip = aws_instance.ubuntu.public_ip
   	ssh       = "ssh -i ~/.ssh/yy ubuntu@${aws_instance.ubuntu.public_ip}"
   }
}
