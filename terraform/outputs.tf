# O ARN do segredo nao e sensivel (a senha em si nunca sai como output); e so
# uma referencia que outras stacks/operadores usam para buscar a credencial.
output "db_endpoint" {
  description = "Endpoint (host:port) da instancia RDS"
  value       = aws_db_instance.oficina.endpoint
}

output "db_secret_arn" {
  description = "ARN do segredo no Secrets Manager com as credenciais do banco"
  value       = aws_secretsmanager_secret.db.arn
}

output "db_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.db.id
}
