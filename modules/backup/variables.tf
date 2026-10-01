variable "project_name" {
  type    = string
  default = "ai-agent-sandbox"
}

variable "instance_arn" {
  description = "ARN de la instancia EC2 a respaldar"
  type        = string
}

variable "retention_days" {
  description = "Dias que se conserva cada backup antes de borrarse automaticamente"
  type        = number
  default     = 7
}
