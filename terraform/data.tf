# Contrato entre as stacks (ADR-0005): cada repositorio publica seus outputs no
# SSM Parameter Store e os demais leem por `data`, sem acoplar remote states.
#
# Ordem de aplicacao: infra-k8s -> infra-database -> lambda-auth.
# A rede (VPC, subnets, SG de cliente do banco) e criada por infra-k8s;
# esta stack apenas consome o que ja foi publicado.

data "aws_ssm_parameter" "vpc_id" {
  name = "${local.ssm_base}/network/vpc-id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "${local.ssm_base}/network/private-subnet-ids"
}

# SG "cracha": nos do EKS e a Lambda de autenticacao o vestem, sem nenhuma regra
# propria. Isso quebra a dependencia circular entre as stacks — o SG do banco
# (criado aqui) so precisa saber o ID desse cracha, nunca dos recursos que o usam.
data "aws_ssm_parameter" "db_client_sg_id" {
  name = "${local.ssm_base}/network/db-client-sg-id"
}
