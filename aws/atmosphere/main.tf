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

provider "aws" {
	region = "ap-southeast-1"
}

data "aws_vpc" "default" {
	default = true
}

data "aws_security_group" "default" {
	name   = "default"
	vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "rds_ingress" {
	type              = "ingress"
	from_port         = 5432
	to_port           = 5432
	protocol          = "tcp"
	cidr_blocks       = ["0.0.0.0/0"]
	security_group_id = data.aws_security_group.default.id
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
