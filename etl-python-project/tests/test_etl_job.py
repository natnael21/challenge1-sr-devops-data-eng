import pandas as pd

from etl_job import run_etl


class FakeS3Client:
    def __init__(self):
        self.uploads = []

    def upload_fileobj(self, file_pointer, bucket, key):
        self.uploads.append((bucket, key, file_pointer.read()))


class FakeTable:
    def __init__(self):
        self.items = []

    def put_item(self, Item):
        self.items.append(Item)


class FakeDynamoResource:
    def __init__(self, table):
        self.table = table

    def Table(self, _name):
        return self.table


class FakeSession:
    def __init__(self, s3_client, ddb_resource):
        self._s3 = s3_client
        self._ddb = ddb_resource

    def client(self, *_args, **_kwargs):
        return self._s3

    def resource(self, *_args, **_kwargs):
        return self._ddb


def test_run_etl_writes_output_and_remote_targets(monkeypatch, tmp_path):
    input_path = tmp_path / "input.csv"
    output_path = tmp_path / "output.csv"
    input_path.write_text("customer_id,amount\n1,10\n2,15\n", encoding="utf-8")

    s3_client = FakeS3Client()
    fake_table = FakeTable()
    ddb_resource = FakeDynamoResource(fake_table)

    monkeypatch.setattr(
        "boto3.session.Session",
        lambda: FakeSession(s3_client, ddb_resource),
    )

    result = run_etl(
        input_path=str(input_path),
        output_path=str(output_path),
        bucket="etl-output-bucket",
        table_name="etl-job-metadata",
        endpoint_url="http://localhost:4566",
    )

    output_df = pd.read_csv(output_path)
    assert "processed" in output_df.columns
    assert output_df["processed"].all()
    assert len(s3_client.uploads) == 1
    assert len(fake_table.items) == 1
    assert result["row_count"] == 2
