# Part 3 — Data Warehouse: ETL Notes

---

## ETL Decisions

### Decision 1 — Date Format Standardization

**Problem:** The `date` column in `retail_transactions.csv` contains three different date formats across 300 rows: `DD/MM/YYYY` (e.g., `29/08/2023`), `DD-MM-YYYY` (e.g., `12-12-2023`), and `YYYY-MM-DD` (e.g., `2023-02-05`). SQL `DATE` columns require a single consistent format, and mixing formats causes incorrect or failed inserts. Attempting to parse `29/08/2023` as ISO format would yield an invalid date.

**Resolution:** During the ETL transformation step, all date strings were parsed using a format-detection loop that tries each of the three patterns in sequence and converts every value to the ISO standard `YYYY-MM-DD` format before loading into `dim_date` and `fact_sales`. This ensures all date arithmetic (month-over-month trends, quarterly rollups) works correctly and consistently across the warehouse.

---

### Decision 2 — NULL Store City Imputation

**Problem:** The `store_city` column contains 19 NULL values. These rows cannot be loaded into `dim_store` or `fact_sales` as-is because `store_city` is a NOT NULL dimension attribute, and NULLs would break aggregations grouped by city (e.g., Q2 — top stores by revenue).

**Resolution:** Since `store_name` is always populated and each store name maps deterministically to a single city (e.g., `Mumbai Central` → `Mumbai`, `Delhi South` → `Delhi`), the missing city values were imputed by building a `store_name → store_city` lookup from the non-null rows. The five store-to-city mappings are: Chennai Anna → Chennai, Delhi South → Delhi, Bangalore MG → Bangalore, Pune FC Road → Pune, Mumbai Central → Mumbai. All 19 NULL cities were filled using this mapping before loading.

---

### Decision 3 — Category Casing and Value Standardization

**Problem:** The `category` column contains five distinct string values for what should be only three categories: `'electronics'`, `'Electronics'`, `'Grocery'`, `'Clothing'`, and `'Groceries'`. Two problems exist simultaneously — inconsistent casing (`electronics` vs `Electronics`) and inconsistent naming (`Groceries` vs `Grocery`). If loaded as-is, `GROUP BY category` queries would return five groups instead of three, splitting revenue and unit counts incorrectly.

**Resolution:** A two-step normalization was applied. First, all values were title-cased (`.str.capitalize()`) to unify `electronics` → `Electronics`. Second, `Groceries` was explicitly remapped to `Grocery` to enforce a single canonical label. The final standardized categories loaded into `dim_product` are: `Electronics`, `Grocery`, and `Clothing`. This ensures all category-level analytics in `dw_queries.sql` produce correct three-way groupings.
