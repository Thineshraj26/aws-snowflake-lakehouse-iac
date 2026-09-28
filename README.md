# Automated Cloud Data Lakehouse on AWS & Snowflake

An end-to-end, production-grade cloud data lakehouse architecture automating event-driven ingestion, Medallion modeling, and real-time BI analytics.

## Architecture Overview

```text
[Synthetic Ingestion Engine]
        │ (Parquet)
        ▼
   [AWS S3] ──(S3 Event / SQS)──► [Snowpipe (Auto-Ingest)]
                                           │
                                           ▼
                                 [Snowflake: Bronze]
                                           │
                                 [dbt Core Orchestration]
                                 ├── Silver (Deduplication & Star Schema)
                                 └── Gold (Aggregated Business Marts)
                                           │
                                           ▼
                              [Power BI (DirectQuery Live BI)]