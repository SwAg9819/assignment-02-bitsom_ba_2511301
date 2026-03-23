# Part 6 — Capstone: Design Justification

---

## Storage Systems

The architecture uses five storage systems, each chosen for a specific goal.

**Data Lake (S3 / HDFS) — Goals 1 & 2:** The machine learning model for readmission prediction (Goal 1) requires raw, unprocessed historical EHR data — diagnoses, medications, lab results, discharge summaries — in its original form. Pre-aggregated warehouse tables would destroy the feature-level signal that tree-based models like XGBoost depend on. The Data Lake stores raw files (Parquet, JSON, PDFs) cheaply at scale. The same raw clinical notes feed the RAG pipeline for natural language patient history search (Goal 2), where unstructured text must be embedded into vectors.

**Vector Database (Pinecone / Chroma) — Goal 2:** Clinical notes are unstructured text. When a doctor asks "Has this patient had a cardiac event before?", a SQL query cannot answer this — it requires semantic search. Patient history records are embedded using a medical-domain language model and stored in the vector DB. The query is embedded at runtime, and the top-K most semantically similar records are retrieved and passed to an LLM for a grounded answer.

**Data Warehouse (Snowflake / Redshift) — Goal 3:** Monthly management reports (bed occupancy, department-wise costs, revenue) are structured, aggregated, and time-bound — the exact workload a columnar data warehouse is optimized for. A star schema (`fact_admissions`, `dim_date`, `dim_department`, `dim_patient`) enables fast OLAP queries with sub-second response times for BI dashboards.

**Time-Series Database (InfluxDB / TimescaleDB) — Goal 4:** ICU vitals (heart rate, SpO₂, blood pressure) arrive as high-frequency streams from monitoring devices via Kafka. A relational database would struggle with the write throughput and time-windowed aggregations (e.g., "average heart rate over the last 5 minutes") that time-series databases handle natively with built-in retention policies and downsampling.

**OLTP Database (PostgreSQL) — Transactional Operations:** Hospital day-to-day operations — admissions, appointment scheduling, bed assignment, prescriptions — require ACID-compliant transactional integrity. PostgreSQL provides the consistency and foreign-key enforcement that these workflows demand.

---

## OLTP vs OLAP Boundary

The transactional system ends at the **ETL pipeline boundary**. PostgreSQL handles all live, write-heavy hospital operations in real time — admissions, discharges, prescriptions, billing. These operations require row-level locking, referential integrity, and immediate consistency.

The analytical system begins when the nightly ETL pipeline (Apache Spark orchestrated by Airflow) extracts data from PostgreSQL and transforms it into the denormalized star schema in the Data Warehouse. This separation is deliberate: running analytical queries (e.g., "total cost by department across 2 years") directly on the OLTP database would lock rows, degrade transactional performance, and risk affecting live patient care operations.

The ICU real-time stream (Kafka → InfluxDB) operates on a separate boundary — it is neither OLTP nor OLAP but a streaming analytics layer with its own alerting logic independent of both.

---

## Trade-offs

**Trade-off: Complexity of a Five-System Architecture**

The most significant trade-off in this design is operational complexity. Running five distinct storage systems (PostgreSQL, Data Warehouse, Data Lake, Vector DB, Time-Series DB) means five sets of infrastructure to provision, monitor, secure, and maintain. A small hospital IT team may lack the expertise to operate all of these simultaneously, and the failure of any one system affects a specific goal.

**Mitigation:** The primary mitigation is using managed cloud services wherever possible — Amazon RDS (PostgreSQL), Snowflake (Data Warehouse), Pinecone (Vector DB), and InfluxDB Cloud (Time-Series) all eliminate infrastructure management entirely. The team manages configuration and data pipelines, not servers. A secondary mitigation is phased rollout: deploy the OLTP + Data Warehouse layer first (Goals 3 and 4), then add the ML pipeline (Goal 1), and finally the Vector DB + RAG system (Goal 2). This spreads complexity over time and allows the team to build operational familiarity incrementally rather than launching all five systems simultaneously.
