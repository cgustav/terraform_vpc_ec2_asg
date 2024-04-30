variable "bucket_name" {
  description = "Nombre del bucket de S3"
  type        = string
}

variable "environment" {
  description = "El entorno para el que se está creando el recurso"
  type        = string
}

variable "paths_to_static_files" {
  description = "Lista de paths locales a los directorios con archivos estáticos para cargar en S3"
  type        = list(string)
}

variable "ec2_role_arn" {
  description = "ARN del rol de IAM para las instancias EC2 que accederán al bucket"
  type        = string
}

