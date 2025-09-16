# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "innovatemart-db-subnet-group"
  subnet_ids = [aws_subnet.public1.id, aws_subnet.public2.id]

  tags = {
    Name = "InnovateMart DB subnet group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "innovatemart-rds-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "innovatemart-rds-sg"
  }
}

# RDS MySQL for Catalog Service
resource "aws_db_instance" "catalog_mysql" {
  identifier     = "innovatemart-catalog-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type     = "gp2"
  
  db_name  = "catalog"
  username = "catalog"
  password = random_password.mysql_password.result
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  skip_final_snapshot = true
  
  tags = {
    Name = "innovatemart-catalog-mysql"
  }
}

# RDS PostgreSQL for Orders Service
resource "aws_db_instance" "orders_postgresql" {
  identifier     = "innovatemart-orders-postgres"
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type     = "gp2"
  
  db_name  = "orders"
  username = "orders"
  password = random_password.postgres_password.result
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  skip_final_snapshot = true
  
  tags = {
    Name = "innovatemart-orders-postgres"
  }
}

# DynamoDB Table for Carts Service
resource "aws_dynamodb_table" "carts" {
  name           = "innovatemart-carts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "innovatemart-carts"
  }
}

# Random passwords for databases
resource "random_password" "mysql_password" {
  length  = 16
  special = true
}

resource "random_password" "postgres_password" {
  length  = 16
  special = true
}

# Outputs for database connection info
output "catalog_mysql_endpoint" {
  value = aws_db_instance.catalog_mysql.endpoint
}

output "orders_postgresql_endpoint" {
  value = aws_db_instance.orders_postgresql.endpoint
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.carts.name
}
