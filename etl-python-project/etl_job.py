
import os
from datetime import datetime, timezone
from uuid import uuid4

import boto3
import pandas as pd

DEFAULT_REGION = os.getenv("AWS_DEFAULT_REGION", "us-east-1")
DEFAULT_ENDPOINT = os.getenv("AWS_ENDPOINT_URL", "http://localhost:4566")
DEFAULT_BUCKET = os.getenv("S3_BUCKET", "etl-output-bucket")
DEFAULT_TABLE = os.getenv("DYNAMODB_TABLE", "etl-job-metadata")
DEFAULT_ROLE_ARN = os.getenv(
    "ETL_ROLE_ARN",
    "arn:aws:iam::000000000000:role/etl-lambda-role",
)


def run_etl(
    input_path: str = "data/input.csv",
    output_path: str = "data/output.csv",
    bucket: str = DEFAULT_BUCKET,
    table_name: str = DEFAULT_TABLE,
    endpoint_url: str = DEFAULT_ENDPOINT,
    region_name: str = DEFAULT_REGION,
    role_arn: str = DEFAULT_ROLE_ARN,
):
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df = pd.read_csv(input_path)

    print("Transforming data...")
    df.columns = [column.strip().lower().replace(" ", "_") for column in df.columns]
    if "amount" in df.columns:
        df["amount"] = pd.to_numeric(df["amount"], errors="coerce").fillna(0)
    df["processed"] = True
    df["processed_at"] = datetime.now(timezone.utc).isoformat()

    df.to_csv(output_path, index=False)

    session = boto3.session.Session()
    s3_client = session.client(
        "s3",
        endpoint_url=endpoint_url,
        region_name=region_name,
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID", "test"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY", "test"),
    )
    dynamodb = session.resource(
        "dynamodb",
        endpoint_url=endpoint_url,
        region_name=region_name,
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID", "test"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY", "test"),
    )

    object_key = f"processed/{os.path.basename(output_path)}"
    with open(output_path, "rb") as file_pointer:
        s3_client.upload_fileobj(file_pointer, bucket, object_key)

    metadata_table = dynamodb.Table(table_name)
    job_id = str(uuid4())
    metadata_table.put_item(
        Item={
            "job_id": job_id,
            "processed_at": datetime.now(timezone.utc).isoformat(),
            "row_count": len(df),
            "s3_bucket": bucket,
            "s3_key": object_key,
            "assumed_role_arn": role_arn,
        }
    )

    print(
        f"ETL complete. Uploaded {len(df)} rows to s3://{bucket}/{object_key} "
        f"and inserted metadata in {table_name} with job_id={job_id}."
    )

    return {
        "job_id": job_id,
        "row_count": len(df),
        "s3_bucket": bucket,
        "s3_key": object_key,
        "table_name": table_name,
        "role_arn": role_arn,
    }


if __name__ == "__main__":
    run_etl()
