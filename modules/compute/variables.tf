variable "project_name" {
  type    = string
  default = "ai-agent-sandbox"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.small"
}

variable "private_subnet_id" {
  description = "ID de la subnet privada donde vive la EC2"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "instance_profile_name" {
  description = "Nombre del instance profile IAM para la EC2"
  type        = string
}

variable "root_volume_size" {
  description = "Tamano del disco raiz en GB"
  type        = number
  default     = 20
}
