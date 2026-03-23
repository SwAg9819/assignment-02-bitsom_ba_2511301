# Part 1 — RDBMS: Normalization

---

## Anomaly Analysis

The file `orders_flat.csv` is a denormalized table with 186 rows and 15 columns:
`order_id`, `customer_id`, `customer_name`, `customer_email`, `customer_city`,
`product_id`, `product_name`, `category`, `unit_price`, `quantity`, `order_date`,
`sales_rep_id`, `sales_rep_name`, `sales_rep_email`, `office_address`.

---

### Insert Anomaly

**Definition:** A new entity cannot be recorded unless an unrelated record also exists.

**Example from dataset:**

Suppose the company onboards a new sales representative — say `SR04`, *Sunita Rao* (`sunita@corp.com`), Kolkata office — but she has not closed any order yet. In `orders_flat.csv`, every row requires a valid `order_id`, `customer_id`, and `product_id`. There is no way to insert SR04's record without fabricating a fake order.

Similarly, a new product `P009 — Mechanical Keyboard (Electronics, ₹4,500)` cannot be entered into the catalogue until at least one customer orders it, because the table has no standalone product record.

**Affected columns:** `sales_rep_id`, `sales_rep_name`, `sales_rep_email`, `office_address`, `product_id`, `product_name`, `category`, `unit_price`

---

### Update Anomaly

**Definition:** The same fact is stored redundantly across many rows; updating it inconsistently corrupts the data.

**Example from dataset:**

Sales rep `SR01` (Deepak Joshi) has his `office_address` repeated in every row where he appears — over 60 rows. In the flat file, two different values exist for the same rep:

- Most rows: `Mumbai HQ, Nariman Point, Mumbai - 400021`
- Row ~37 (order ORD1003 area): `Mumbai HQ, Nariman Pt, Mumbai - 400021`

This is a real update anomaly already present in the data: an abbreviated "Nariman Pt" crept in when one subset of rows was updated. Any `GROUP BY office_address` query will now silently split SR01's records into two groups, producing incorrect aggregations.

**Affected column:** `office_address`  
**Affected rows:** All rows where `sales_rep_id = 'SR01'` (~60+ rows)

---

### Delete Anomaly

**Definition:** Deleting a set of rows causes unintended permanent loss of an unrelated entity's information.

**Example from dataset:**

Customer `C004` (Sneha Iyer, Chennai, `sneha@gmail.com`) appears in only a few rows. If all orders associated with C004 are deleted — for example, during a data archiving run — every trace of Sneha Iyer's customer profile disappears from the system. Her `customer_id`, `customer_name`, `customer_email`, and `customer_city` exist in no other table.

The same applies to product `P008` (Webcam, Electronics, ₹2,100): it appears in very few orders (e.g., ORD1185). Deleting those orders removes all record of the product from the database.

**Affected columns:** `customer_id`, `customer_name`, `customer_email`, `customer_city`  
**Affected rows:** All rows where `customer_id = 'C004'`

---

## Normalization Justification

**Prompt:** *Your manager argues that keeping everything in one table is simpler and normalization is over-engineering. Using specific examples from the dataset, defend or refute this position.*

---

The flat-table approach in `orders_flat.csv` appears simple on the surface but creates compounding problems that grow with data volume. The argument against normalization breaks down when confronted with concrete evidence from this very dataset.

The update anomaly is the most immediate problem. Sales rep Deepak Joshi's `office_address` is stored in over 60 rows. The flat file already contains two versions of his address — "Nariman Point" in most rows and "Nariman Pt" in at least one. A manager who updates his address after a relocation must touch every single one of those rows without missing a single one. In practice, they won't. The result is silent data corruption: reports grouped by office will split Deepak's records across two groups, and no error will be thrown. In a normalized schema, the address lives in exactly one row in a `sales_reps` table — update it once, it is correct everywhere instantly.

The delete anomaly is operationally dangerous. If customer C004 (Sneha Iyer, Chennai) cancels her account and her orders are purged, her entire identity — email, city, ID — vanishes. Marketing cannot re-engage her. Finance loses audit history of who she was. Normalization keeps `customers` as an independent table, so customer records outlive their transactions.

The insert anomaly paralyzes business operations. The company cannot add a new product to its catalog until someone orders it, and cannot onboard a new sales rep until they close their first deal. Both are legitimate pre-order needs that the flat schema structurally cannot support.

The "simplicity" argument confuses ease of initial setup with ease of long-term maintenance. A single table may save ten minutes of schema design today, but it creates hours of data cleaning, reconciliation, and query debugging every month. Normalization is not over-engineering — it is the minimum viable structure for data that remains trustworthy as it grows.
