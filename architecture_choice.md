# Part 5 — Data Lake: Architecture Choice

---

## Architecture Recommendation

**Scenario:** A fast-growing food delivery startup collects GPS location logs, customer text reviews, payment transactions, and restaurant menu images. Which storage architecture would you recommend — Data Warehouse, Data Lake, or Data Lakehouse?

---

I recommend a **Data Lakehouse** architecture for this startup, and the recommendation is driven by the specific combination of data types they collect and the analytical needs that follow from them.

**Reason 1 — Heterogeneous data types that cannot fit in a warehouse alone.**
A traditional Data Warehouse (e.g., Snowflake, Redshift) is built for structured, tabular data. Payment transactions fit naturally into a warehouse. But GPS location logs are semi-structured time-series data, customer text reviews are unstructured free text, and restaurant menu images are binary blobs. A warehouse cannot store or query any of these natively. A pure Data Lake (e.g., S3 + Hadoop) can store all formats but offers no structured query layer, making BI reporting on transactions slow and difficult. The Data Lakehouse — architectures like Delta Lake, Apache Iceberg, or Databricks — stores all formats in a unified object storage layer (S3/GCS) while adding a structured ACID transaction layer on top. This means payment data can be queried with SQL joins, while images and logs live in the same storage tier.

**Reason 2 — ML workloads require raw data.**
The startup will inevitably build ML models — delivery time prediction (GPS logs), sentiment analysis (text reviews), menu item recognition (images). These models need raw, unprocessed data in its original form. A warehouse pre-aggregates and transforms data, destroying the raw signal. A Lakehouse preserves raw data while still supporting the cleaned, aggregated views that business dashboards need.

**Reason 3 — Cost efficiency at startup scale.**
Object storage (S3/GCS) costs a fraction of managed warehouse compute storage. A Lakehouse lets the startup store petabytes of GPS pings and images cheaply in object storage, and only pay for compute when running queries. A full warehouse would require expensive columnar storage for data that may only be queried occasionally.

In summary, the Data Lakehouse is the only architecture that supports structured SQL analytics, unstructured ML workloads, and cost-efficient multi-format storage simultaneously — exactly what this startup's data portfolio demands.
