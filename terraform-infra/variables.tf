variable "aws_region" {
  description = "AWS region used for LocalStack simulation."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "Endpoint URL for LocalStack services."
  type        = string
  default     = "http://localhost:4566"
}

variable "s3_bucket_name" {
  description = "Bucket name for ETL output files."
  type        = string
  default     = "etl-output-bucket"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for ETL metadata."
  type        = string
  default     = "etl-job-metadata"
}
