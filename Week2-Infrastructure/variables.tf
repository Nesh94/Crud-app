variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "af-south-1"
}

variable "project_name" {
  description = "Name prefix used for tagging and naming resources"
  type        = string
  default     = "crud-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
  default     = ["af-south-1a", "af-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for the app servers"
  type        = string
  default     = "t3.micro"
}

variable "docker_image" {
  description = "Docker Hub image to run on each EC2 instance"
  type        = string
  default     = "mutshutshudzi/crud-app:latest"
}

variable "app_port" {
  description = "Port the app listens on inside the container"
  type        = number
  default     = 3000
}

variable "min_size" {
  description = "Minimum number of app instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of app instances"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of app instances"
  type        = number
  default     = 2
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "cruddb"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password for RDS (set this in terraform.tfvars, never commit it)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}
