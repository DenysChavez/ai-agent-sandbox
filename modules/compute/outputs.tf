output "instance_id" {
  value = aws_instance.agent.id
}

output "security_group_id" {
  value = aws_security_group.ec2_agent_sg.id
}

output "instance_arn" {
  value = aws_instance.agent.arn
}
