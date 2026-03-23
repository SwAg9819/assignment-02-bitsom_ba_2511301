# Part 2 — NoSQL: RDBMS vs NoSQL

---

## Database Recommendation

**Scenario:** A healthcare startup is building a patient management system. One engineer recommends MySQL; another recommends MongoDB. Given ACID vs BASE and the CAP theorem, which would you recommend? Would the answer change if they also needed a fraud detection module?

---

For a patient management system, I would recommend **MySQL** (or any ACID-compliant relational database such as PostgreSQL) as the primary data store, and my reasoning is grounded directly in the properties of healthcare data.

Healthcare data is among the most integrity-critical data that exists. A patient's allergy record, prescription history, or lab result must be **exactly correct** — a partial write, a stale read, or a phantom record could result in a wrong drug being administered. MySQL's ACID guarantees — Atomicity, Consistency, Isolation, Durability — directly address this. When a doctor updates a prescription and simultaneously a pharmacist reads it, MySQL's isolation levels ensure the pharmacist either sees the old committed state or the new one — never a half-written intermediate state. MongoDB's BASE model (Basically Available, Soft-state, Eventually Consistent) explicitly trades consistency for availability, which is an unacceptable trade-off when a read of a stale record could harm a patient.

From the CAP theorem perspective, healthcare applications must prioritize **Consistency over Availability**. If the system goes briefly offline during a network partition, that is tolerable. Returning inconsistent medication data is not. MySQL is a CP system; MongoDB in its default configuration leans toward AP.

Additionally, patient data has **highly structured, well-defined relationships** — patients, diagnoses, prescriptions, doctors, appointments — that map naturally to relational tables with enforced foreign keys. There is no schema-flexibility advantage to using MongoDB here.

**If a fraud detection module is added**, the answer shifts. Fraud detection involves real-time analysis of behavioral patterns across millions of transactions, requiring fast writes, flexible event schemas, and time-series-style queries. Here, a secondary **MongoDB instance or a purpose-built time-series/streaming store** (such as Apache Kafka + Cassandra) would complement MySQL. The core patient records remain in MySQL for consistency; the fraud signals feed into a separate NoSQL layer optimized for high-throughput reads and writes. This hybrid architecture gives the startup the best of both models without compromising patient data integrity.
