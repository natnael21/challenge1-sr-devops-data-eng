# IAM Notes

## Objective

Implement least-privilege IAM controls in LocalStack and demonstrate role usage from ETL logic.

## Implemented IAM Design

- Role: `etl-lambda-role`
- Policy: `etl-data-policy`
- Policy attachment: role attached using `aws_iam_role_policy_attachment`
- Simulated workload: `aws_lambda_function.etl_lambda` uses `etl-lambda-role`

## Least-Privilege Choices

The attached policy allows only:

- `s3:PutObject`, `s3:GetObject`, `s3:ListBucket` on:
  - `etl-output-bucket`
  - `etl-output-bucket/*`
- `dynamodb:PutItem`, `dynamodb:GetItem`, `dynamodb:Scan` on:
  - `etl-job-metadata` table ARN

This avoids wildcard permissions such as `s3:*`, `dynamodb:*`, or unrestricted `*` resource scope.

## Application-Level Demonstration

The ETL job reads role identity from environment variable:

- `ETL_ROLE_ARN` (default: LocalStack role ARN)

and stores it in DynamoDB metadata (`assumed_role_arn`) during ETL execution, showing explicit linkage between workload and IAM role context.

## Files

- `terraform-infra/main.tf` (IAM role/policy/attachment + Lambda association)
- `etl-python-project/etl_job.py` (role ARN capture in ETL metadata)
