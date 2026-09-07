# Publicados para infra-k8s (deployment da aplicacao) e lambda-auth lerem via
# `data "aws_ssm_parameter"`, sem acoplar remote states entre os repositorios.
resource "aws_ssm_parameter" "db_host" {
  name  = "${local.ssm_base}/database/host"
  type  = "String"
  value = aws_db_instance.oficina.address
}

resource "aws_ssm_parameter" "db_port" {
  name  = "${local.ssm_base}/database/port"
  type  = "String"
  value = tostring(aws_db_instance.oficina.port)
}

resource "aws_ssm_parameter" "db_name" {
  name  = "${local.ssm_base}/database/name"
  type  = "String"
  value = local.nome_banco
}

resource "aws_ssm_parameter" "db_secret_arn" {
  name  = "${local.ssm_base}/database/secret-arn"
  type  = "String"
  value = aws_secretsmanager_secret.db.arn
}
