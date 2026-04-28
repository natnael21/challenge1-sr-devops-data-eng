terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = var.aws_region
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = var.localstack_endpoint
    dynamodb = var.localstack_endpoint
    iam      = var.localstack_endpoint
    sts      = var.localstack_endpoint
    lambda   = var.localstack_endpoint
  }
}

provider "docker" {}

resource "aws_s3_bucket" "etl_output" {
  bucket = var.s3_bucket_name
}

resource "aws_dynamodb_table" "etl_metadata" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "job_id"

  attribute {
    name = "job_id"
    type = "S"
  }
}

resource "aws_iam_role" "etl_lambda_role" {
  name = "etl-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "etl_data_policy" {
  name = "etl-data-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.etl_output.arn,
          "${aws_s3_bucket.etl_output.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.etl_metadata.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "etl_policy_attachment" {
  role       = aws_iam_role.etl_lambda_role.name
  policy_arn = aws_iam_policy.etl_data_policy.arn
}

resource "local_file" "lambda_source" {
  filename = "${path.module}/build/lambda_function.py"
  content  = <<EOF
import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "lambda role is attached"})
    }
EOF
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = local_file.lambda_source.filename
  output_path = "${path.module}/build/lambda_function.zip"
}

resource "aws_lambda_function" "etl_lambda" {
  function_name    = "etl-sandbox-lambda"
  role             = aws_iam_role.etl_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "docker_image" "http_echo" {
  name = "hashicorp/http-echo:0.2.3"
}

resource "docker_container" "http_echo" {
  name  = "terraform-http-echo"
  image = docker_image.http_echo.image_id

  ports {
    internal = 5678
    external = 5678
  }

  command = ["-listen=:5678", "-text=terraform managed container"]
}
