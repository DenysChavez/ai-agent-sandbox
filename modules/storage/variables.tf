variable "project_name" {
  type    = string
  default = "ai-agent-sandbox"
}

variable "ec2_role_arn" {
  description = "ARN del Role de la EC2, para restringir acceso al bucket"
  type        = string
}
