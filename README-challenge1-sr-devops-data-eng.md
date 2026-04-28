# DevOps Sandbox - Completed Challenge Implementation

This repository now contains a complete local DevOps/Data Engineering sandbox implementation covering:

- CI/CD with Jenkins (`Jenkinsfile`)
- Infrastructure as Code with Terraform (`terraform-infra/`)
- IAM role/policy design in LocalStack (`IAM_NOTES.md`)
- ETL application logic in Python with LocalStack integration (`etl-python-project/etl_job.py`)
- Observability stack with Prometheus + Grafana (`docker-compose.yml`, `observability/`)
- Submission-ready deliverable summary (`FINAL_DELIVERABLE.md`)

## Architecture at a Glance

- `docker-compose.yml` starts:
  - LocalStack (S3, DynamoDB, IAM, Lambda, etc.)
  - Jenkins
  - Gitea
  - PostgreSQL
  - Prometheus
  - Grafana 
- `terraform-infra/` provisions:
  - S3 bucket (`etl-output-bucket`)
  - DynamoDB table (`etl-job-metadata`)
  - IAM role + policy for ETL/Lambda path
  - Lambda function with role attachment
  - Docker container via `terraform-provider-docker`
- `etl-python-project/etl_job.py`:
  - Reads CSV input
  - Transforms data
  - Writes output CSV
  - Uploads output to LocalStack S3
  - Writes ETL metadata to LocalStack DynamoDB

## Quick Start

1. Start platform services:

```bash
docker compose up -d
```

2. Provision infrastructure:

```bash
cd terraform-infra
terraform init
terraform apply -auto-approve
```

3. Run ETL locally:

```bash
cd ../etl-python-project
python -m pip install poetry
poetry install
poetry run pytest -q
poetry run python etl_job.py
```

4. (Optional) Trigger Jenkins pipeline:
   - Open Jenkins at `http://localhost:8080`
   - Configure a pipeline job from this repo using `Jenkinsfile`
   - Run through manual deployment approval stage

## Evidence and Submission

Use `FINAL_DELIVERABLE.md` as your final submission narrative and checklist.
Use `IAM_NOTES.md` for IAM least-privilege justification.
Use `OBSERVABILITY_NOTES.md` for observability setup and screenshot guidance.
