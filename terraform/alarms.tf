# Topico so existe quando ha um e-mail para notificar — evita alarme "mudo"
# apontando para um SNS sem inscritos.
resource "aws_sns_topic" "alarmes" {
  count = var.alarm_email != "" ? 1 : 0
  name  = "${local.prefixo}-db-alarmes"
}

resource "aws_sns_topic_subscription" "alarmes_email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarmes[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

locals {
  alarm_actions = var.alarm_email != "" ? [aws_sns_topic.alarmes[0].arn] : []

  # FreeStorageSpace vem em bytes; o limite e 10% do armazenamento alocado.
  free_storage_threshold_bytes = var.allocated_storage * 1024 * 1024 * 1024 * 0.1
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${local.prefixo}-db-cpu-alta"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oficina.id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "conexoes" {
  alarm_name          = "${local.prefixo}-db-conexoes-altas"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.max_connections_alarm * 0.8
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oficina.id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "armazenamento_livre" {
  alarm_name          = "${local.prefixo}-db-armazenamento-baixo"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = local.free_storage_threshold_bytes
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oficina.id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "latencia_leitura" {
  alarm_name          = "${local.prefixo}-db-latencia-leitura-alta"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 0.05
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.oficina.id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.alarm_actions
}
