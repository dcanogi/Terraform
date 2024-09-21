variable "postgres_version" {
  description = "La versión de Postgres que se utilizará"
  type        = string
  default     = "latest"
}

variable "postgres_user" {
  description = "Nombre de usuario de Postgres"
  type        = string
  default     = "user"
}

variable "postgres_password" {
  description = "Contraseña del usuario de Postgres"
  type        = string
  default     = "pass"
}

variable "postgres_db" {
  description = "Nombre de la base de datos en Postgres"
  type        = string
  default     = "outline"
}

variable "outline_version" {
  description = "La versión de Outline Wiki que se utilizará"
  type        = string
  default     = "latest"
}

variable "aws_s3_bucket_name" {
  description = "Nombre del bucket de AWS S3 para las cargas de Outline"
  type        = string
}

variable "http_ip" {
  description = "Dirección IP de escucha para Nginx"
  type        = string
  default     = "0.0.0.0"
}

variable "http_port" {
  description = "Puerto en el que Nginx escucha"
  type        = number
  default     = 80
}

variable "network_name" {
  description = "Nombre de la red Docker que se utilizará"
  type        = string
  default     = "outlinewiki"
}
