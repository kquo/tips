## AI
AI bits.

### Run DeepSeek Locally

Use [ollama](https://github.com/ollama/ollama) for this.

Pick what DeepSeek R1 model you want to play with: 7b (4.7GB) - 14b (9G) - 32b (20GB) - 70b (43GB) - 671b (404GB)

```bash
brew install ollama                   # Install ollama
allama serve                          # Start ollama - in a diff shell window
ollama pull deepseek-r1:7b            # Pull deepseek-r1:7b
ollama run deepseek-r1:7b             # Run it
alias r1='ollama run deepseek-r1:7b'  # Setup a shell alias to prompt question
```

### Embeddings

[Embeddings](https://en.wikipedia.org/wiki/Word_embedding) are numerical vector representations of data that capture semantic or relational meaning — e.g. `"cat" → [0.12, -0.83, 0.45, ...]`, a list of a few hundred to a few thousand floats. They're widely used for tasks involving similarity, ranking, or grouping.

#### Common Patterns

The most common use is semantic search / retrieval: embed a corpus and a query, then do a nearest-neighbor lookup (FAISS, Annoy, ScaNN, Pinecone) — no generative model needed. Recommendation engines apply the same idea, projecting users and items into a shared vector space and ranking by distance (Spotify, YouTube, Amazon). Anomaly and fraud detection embed transactions or log entries and flag outliers in vector space, while clustering and deduplication group similar items for topic discovery, customer segmentation, or duplicate detection. Code search maps natural-language queries and code into the same space (Sourcegraph's older approach, GitHub code search pre-Copilot). Finally, classification embeds inputs and compares them against class centroids or a simple linear head — faster and cheaper than calling a full LLM (e.g. Sentence-BERT for duplicate-question detection or support-ticket routing).

#### When Embeddings Are Enough

For tasks focused on matching, ranking, or grouping, embeddings alone are often sufficient: faster, cheaper, more deterministic, and easier to debug than reaching for an LLM.
