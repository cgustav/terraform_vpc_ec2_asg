# modules/rds/main.tf

resource "aws_db_instance" "this" {
  identifier           = "instance-${var.db_name}"
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = true

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name

  lifecycle {
    ignore_changes = [password]
  }

  #   provisioner "remote-exec" {
  #     # when = "create"
  #     # command = <<EOT
  #     #     echo "${var.init_script}" | mysql -u ${var.username} -p${var.password}
  #     # EOT

  #     inline = [
  #       "echo '${var.init_script}' | mysql -u ${var.username} -p${var.password}"
  #     ]
  #   }

  #   provisioner "local-exec" {
  #     when    = create
  #     command = <<EOT
  #       echo "${var.init_script}" | mysql -u ${var.username} -p${var.password}
  #     EOT

  #     # environment = {
  #     #   DB_ARN     = aws_rds_cluster.cluster.arn
  #     #   DB_NAME    = aws_rds_cluster.cluster.database_name
  #     #   SECRET_ARN = aws_secretsmanager_secret.db-pass.arn
  #     # }

  #     interpreter = ["bash", "-c"]
  #   }

  tags = var.tags
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = "rds-${var.db_name}-parameter-group"
  family = "${var.engine}${var.engine_version}"

  description = "RDS ${var.db_name} parameter group"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "innodb_buffer_pool_size"
    value = var.buffer_pool_size
  }

}

