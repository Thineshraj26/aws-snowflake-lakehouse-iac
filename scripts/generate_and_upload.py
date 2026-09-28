import io
import random
import uuid
from datetime import datetime, timezone
import boto3
from botocore.exceptions import ClientError
from faker import Faker
import pandas as pd

# Target S3 configuration
BUCKET_NAME = "lakehouse-data-store-abcf6f25"
PREFIX = "raw/transactions"

fake = Faker()


def generate_orders(num_records: int = 1000) -> pd.DataFrame:
  """Generates realistic transactional e-commerce order records."""
  categories = [
      "Electronics",
      "Home & Kitchen",
      "Industrial Equipment",
      "Apparel",
      "Automotive",
  ]
  payment_methods = ["Credit Card", "Wire Transfer", "E-Wallet", "Invoice"]
  order_statuses = ["COMPLETED", "PROCESSING", "SHIPPED", "RETURNED"]

  records = []
  for _ in range(num_records):
    unit_price = round(random.uniform(5.0, 750.0), 2)
    quantity = random.randint(1, 12)
    total_amount = round(unit_price * quantity, 2)

    record = {
        "order_id": str(uuid.uuid4()),
        "customer_id": f"CUST_{random.randint(1000, 9999)}",
        "customer_name": fake.name(),
        "customer_email": fake.email(),
        "customer_country": fake.country_code(),
        "category": random.choice(categories),
        "quantity": quantity,
        "unit_price": unit_price,
        "total_amount": total_amount,
        "payment_method": random.choice(payment_methods),
        "order_status": random.choice(order_statuses),
        "created_at": fake.date_time_between(
            start_date="-30d", end_date="now", tzinfo=timezone.utc
        ).isoformat(),
        "ingested_at": datetime.now(timezone.utc).isoformat(),
    }
    records.append(record)

  df = pd.DataFrame(records)
  # Enforce explicit dtypes for clean parquet schema definitions
  df["quantity"] = df["quantity"].astype("int32")
  df["unit_price"] = df["unit_price"].astype("float64")
  df["total_amount"] = df["total_amount"].astype("float64")
  return df


def upload_df_to_s3_as_parquet(
    df: pd.DataFrame, bucket: str, key: str
) -> None:
  """Serialises DataFrame to in-memory Parquet and streams directly to S3."""
  s3_client = boto3.client("s3")

  # Use in-memory buffer to avoid creating unnecessary temporary files on disk
  parquet_buffer = io.BytesIO()
  df.to_parquet(parquet_buffer, engine="pyarrow", compression="snappy", index=False)
  parquet_buffer.seek(0)

  print(f"Uploading {len(df)} rows to s3://{bucket}/{key} ...")
  try:
    s3_client.put_object(
        Bucket=bucket, Key=key, Body=parquet_buffer.getvalue()
    )
    print("Upload successful.")
  except ClientError as err:
    print(f"Failed to upload: {err}")
    raise


if __name__ == "__main__":
  # Timestamped filename partition
  current_ts = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
  s3_object_key = f"{PREFIX}/orders_{current_ts}.parquet"

  orders_df = generate_orders(num_records=5000)
  upload_df_to_s3_as_parquet(orders_df, BUCKET_NAME, s3_object_key)