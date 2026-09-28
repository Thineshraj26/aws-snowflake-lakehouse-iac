# Dedicated compute warehouse for analytics workloads
resource "snowflake_warehouse" "lakehouse_wh" {
  name           = "LAKEHOUSE_WH"
  warehouse_size = "xsmall"
  auto_suspend   = 60
  auto_resume    = true
  initially_suspended = true
  comment        = "Compute warehouse for Cloud Lakehouse ELT"
}

# Database for the lakehouse
resource "snowflake_database" "lakehouse_db" {
  name    = "LAKEHOUSE_DB"
  comment = "Analytical lakehouse database managed by Terraform"
}

# Medallion schemas
resource "snowflake_schema" "bronze_schema" {
  database = snowflake_database.lakehouse_db.name
  name     = "BRONZE"
  comment  = "Raw landing views and external tables"
}

resource "snowflake_schema" "silver_schema" {
  database = snowflake_database.lakehouse_db.name
  name     = "SILVER"
  comment  = "Cleansed and transformed intermediate tables"
}

resource "snowflake_schema" "gold_schema" {
  database = snowflake_database.lakehouse_db.name
  name     = "GOLD"
  comment  = "Analytical marts and dimensional star schemas"
}

# Storage Integration that allows Snowflake to read from S3 securely
resource "snowflake_storage_integration" "s3_integration" {
  name                      = "S3_LAKEHOUSE_INTEGRATION"
  comment                   = "Secure connection to AWS S3 lakehouse bucket"
  type                      = "EXTERNAL_STAGE"
  enabled                   = true
  storage_provider          = "S3"
  storage_allowed_locations = ["s3://${aws_s3_bucket.lakehouse_bucket.id}/raw/"]
  storage_aws_role_arn      = aws_iam_role.snowflake_role.arn
}

output "storage_integration_name" {
  value = snowflake_storage_integration.s3_integration.name
}