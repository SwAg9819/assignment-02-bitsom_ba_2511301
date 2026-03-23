// ============================================================
// Part 2.2 — MongoDB Operations
// File: part2-nosql/mongo_queries.js
// Collection: db.products
// Run in: mongosh or MongoDB Compass Shell
// ============================================================

// OP1: insertMany() — insert all 3 documents from sample_documents.json
db.products.insertMany([
  {
    _id: "PROD_ELEC_001",
    name: "Sony WH-1000XM5 Headphones",
    category: "Electronics",
    brand: "Sony",
    price: 29999,
    currency: "INR",
    in_stock: true,
    quantity_available: 42,
    specifications: {
      battery_life_hours: 30,
      connectivity: ["Bluetooth 5.2", "3.5mm AUX"],
      noise_cancellation: true,
      voltage: "5V DC",
      frequency_response: "4Hz - 40,000Hz"
    },
    warranty: {
      duration_months: 12,
      type: "Manufacturer Warranty",
      covers: ["manufacturing defects", "hardware failure"]
    },
    ratings: { average: 4.7, total_reviews: 1284 },
    tags: ["wireless", "noise-cancelling", "premium", "audio"]
  },
  {
    _id: "PROD_CLOTH_001",
    name: "Men's Slim Fit Chinos",
    category: "Clothing",
    brand: "Roadster",
    price: 1299,
    currency: "INR",
    in_stock: true,
    quantity_available: 210,
    attributes: {
      fabric: "98% Cotton, 2% Spandex",
      fit: "Slim Fit",
      sizes_available: ["28", "30", "32", "34", "36", "38"],
      colors_available: ["Navy Blue", "Olive Green", "Beige", "Charcoal"],
      care_instructions: ["Machine wash cold", "Do not bleach", "Tumble dry low"],
      gender: "Men",
      occasion: ["Casual", "Semi-formal"]
    },
    ratings: { average: 4.2, total_reviews: 3891 },
    tags: ["cotton", "chinos", "slim-fit", "casual"]
  },
  {
    _id: "PROD_GROC_001",
    name: "Aashirvaad Whole Wheat Atta 10kg",
    category: "Groceries",
    brand: "Aashirvaad",
    price: 389,
    currency: "INR",
    in_stock: true,
    quantity_available: 560,
    attributes: {
      weight_kg: 10,
      form: "Powder",
      storage_instructions: "Store in a cool, dry place",
      manufactured_date: "2024-11-01",
      expiry_date: "2025-05-01",
      shelf_life_days: 180
    },
    nutritional_info: {
      serving_size_g: 30,
      calories_per_serving: 108,
      protein_g: 3.6,
      carbohydrates_g: 21.4,
      fat_g: 0.5,
      fiber_g: 2.9,
      sodium_mg: 1
    },
    certifications: ["FSSAI Approved", "ISO 22000"],
    ratings: { average: 4.5, total_reviews: 22470 },
    tags: ["atta", "whole-wheat", "staple", "10kg"]
  }
]);


// OP2: find() — retrieve all Electronics products with price > 20000
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    name: 1,
    brand: 1,
    price: 1,
    category: 1,
    _id: 0
  }
);


// OP3: find() — retrieve all Groceries expiring before 2025-01-01
// The expiry_date is stored as a string (ISO format) under attributes.expiry_date
db.products.find(
  {
    category: "Groceries",
    "attributes.expiry_date": { $lt: "2025-01-01" }
  },
  {
    name: 1,
    brand: 1,
    "attributes.expiry_date": 1,
    _id: 0
  }
);


// OP4: updateOne() — add a "discount_percent" field to a specific product
// Adding a 10% discount to the Sony Headphones product
db.products.updateOne(
  { _id: "PROD_ELEC_001" },
  {
    $set: {
      discount_percent: 10,
      discounted_price: 26999
    }
  }
);


// OP5: createIndex() — create an index on category field and explain why
// Index on "category" is the most valuable single-field index for this collection
// because nearly every query filters or groups by category (Electronics, Clothing, Groceries).
// Without this index, MongoDB performs a full collection scan (O(n)) for every category
// filter. With it, lookups are O(log n), dramatically improving performance as the
// catalog grows to millions of products.
db.products.createIndex(
  { category: 1 },
  { name: "idx_category", background: true }
);

// Verify index was created
db.products.getIndexes();
