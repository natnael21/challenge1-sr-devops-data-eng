# Final Deliverable - DevOps Sandbox Data Engineering Challenge

## Candidate Summary

This submission delivers a complete local DevOps and Data Engineering workflow:

- Jenkins CI/CD pipeline with build, test, and manual deployment approval.
- Terraform Infrastructure as Code for LocalStack AWS resources and a Docker-managed container.
- IAM role/policy implementation with least-privilege controls and workload attachment.
- Python ETL flow that transforms CSV input, uploads to S3, and records metadata in DynamoDB.
- Observability stack using Prometheus and Grafana.

## What Was Implemented

### 1) CI/CD Pipeline

- File: `Jenkinsfile`
- Stages:
  - `Checkout`
  - `Install` (`poetry install`)
  - `Test` (`pytest`)
  - `Build` (`poetry build` + ETL execution)
  - `Deploy` (manual approval gate with `input`)

### 2) Infrastructure as Code

- Folder: `terraform-infra/`
- Providers:
  - `hashicorp/aws` (LocalStack endpoints)
  - `kreuzwerker/docker`
  - `hashicorp/archive`
  - `hashicorp/local`
- Provisioned resources:
  - S3 bucket: `etl-output-bucket`
  - DynamoDB table: `etl-job-metadata`
  - IAM role + policy + attachment
  - Lambda function attached to IAM role
  - Docker container (`terraform-http-echo`)

### 3) IAM and Access Controls

- Role: `etl-lambda-role`
- Policy: `etl-data-policy`
- Allowed actions restricted to required S3 and DynamoDB operations.
- ETL records role ARN in metadata to demonstrate role context usage.

See full rationale in `IAM_NOTES.md`.

### 4) Application Logic

- File: `etl-python-project/etl_job.py`
- Behavior:
  - Load `data/input.csv`
  - Standardize columns and enrich with processing metadata
  - Persist transformed output to `data/output.csv`
  - Upload output to S3 (`processed/output.csv`)
  - Insert run metadata in DynamoDB (`job_id`, row count, S3 location, role ARN)

### 5) Observability

- Added Prometheus + Grafana to compose stack.
- Prometheus scrape config in `observability/prometheus/prometheus.yml`.

See setup notes in `OBSERVABILITY_NOTES.md`.

## How to Run

## Prerequisites

- Docker + Docker Compose
- Terraform >= 1.5
- Python 3.10+
- Poetry

### A. Start Sandbox Platform

```bash
docker compose up -d
```

### B. Provision Infra

```bash
cd terraform-infra
terraform init
terraform apply -auto-approve
```

### C. Run ETL

```bash
cd ../etl-python-project
python -m pip install poetry
poetry install
poetry run pytest -q
poetry run python etl_job.py
```

### D. Validate Outputs

```bash
aws --endpoint-url=http://localhost:4566 s3 ls s3://etl-output-bucket/processed/
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name etl-job-metadata
```

## Screenshot Checklist

- [ ] Docker services running (`docker compose ps`)
- [ ] Terraform apply output with created resources
- [ ] Jenkins pipeline stage results (install/test/build/deploy approval)
- [ ] S3 object present in LocalStack bucket
- [ ] DynamoDB metadata record for ETL run
- [ ] Prometheus targets page
- [ ] Grafana dashboard panel with metrics

## Included Files (Key)

- `README-challenge1-sr-devops-data-eng.md`
- `Jenkinsfile`
- `docker-compose.yml`
- `terraform-infra/main.tf`
- `terraform-infra/variables.tf`
- `terraform-infra/outputs.tf`
- `etl-python-project/etl_job.py`
- `etl-python-project/tests/test_etl_job.py`
- `etl-python-project/data/input.csv`
- `IAM_NOTES.md`
- `OBSERVABILITY_NOTES.md`
- `FINAL_DELIVERABLE.md`
