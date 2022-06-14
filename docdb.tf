resource "aws_db_instance" "main" {
  allocated_storage = 10
  engine            = "postgres"
  engine_version    = "13.4"
  instance_class    = "db.t3.micro"
  db_name           = "db_instance"
  username          = "dbuser"
  # todo autogenerate password and store it in key vault or something
  password             = "passpasspass"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_docdb_subnet_group.main.name
}
resource "aws_docdb_subnet_group" "main" {
  name       = var.project
  subnet_ids = [for subnet in aws_subnet.main : subnet.id]
}
resource "aws_docdb_cluster" "main" {
  cluster_identifier              = var.project
  engine                          = "docdb"
  master_username                 = "dbuser"
  master_password                 = "passpasspass"
  backup_retention_period         = 5
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
}
resource "aws_docdb_cluster_instance" "main" {
  identifier         = var.project
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = "db.t3.medium"
}
resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb4.0"
  name        = var.project
  description = "docdb cluster parameter group"

  parameter {
    name         = "tls"
    value        = "disabled"
    apply_method = "pending-reboot"
  }
}