resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "lakehouse_bucket" {
  bucket        = "${var.bucket_prefix}-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Environment = "Dev"
    Project     = "Cloud-Lakehouse"
  }
}

# Block public access entirely for zero-trust security
resource "aws_s3_bucket_public_access_block" "lakehouse_bucket_block" {
  bucket = aws_s3_bucket.lakehouse_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bronze landing folder
resource "aws_s3_object" "bronze_folder" {
  bucket = aws_s3_bucket.lakehouse_bucket.id
  key    = "raw/"
}

# Curated output folder
resource "aws_s3_object" "curated_folder" {
  bucket = aws_s3_bucket.lakehouse_bucket.id
  key    = "curated/"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.lakehouse_bucket.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.lakehouse_bucket.arn
}

# IAM Role for Snowflake to assume
resource "aws_iam_role" "snowflake_role" {
  name = "snowflake_s3_lakehouse_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::640083578061:user/externalstages/ciyo6d0000"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "LZ19380_SFCRole=4_B7UPc0W2n5y0wW00dWLmCmrEkPg="
          }
        }
      }
    ]
  })
}

# Policy allowing read access to S3 raw directory
resource "aws_iam_role_policy" "snowflake_s3_policy" {
  name = "snowflake_s3_access_policy"
  role = aws_iam_role.snowflake_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.lakehouse_bucket.arn,
          "${aws_s3_bucket.lakehouse_bucket.arn}/*"
        ]
      }
    ]
  })
}

output "snowflake_iam_role_arn" {
  value = aws_iam_role.snowflake_role.arn
}

# S3 Event Notification for Snowpipe Auto-Ingest
resource "aws_s3_bucket_notification" "snowpipe_notification" {
  bucket = aws_s3_bucket.lakehouse_bucket.id

  queue {
    queue_arn     = "arn:aws:sqs:us-east-1:640083578061:sf-snowpipe-AIDAZKB7UJTG53HB2FGG4-gmtozJVHPbxDlXStCBnQjw"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "raw/"
    filter_suffix = ".parquet"
  }

  depends_on = [aws_s3_object.bronze_folder]
}