output "s3_bucket_name" {
  value = aws_s3_bucket.etl_output.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.etl_metadata.name
}

output "iam_role_arn" {
  value = aws_iam_role.etl_lambda_role.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.etl_lambda.function_name
}

output "docker_container_name" {
  value = docker_container.http_echo.name
}
