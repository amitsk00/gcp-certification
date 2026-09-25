
# Section 1: Architecting Low-Code AI Solutions (~13% of the Exam)
---

## 1.1 Developing ML Models Using BigQuery ML or AutoML on Gemini Enterprise Agent Platform

### Building Models in BigQuery ML or Agent Platform AutoML
BigQuery ML lets you create and execute ML models directly in BigQuery using SQL — no data movement or Python required.

#### Supported Model Types
| Type | SQL Example | Use Case |
|---|---|---|
| Logistic Regression (classification) | `CREATE MODEL ... OPTIONS(model_type='LOGISTIC_REG')` | Churn prediction, spam detection |
| Linear Regression | `OPTIONS(model_type='LINEAR_REG')` | Price forecasting |
| K-Means Clustering | `OPTIONS(model_type='KMEANS', num_clusters=5)` | Customer segmentation |
| ARIMA Plus (forecasting) | `OPTIONS(model_type='ARIMA_PLUS')` | Time-series demand forecasting |
| DNN Classifier/Regressor | `OPTIONS(model_type='DNN_CLASSIFIER')` | Complex tabular classification |
| XGBoost | `OPTIONS(model_type='BOOSTED_TREE_CLASSIFIER')` | Tabular data, Kaggle-style problems |

#### Example: Logistic Regression in BigQuery ML
```sql
CREATE OR REPLACE MODEL `my_project.my_dataset.churn_model`
OPTIONS(
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['churned'],
  max_iterations = 20
) AS
SELECT
  total_charges,
  tenure_months,
  contract_type,
  churned
FROM `my_project.my_dataset.customers`;
```

