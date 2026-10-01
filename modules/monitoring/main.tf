# SNS topic: el "canal" por donde se manda la notificacion
resource "aws_sns_topic" "billing_alerts" {
  name = "${var.project_name}-billing-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# La alarma en si - solo funciona en us-east-1
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "${var.project_name}-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600  # 6 horas
  statistic           = "Maximum"
  threshold           = var.billing_threshold_usd
  alarm_description   = "Alerta si el gasto estimado de la cuenta supera ${var.billing_threshold_usd} USD"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]
}

# Log group para logs del sistema (retencion corta para no acumular costo)
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/${var.project_name}/ec2/system"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-ec2-logs"
  }
}
