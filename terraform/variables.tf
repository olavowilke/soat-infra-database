variable "project" {
  description = "Prefixo de nomes dos recursos"
  type        = string
  default     = "oficina"
}

variable "environment" {
  description = "Ambiente logico (homolog | prod)"
  type        = string

  validation {
    condition     = contains(["homolog", "prod"], var.environment)
    error_message = "environment deve ser homolog ou prod."
  }
}

variable "aws_region" {
  description = "Regiao AWS"
  type        = string
  default     = "us-east-1"
}

variable "engine_version" {
  description = "Versao do PostgreSQL"
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "Classe da instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento inicial (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Teto do autoscaling de armazenamento (GB)"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Instancia standby em outra AZ (alta disponibilidade)"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Retencao dos backups automaticos"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Bloqueia exclusao acidental da instancia via API/console"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Habilita o Performance Insights"
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "E-mail para notificacao dos alarmes (vazio desativa o topico SNS)"
  type        = string
  default     = ""
}

variable "max_connections_alarm" {
  description = "Numero maximo de conexoes simultaneas suportado pela instance_class escolhida, usado como base do alarme de DatabaseConnections"
  type        = number
  default     = 100
}
