
# Section 7: Generative AI & June 2026 Exam Updates (New Content)

 

> The June 2026 refresh of the Professional ML Engineer exam adds generative-AI

> content and rebrands **Vertex AI → Gemini Enterprise Agent Platform**. This

> section covers only what the exam tests: **foundation models, tuning, grounding,

> evaluation, and responsible AI — all as models and pipelines.** (No agent-building.)

 

---

 

## 7.1 Foundation Models & Model Garden

 

**Choosing and accessing a base model:**

 

- **Model Garden** = catalog of first-party (Gemini, Imagen, Chirp), third-party, and open models (Gemma, Llama) — the single entry point for picking a foundation model.

- Prefer a **managed Gemini API** over self-hosting an open model unless you need weights, on-prem, or heavy customization.

- **Gemini Flash** = latency/cost-optimized; **Gemini Pro** = accuracy/reasoning-optimized. Match the tier to the SLA, not the hype.

 

**When to customize vs. when not to:**

 

- Try **prompt + context engineering first** — cheapest, no training, instant iteration.

- Move to **tuning** only when prompting plateaus on a consistent, narrow task.

 

> **Exam Q:** *A team gets inconsistent output formats from Gemini despite detailed

> prompts, on a fixed classification task with 5k labeled examples. Cheapest reliable fix?*

> → **Supervised fine-tuning**, not a bigger model or more prompt tokens. A stable

> narrow task + labeled data is the textbook tuning signal.

 

---

 

## 7.2 Tuning Foundation Models

 

**Know the ladder (cheap → expensive), and when each applies:**

 

| Method | What it changes | Use when |

|---|---|---|

| Prompt / few-shot | Nothing (in-context) | Task is easy to describe; fast iteration |

| **Supervised fine-tuning (SFT)** | Adapter weights (PEFT/LoRA) | Consistent task, labeled input→output pairs |

| **RLHF / preference tuning** | Reward-aligned weights | Quality is subjective (tone, helpfulness) |

| **Distillation** | Small student model | Need SFT quality at Flash-level cost/latency |

 

**Google-specific mechanics the exam probes:**

 

- **Fine-tune Gemini directly from BigQuery** — tuning data stays in BQ, no export step. This is a *new* exam-flagged capability.

- Vertex tuning produces a **new tuned model version** registered like any other — same deploy/monitor path as Section 4.

- Tuning is **PEFT/adapter-based**, not full-weight retraining — that's why it's affordable.

 

> **Exam Q:** *You need Gemini-Pro-level answers but at Flash cost for 10M calls/day. Approach?*

> → **Distill** Pro into a smaller model (or tuned Flash). Preference tuning fixes tone,

> not cost; a bigger model worsens cost.

 

---

 

## 7.3 Grounding & RAG (as a serving pattern)

 

Framed as a **retrieval + model** pipeline — not an agent.

 

- **Grounding** = tie model output to an authoritative source to cut hallucination.

- **RAG** = retrieve relevant chunks → inject into prompt context → generate.

- Google building blocks: **Vertex AI Search** (managed retrieval) and **Vector Search** (raw embedding ANN index) + an **embeddings model**.

 

**Exam decision points:**

 

- Facts change often, or must cite sources → **RAG/grounding**, not fine-tuning.

- Behavior/format/style is the gap → **tuning**, not RAG.

- Both wrong facts *and* wrong format → RAG **and** tuning are complementary.

 

> **Exam Q:** *An internal Q&A bot must answer from policy docs updated weekly and cite them.

> Fine-tune or RAG?*

> → **RAG** — weekly-changing facts + citation requirement. Fine-tuning bakes in stale

> facts and can't cite.

 

---

 

## 7.4 Prompt & Context Engineering

 

Foundational concepts now explicitly in scope:

 

- **Zero-shot vs. few-shot** — add worked examples when the model misreads intent.

- **Chain-of-thought** — "reason step by step" for multi-step/math tasks.

- **System instructions** — pin role, constraints, and output schema (e.g., "return JSON").

- **Context window management** — relevant retrieved context beats dumping everything; irrelevant filler degrades quality and cost.

 

> **Exam Q:** *Model does arithmetic-heavy reasoning wrong. No training budget. First lever?*

> → **Chain-of-thought prompting.** Free, immediate, targets multi-step reasoning.

 

---

 

## 7.5 Evaluating Generative AI

 

Gen-AI outputs are open-ended — classic accuracy/F1 don't fit.

 

- **Reference-based metrics**: ROUGE (summarization), BLEU (translation) — need golden answers.

- **LLM-as-a-judge**: Gemini scores coherence, groundedness, fluency at scale.

- **Vertex AI Evaluation service**: built-in SDK combining computed + model-judged metrics.

- **Groundedness** is the key RAG metric — is every claim supported by retrieved context?

 

> **Exam Q:** *How to evaluate a summarizer's quality across 50k docs with no human raters?*

> → **LLM-as-a-judge** (via Vertex AI Evaluation). ROUGE alone needs reference summaries;

> human review doesn't scale.

 

---

 

## 7.6 Responsible AI (now a named domain)

 

- **Safety filters** — Gemini harm categories (hate, harassment, dangerous, sexual); tune thresholds per use case.

- **Model Armor** — managed prompt-injection detection + output sanitization.

- **DLP** — detect/redact PII *before* it reaches the model or storage.

- **Fairness** — audit per demographic group; disparate-impact ratio **< 0.8** flags concern.

- **Transparency** — Model Cards document intended use, limits, and training data.

 

> **Exam Q:** *A gen-AI app risks leaking customer PII into prompts sent to Gemini. Control?*

> → **Cloud DLP** to redact PII pre-inference. Safety filters block harmful content, not PII.

 

---

 

## Key Exam Tips for Section 7

 

- **Model Garden** = pick a base model; **Gemini Flash** = cheap/fast, **Pro** = smart.

- **Prompt → tune → distill** is the cost ladder; start left, move right only when stuck.

- **Fine-tune Gemini from BigQuery directly** — new capability, no data export.

- **RAG for changing facts + citations; tuning for behavior/format.** Don't confuse them.

- **Chain-of-thought** = free fix for reasoning errors; **few-shot** = fix intent errors.

- **LLM-as-a-judge / Vertex AI Evaluation** = scalable gen-AI eval; **groundedness** = the RAG metric.

- **Model Armor** = prompt injection; **DLP** = PII; **safety filters** = harmful content — know which solves which.

- Platform rename: **Vertex AI → Gemini Enterprise Agent Platform**; the ML tooling (Pipelines, Training, Registry, Monitoring) is unchanged.

 

📖 [Model Garden](https://cloud.google.com/vertex-ai/docs/start/explore-models)

📖 [Tune Gemini models](https://cloud.google.com/vertex-ai/generative-ai/docs/models/tune-models)

📖 [Vertex AI Evaluation](https://cloud.google.com/vertex-ai/generative-ai/docs/models/evaluation-overview)

 

 

 

 