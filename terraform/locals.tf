locals {
  prefixo  = "${var.project}-${var.environment}"
  ssm_base = "/${var.project}/${var.environment}"

  # Mantidos identicos aos defaults de spring.datasource em application.yml
  # para que a aplicacao funcione sem alteracao ao trocar de banco local para o RDS.
  nome_banco     = "oficina_db"
  usuario_master = "oficina"
}