#### Agent Platform AutoML
AutoML automates the process of training high-quality models with minimal ML expertise:
- **Tabular**: Classification, regression, forecasting
- **Image**: Classification, object detection
- **Text**: Classification, entity extraction, sentiment analysis
- **Video**: Classification, object tracking, action recognition
**When to choose AutoML over BigQuery ML:**
- You have image, video, or text data (BigQuery ML is primarily tabular)
- You want Vertex AI ecosystem integration (pipelines, monitoring, endpoints)
- You need higher accuracy than SQL-based models offer
> **Tip for exam:** BigQuery ML = SQL interface, stays in BigQuery. AutoML = no-code GUI, broader data types, lives in Vertex AI / Agent Platform.
📖 [BigQuery ML docs](https://cloud.google.com/bigquery/docs/bqml-introduction)
📖 [AutoML on Vertex AI](https://cloud.google.com/vertex-ai/docs/beginner/beginners-guide)
---

### Performing Feature Engineering or Selection Using BigQuery ML
BigQuery ML supports feature preprocessing transforms directly in SQL before or during training.

#### Automatic Preprocessing (auto_class_weights, standardize)
```sql
CREATE OR REPLACE MODEL `my_project.dataset.model`
OPTIONS(
  model_type = 'LOGISTIC_REG',
  auto_class_weights = TRUE,  -- handles class imbalance
  input_label_cols = ['label']
) AS
SELECT * FROM `my_dataset.training_table`;
```

#### Manual Feature Transforms with TRANSFORM clause
```sql
CREATE OR REPLACE MODEL `my_project.dataset.model`
TRANSFORM(
  ML.STANDARD_SCALER(total_amount) OVER() AS scaled_amount,
  ML.ONE_HOT_ENCODER(category) OVER() AS encoded_category,
  ML.BUCKETIZE(age, [18, 30, 45, 60]) OVER() AS age_bucket,
  label
)
OPTIONS(model_type='LOGISTIC_REG', input_label_cols=['label'])
AS SELECT * FROM `my_dataset.data`;
```

#### Key Transform Functions
| Function | Purpose |
|---|---|
| `ML.STANDARD_SCALER` | Normalize numeric features (zero mean, unit variance) |
| `ML.MIN_MAX_SCALER` | Scale to [0, 1] range |
| `ML.ONE_HOT_ENCODER` | Encode categorical strings |
| `ML.BUCKETIZE` | Bin continuous values into categories |
| `ML.FEATURE_CROSS` | Create interaction features |
| `ML.NGRAMS` | Text n-gram features |

#### Feature Selection with ML.FEATURE_INFO
After training, inspect feature importance:
```sql
SELECT * FROM ML.FEATURE_INFO(MODEL `my_project.dataset.model`);
```
📖 [BigQuery ML preprocessing](https://cloud.google.com/bigquery/docs/bigqueryml-transform)
---

### Generating Predictions Using BigQuery ML
Three types of prediction functions:
```sql
-- Batch predictions
SELECT * FROM ML.PREDICT(
  MODEL `my_project.dataset.churn_model`,
  (SELECT * FROM `my_dataset.new_customers`)
);
-- Evaluate model performance
SELECT * FROM ML.EVALUATE(
  MODEL `my_project.dataset.churn_model`,
  (SELECT * FROM `my_dataset.test_customers`)
);
-- Explain predictions (feature attributions)
SELECT * FROM ML.EXPLAIN_PREDICT(
  MODEL `my_project.dataset.churn_model`,
  (SELECT * FROM `my_dataset.new_customers`),
  STRUCT(5 AS top_k_features)
);
```
**Output columns for classification:**
- `predicted_label` — the predicted class
- `predicted_label_probs` — probability per class
📖 [ML.PREDICT reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict)
---

### Training Models Using Agent Platform AutoML
Steps to train an AutoML model on Vertex AI:
1. **Create a Dataset** — upload tabular CSV, images, text files to Cloud Storage or BigQuery
2. **Configure Training** — select target column, budget (node hours), optimization objective
3. **Train** — Vertex AI handles splitting, hyperparameter search, ensembling
4. **Evaluate** — review confusion matrix, AUC-ROC, feature importance in the console
5. **Deploy** — one-click deploy to an endpoint for online prediction
**Key AutoML settings to know:**
| Setting | Notes |
|---|---|
| Training budget | Measured in node hours; more = potentially better model |
| Optimization objective | e.g., `maximize-au-roc`, `minimize-rmse` |
| Data split | Auto (80/10/10) or manual via `split_column` |
| Early stopping | Enabled by default; stops if no improvement |
📖 [Vertex AI AutoML Tabular](https://cloud.google.com/vertex-ai/docs/tabular-data/tabular-workflows/overview)
---

### Fine-Tuning Gemini Models Using BigQuery
BigQuery supports supervised fine-tuning of Gemini models directly via SQL using `CREATE MODEL` with `REMOTE_SERVICE_TYPE='CLOUD_AI_LARGE_LANGUAGE_MODEL_V1'`.
```sql
CREATE OR REPLACE MODEL `my_project.dataset.fine_tuned_gemini`
OPTIONS(
  model_type = 'GEMINI',
  base_model = 'gemini-1.5-pro-001',
  tuning_task = 'SUPERVISED_FINE_TUNING'
) AS
SELECT
  input_text,
  output_text
FROM `my_dataset.training_examples`;
```
**When to fine-tune vs. prompt engineer:**
- Fine-tune when: consistent format/style is required, domain-specific jargon matters, few-shot prompting isn't enough
- Prompt engineer when: task is general, latency/cost matters, you want rapid iteration
📖 [Fine-tune Gemini in BigQuery](https://cloud.google.com/bigquery/docs/generate-text-tutorial)
---

## 1.2 Building AI Solutions Using Google Cloud AI APIs or Foundational Models

### Evaluating and Selecting the Appropriate Model from Model Garden
**Gemini Enterprise Agent Platform Model Garden** is a central hub for discovering, testing, and deploying foundation models.

#### Decision Framework
| Requirement | Recommended Model |
|---|---|
| General text/code/reasoning | Gemini 1.5 Pro / Gemini 2.0 |
| Fast, low-cost text tasks | Gemini 1.5 Flash |
| Image generation | Imagen 3 |
| Video generation/understanding | Veo |
| Open-source flexibility | Llama 3, Mistral, Gemma |
| Embeddings | text-embedding-004 |
**Key model selection criteria:**
- **Latency** — Flash models are faster; Pro models are more capable
- **Context window** — Gemini 1.5 Pro supports up to 1M tokens
- **Modality** — text, image, audio, video
- **Cost** — billed per 1K input/output tokens
- **Fine-tuning support** — check if the model supports supervised fine-tuning
📖 [Model Garden](https://cloud.google.com/vertex-ai/generative-ai/docs/model-garden/explore-models)
---

### Building Applications Using Industry-Specific APIs
Google Cloud provides pre-trained, production-ready APIs for common AI tasks:

#### Document AI API
Extracts structured data from documents (invoices, contracts, IDs).
```python
from google.cloud import documentai
client = documentai.DocumentProcessorServiceClient()
name = client.processor_path(project, location, processor_id)
with open("invoice.pdf", "rb") as f:
    raw_document = documentai.RawDocument(content=f.read(), mime_type="application/pdf")
request = documentai.ProcessRequest(name=name, raw_document=raw_document)
result = client.process_document(request=request)
for entity in result.document.entities:
    print(f"{entity.type_}: {entity.mention_text}")
```

#### Vision API
```python
from google.cloud import vision
client = vision.ImageAnnotatorClient()
image = vision.Image(source=vision.ImageSource(image_uri="gs://my-bucket/image.jpg"))

# Label detection
response = client.label_detection(image=image)
for label in response.label_annotations:
    print(label.description, label.score)

# OCR
response = client.text_detection(image=image)
print(response.full_text_annotation.text)
```

#### Translate API
```python
from google.cloud import translate_v2 as translate
client = translate.Client()
result = client.translate("Hello, world!", target_language="es")
print(result["translatedText"])  # "¡Hola, mundo!"
```
**Other notable APIs:** Speech-to-Text, Text-to-Speech, Natural Language API, Video Intelligence API
📖 [Document AI](https://cloud.google.com/document-ai/docs) | [Vision API](https://cloud.google.com/vision/docs) | [Translate API](https://cloud.google.com/translate/docs)
---

### Building Solutions and Tuning Models for Specific Use Cases

#### Gemini (Text, Multimodal)
```python
import vertexai
from vertexai.generative_models import GenerativeModel, Part
vertexai.init(project="my-project", location="us-central1")
model = GenerativeModel("gemini-1.5-pro")

# Multimodal: image + text
image_part = Part.from_uri("gs://my-bucket/chart.png", mime_type="image/png")
response = model.generate_content(["Describe this chart:", image_part])
print(response.text)
```

#### Imagen (Image Generation)
```python
from vertexai.preview.vision_models import ImageGenerationModel
model = ImageGenerationModel.from_pretrained("imagegeneration@006")
images = model.generate_images(
    prompt="A futuristic city skyline at sunset, photorealistic",
    number_of_images=1,
    aspect_ratio="16:9"
)
images[0].save("output.png")
```

#### Veo (Video Generation)
Veo generates high-quality video clips from text or image prompts. Accessed via Vertex AI API or the console.

#### Models as a Service (MaaS)
Open-source models (Llama, Mistral, Gemma) served via Model Garden without managing infrastructure — pay per token, no GPU provisioning needed.
📖 [Gemini API on Vertex AI](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/overview)
---

### Optimizing Gemini-Based Applications for Cost, Latency, and Availability

#### Cost Optimization
| Strategy | How |
|---|---|
| Use smaller/flash models | Gemini Flash is ~10x cheaper than Pro |
| Reduce token count | Trim system prompts, use structured output |
| Cache responses | Use context caching for repeated long contexts |
| Batch requests | Use batch prediction API for offline workloads |

#### Latency Optimization
- **Streaming responses**: Return tokens as generated instead of waiting for full response
  ```python
  for chunk in model.generate_content("Tell me a story", stream=True):
      print(chunk.text, end="")
  ```
- **Reduce max output tokens**: Set `max_output_tokens` if full response isn't needed
- **Flash model**: Lower latency than Pro at the cost of some quality
- **Region selection**: Deploy in regions closest to users

#### Availability
- Use **Vertex AI endpoints** with auto-scaling
- Set up **fallback models** in your application logic
- Monitor with **Cloud Monitoring** alerts on error rates and latency
📖 [Gemini cost optimization](https://cloud.google.com/vertex-ai/generative-ai/docs/cost-optimization)
📖 [Context caching](https://cloud.google.com/vertex-ai/generative-ai/docs/context-cache/context-cache-overview)
---

## Key Exam Tips for Section 1
- **BigQuery ML** = SQL-only, stays in BigQuery warehouse, fast to prototype
- **AutoML** = GUI-driven, broader data types, automatic feature engineering
- **Model Garden** = catalog of foundation + open-source models
- **Pre-trained APIs** = zero training needed, best for common tasks (OCR, translation, object detection)
- **Fine-tuning** = needed when base model behavior is consistently wrong for your domain
- Choose **Gemini Flash** for cost/speed, **Gemini Pro** for complex reasoning tasks
 