# ETL Python Project

This ETL job transforms CSV data and writes results to LocalStack-backed AWS services.

## What it does

- Reads `data/input.csv`
- Normalizes/enriches columns (`processed`, `processed_at`)
- Writes transformed CSV to `data/output.csv`
- Uploads output to S3 bucket (`etl-output-bucket`)
- Writes ETL metadata to DynamoDB table (`etl-job-metadata`)

## Run locally

```bash
python -m pip install poetry
poetry install
poetry run pytest -q
poetry run python etl_job.py
```

## Required environment (defaults provided)

- `AWS_ENDPOINT_URL` (default: `http://localhost:4566`)
- `AWS_DEFAULT_REGION` (default: `us-east-1`)
- `AWS_ACCESS_KEY_ID` (default: `test`)
- `AWS_SECRET_ACCESS_KEY` (default: `test`)
- `S3_BUCKET` (default: `etl-output-bucket`)
- `DYNAMODB_TABLE` (default: `etl-job-metadata`)
- `ETL_ROLE_ARN` (default: `arn:aws:iam::000000000000:role/etl-lambda-role`)