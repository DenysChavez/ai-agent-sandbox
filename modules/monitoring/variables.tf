variable "project_name" {
  type    = string
  default = "ai-agent-sandbox"
}

variable "billing_threshold_usd" {
  description = "Umbral en USD para disparar la alarma de billing"
  type        = number
  default     = 15
}

variable "alert_email" {
  description = "Email donde recibir la alerta de billing"
  type        = string
}
