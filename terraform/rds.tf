resource "aws_db_subnet_group" "oficina" {
  name       = "${local.prefixo}-db"
  subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  tags = {
    Name = "${local.prefixo}-db"
  }
}

resource "aws_db_parameter_group" "oficina" {
  name   = "${local.prefixo}-postgres16"
  family = "postgres16"

  # Observabilidade minima para investigar queries lentas sem instrumentar a
  # aplicacao: pg_stat_statements acumula estatisticas por query, e o log
  # registra statements acima de 1s e novas conexoes.
  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

# Senha gerada uma unica vez e guardada apenas no Secrets Manager — nunca em
# arquivo versionado nem em output do Terraform.
resource "random_password" "master" {
  length  = 32
  special = false # evita escapes em connection strings
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${local.prefixo}/database/credentials"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = local.usuario_master
    password = random_password.master.result
    engine   = "postgres"
    host     = aws_db_instance.oficina.address
    port     = aws_db_instance.oficina.port
    dbname   = local.nome_banco
  })
}

resource "aws_db_instance" "oficina" {
  identifier     = "${local.prefixo}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = local.nome_banco
  username = local.usuario_master
  password = random_password.master.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.oficina.name
  parameter_group_name   = aws_db_parameter_group.oficina.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_days

  performance_insights_enabled = var.performance_insights_enabled

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  auto_minor_version_upgrade      = true

  # Em prod nunca descartamos o banco sem snapshot; em homolog o ciclo de
  # destroy/recreate precisa ser rapido para reduzir custo.
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${local.prefixo}-db-final" : null
  deletion_protection       = var.deletion_protection

  # Fora de prod aplicamos mudancas imediatamente para agilizar iteracao;
  # em prod as alteracoes esperam a proxima janela de manutencao.
  apply_immediately = var.environment != "prod"

  tags = {
    Name = "${local.prefixo}-db"
  }
}
