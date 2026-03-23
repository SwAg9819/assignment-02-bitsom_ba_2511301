# Part 4 — Vector Databases: Reflection

---

## Vector DB Use Case

**Prompt:** A law firm wants to build a system where lawyers can search 500-page contracts by asking questions in plain English (e.g., "What are the termination clauses?"). Would a traditional keyword-based database search suffice? Justify why or why not, and explain what role a vector database would play in this system.

---

A traditional keyword-based search would not suffice for this use case, and the limitations are both fundamental and practically significant.

Keyword search works by matching exact or stemmed tokens. If a lawyer types "termination clauses," the system will retrieve paragraphs containing the words "termination" and "clauses." But legal contracts are written with great variation in phrasing. The same concept may appear as "grounds for dissolution," "right to exit," "early termination provisions," or "conditions precedent to cancellation." A keyword engine treats all of these as completely different queries. The lawyer would need to know every possible synonym in advance — defeating the purpose of a natural language interface entirely.

This is precisely the problem that vector databases solve. A system built on vector embeddings would work as follows: each paragraph or clause of each contract is passed through a sentence embedding model (such as `all-MiniLM-L6-v2` or a legal-domain model like `legal-bert`), which converts it into a high-dimensional vector that encodes its semantic meaning. These vectors are stored in a vector database such as Pinecone, Weaviate, or Chroma. When a lawyer asks "What are the termination clauses?", the query itself is embedded into the same vector space, and the database retrieves the top-K most semantically similar paragraphs using cosine similarity — regardless of whether the word "termination" appears in them.

The practical architecture would combine a vector database with a large language model (RAG — Retrieval Augmented Generation): the vector DB retrieves the most relevant contract sections, which are then passed as context to an LLM that formulates a precise, grounded answer. This gives lawyers fast, accurate, semantically-aware search across thousands of pages without requiring legal knowledge of every possible contractual phrasing.

In short: keyword search finds exact words; vector search finds meaning. For contract analysis, only meaning matters.
