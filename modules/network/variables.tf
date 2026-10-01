variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block para la subnet publica"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block para la subnet privada"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "AZ donde crear las subnets"
  type        = string
  default     = "us-east-1a"
}

variable "project_name" {
  description = "Nombre del proyecto, usado para tags"
  type        = string
  default     = "ai-agent-sandbox"
}
