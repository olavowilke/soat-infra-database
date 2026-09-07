# SG do RDS: unica regra de ingresso, liberando 5432 para quem veste o SG
# "cracha" publicado por infra-k8s (nos do EKS e a Lambda de autenticacao).
# Usar source_security_group_id (nunca CIDR) e o que permite adicionar novos
# clientes do banco no futuro sem tocar nesta stack nem reabrir a regra.
resource "aws_security_group" "db" {
  name        = "${local.prefixo}-db"
  description = "Acesso ao RDS PostgreSQL a partir do SG compartilhado de clientes do banco"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  tags = {
    Name = "${local.prefixo}-db"
  }
}

resource "aws_security_group_rule" "db_ingress_postgres" {
  type                     = "ingress"
  security_group_id        = aws_security_group.db.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = data.aws_ssm_parameter.db_client_sg_id.value
  description              = "PostgreSQL a partir do SG cracha (EKS + Lambda de autenticacao)"
}

# Egresso padrao (libera tudo) — a instancia RDS nao inicia conexoes de saida
# relevantes, mas remover o default exigiria abrir excecoes especificas sem
# beneficio de seguranca real neste caso.
resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.db.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
