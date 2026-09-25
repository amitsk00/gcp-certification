
# Section 2: Collaborating Within and Across Teams to Manage Data and Models (~16% of the Exam)

 

---

 

## 2.1 Exploring and Preprocessing Data for ML

 

### Organizing and Exploring Different Data Types

 

Understanding how to store and explore each data type efficiently is fundamental.

 

#### Tabular Data

 

- **Storage**: BigQuery (structured), Cloud Storage (CSV/Parquet/Avro)

- **Exploration tools**: BigQuery console, Looker Studio, Pandas in notebooks

- **Key tasks**: schema validation, null checks, distribution analysis, outlier detection

 

```python

import pandas as pd

 

df = pd.read_csv("gs://my-bucket/data.csv")

print(df.describe())          # summary statistics

print(df.isnull().sum())      # missing values per column

print(df['label'].value_counts())  # class balance

```

 

#### Text Data

 

- **Storage**: Cloud Storage (raw text/JSON), BigQuery (structured text columns)

- **Exploration**: token counts, vocabulary size, language distribution

- **Preprocessing**: tokenization, lowercasing, stop-word removal, TF-IDF

 

```python

from collections import Counter

import re

 

def tokenize(text):

    return re.findall(r'\b\w+\b', text.lower())

 

all_words = [word for doc in corpus for word in tokenize(doc)]

print(Counter(all_words).most_common(20))

```

 

#### Image Data

 

- **Storage**: Cloud Storage (JPEG/PNG), with metadata in BigQuery or JSONL

- **Exploration**: class distribution, image size distribution, brightness/contrast stats

- **Common issue**: class imbalance — use oversampling or `class_weight` in training

 

```python

from PIL import Image

import os

 

sizes = [Image.open(f).size for f in image_files]

print(set(sizes))  # check if all images are the same size

```

 

📖 [Vertex AI Data preparation](https://cloud.google.com/vertex-ai/docs/datasets/prepare)

 

---

 

### Choosing the Right Tool for Data Preprocessing

 

#### Decision Matrix

 

| Tool | Scale | Data Type | Paradigm | Best For |

|---|---|---|---|---|

| BigQuery (SQL) | Petabyte | Tabular | Batch SQL | Fast SQL transforms, feature engineering at scale |

| Dataflow (Apache Beam) | Large | Any | Batch + Streaming | Complex transforms, training-serving consistency |

| Apache Spark (Dataproc) | Large | Any | Batch | ML pipelines with existing Spark code |

| Pandas/NumPy (in-memory) | Small–Medium | Any | In-memory | Prototyping, notebooks, small datasets |

| Scikit-learn Pipelines | Small–Medium | Tabular | In-memory | Combined preprocessing + training |

 

#### BigQuery SQL Preprocessing

 

```sql

-- Normalize a column and one-hot encode a category

SELECT

  user_id,

  (amount - AVG(amount) OVER()) / STDDEV(amount) OVER() AS normalized_amount,

  IF(category = 'premium', 1, 0) AS is_premium,

  label

FROM `my_dataset.transactions`

WHERE date >= '2024-01-01';

```

 

#### Apache Beam / Dataflow

 

Use Dataflow when you need the **same preprocessing code** for both training and serving (avoids training-serving skew).

 

```python

import apache_beam as beam

from apache_beam.options.pipeline_options import PipelineOptions

 

options = PipelineOptions(

    runner='DataflowRunner',

    project='my-project',

    region='us-central1',

    temp_location='gs://my-bucket/temp'

)

 

with beam.Pipeline(options=options) as p:

    (p

     | 'Read' >> beam.io.ReadFromText('gs://my-bucket/input.csv')

     | 'Parse' >> beam.Map(parse_csv)

     | 'Transform' >> beam.Map(normalize_features)

     | 'Write' >> beam.io.WriteToText('gs://my-bucket/output')

    )

```

 

#### TensorFlow Transform (tf.Transform)

 

Ideal for consistent preprocessing when using TensorFlow — computes statistics on full dataset, applies them at serving time.

 

```python

import tensorflow_transform as tft

 

def preprocessing_fn(inputs):

    return {

        'normalized_x': tft.scale_to_z_score(inputs['x']),

        'vocab_y': tft.compute_and_apply_vocabulary(inputs['y']),

    }

```

 

📖 [Dataflow ML preprocessing](https://cloud.google.com/dataflow/docs/guides/ml-guide)

📖 [TFX Transform](https://www.tensorflow.org/tfx/transform/get_started)

 

---

 

### Creating and Consolidating Features in Agent Platform Feature Store

 

**Feature Store** is a managed service for storing, sharing, and serving ML features consistently between training and serving.

 

#### Key Concepts

 

| Concept | Description |

|---|---|

| Feature Group | A logical collection of features (backed by a BigQuery table) |

| Feature | An individual feature column |

| Feature View | A materialized view for online serving |

| Online Store | Low-latency key-value store for real-time feature lookup |

 

#### Workflow

 

```python

from google.cloud import aiplatform

 

aiplatform.init(project="my-project", location="us-central1")

 

# 1. Create a Feature Group (points to BQ table)

fg = aiplatform.FeatureGroup.create(

    name="user_features",

    source=aiplatform.FeatureGroup.BigQuerySource(

        uri="bq://my-project.my_dataset.user_features_table",

        entity_id_columns=["user_id"]

    )

)

 

# 2. Create Features within the group

feature = fg.create_feature(name="lifetime_value", version_column_name="lifetime_value")

 

# 3. Create a Feature View for serving

fv = aiplatform.FeatureView.create(

    name="user_fv",

    feature_group_id="user_features",

    feature_ids=["lifetime_value"],

    sync_config=aiplatform.FeatureViewSyncConfig(cron="0 * * * *")

)

 

# 4. Fetch features at serving time

result = fv.read(key=["user_123"])

```

 

**Why Feature Store matters for the exam:**

- Avoids training-serving skew by using the same feature logic

- Enables feature sharing across teams/models

- Online serving with <10ms latency

 

#### The Core Mental Model: Offline vs. Online Store

 

This split is the single most-tested Feature Store idea — get it and most questions fall out:

 

| | **Offline store** | **Online store** |

|---|---|---|

| Backing | BigQuery (columnar, cheap, huge) | Low-latency KV store (Bigtable/Optimized) |

| Read pattern | Bulk, historical, many rows | Single entity by key, one row |

| Used for | **Training** dataset generation | **Serving** real-time predictions |

| Latency | Seconds–minutes | Single-digit ms |

 

The **same feature definitions feed both**, and that's exactly what kills training-serving skew — training reads the offline store, serving reads the online store, but the feature *logic* is identical.

 

>  Vertex AI Feature Store = single store, ingest once, serve two ways: batch API for training (point-in-time correct), online API for inference (low latency). Same features both ways = no training-serving skew.

 

#### Point-in-Time Correctness (the concept that fixes label leakage)

 

When you build a training set, each label has a timestamp. You must join **only the feature values that were known at or before that moment** — never a value computed later. Grabbing a "future" feature value is **data leakage**: the model looks great in training and fails in production.

 

- Feature Store does this join for you (a **point-in-time / "time-travel" lookup**).

- Rolling your own with a plain SQL join almost always leaks unless you carefully filter `feature_timestamp <= label_timestamp`.

 

> **Mnemonic:** *"Would I have known this value at prediction time?"* If no, it leaks.

 

#### Freshness, Sync & TTL

 

- **Sync / materialization** = pushing computed features from offline (BQ) into the online store on a schedule (the `cron` in the Feature View). Between syncs, online values are as stale as the last sync.

- Match sync cadence to how fast the feature changes — real-time fraud signals need frequent syncs; a customer's home region rarely changes.

- **TTL** bounds how old a served value can be, guarding against serving stale features when a sync fails.

 

#### When NOT to use Feature Store

 

- One-off model, features used by nobody else, no online serving → a plain BigQuery table is simpler and cheaper.

- Feature needed only at training time (never at low-latency serving) → offline/BQ is enough; the online store adds cost for no benefit.

 

> **Exam Q:** *Your model scores well offline but degrades badly in production, and you built the

> training set with a manual SQL join of features to labels. Likely cause?*

> → **Label leakage from missing point-in-time correctness** — the join pulled feature values

> computed after the label timestamp. Use Feature Store's point-in-time lookup (or filter on

> `feature_timestamp <= label_timestamp`).

 

> **Exam Q:** *Real-time predictions need feature lookups under 10ms by entity key. Which store?*

> → **Online store** (Feature View materialized to the online store), not a BigQuery query.

 

📖 [Vertex AI Feature Store](https://cloud.google.com/vertex-ai/docs/featurestore/overview)

📖 [Point-in-time lookups](https://cloud.google.com/vertex-ai/docs/featurestore/latest/serving-batch)

 

---

 

### Ensuring Data Privacy and Handling Sensitive Information (PII)

 

#### PII Detection with Cloud DLP (Data Loss Prevention)

 

```python

from google.cloud import dlp_v2

 

dlp = dlp_v2.DlpServiceClient()

 

inspect_config = dlp_v2.InspectConfig(

    info_types=[

        {"name": "EMAIL_ADDRESS"},

        {"name": "PHONE_NUMBER"},

        {"name": "CREDIT_CARD_NUMBER"},

    ]

)

 

item = dlp_v2.ContentItem(value="Contact us at john.doe@example.com or 555-1234")

 

response = dlp.inspect_content(

    request={

        "parent": f"projects/my-project",

        "inspect_config": inspect_config,

        "item": item,

    }

)

 

for finding in response.result.findings:

    print(finding.info_type.name, finding.likelihood)

```

 

#### Anonymization Techniques

 

| Technique | Description | Example |

|---|---|---|

| Masking | Replace with fixed char | `john@email.com` → `xxxx@email.com` |

| Tokenization | Replace with token | `john@email.com` → `TOKEN_1234` |

| Pseudonymization | Replace with consistent pseudonym | Deterministic replacement |

| Generalization | Reduce precision | Age `34` → `30-40` |

| Bucketing | Group values into ranges | Salary exact → salary range |

 

#### Data Governance Best Practices

 

- Use **IAM roles** to restrict dataset access (e.g., `bigquery.dataViewer`)

- Enable **BigQuery column-level security** with policy tags

- Use **VPC Service Controls** to prevent data exfiltration

- Tag sensitive columns in **Data Catalog**

- Enable **audit logging** for all data access

 

📖 [Cloud DLP](https://cloud.google.com/dlp/docs) | [BigQuery column security](https://cloud.google.com/bigquery/docs/column-level-security)

 

---

 

## 2.2 Model Prototyping Using Notebooks

 

### Collaboration and Security Best Practices for Notebooks

 

#### Vertex AI Workbench vs. Colab Enterprise

 

| Feature | Workbench | Colab Enterprise |

|---|---|---|

| Infrastructure | Managed VM (JupyterLab) | Serverless (managed runtimes) |

| Cost model | VM uptime | Compute used |

| Idle shutdown | Configurable | Automatic |

| GPU support | Yes | Yes |

| VPC integration | Yes | Yes |

| Best for | Long-running experiments | Interactive, collaborative work |

 

#### Security Best Practices

 

- **No public IPs**: Use private networking with VPC

- **Service accounts**: Assign least-privilege service accounts to notebooks

- **Secret Manager**: Store API keys and credentials, not in notebook cells

  ```python

  from google.cloud import secretmanager

  client = secretmanager.SecretManagerServiceClient()

  secret = client.access_secret_version(name="projects/my-project/secrets/api-key/versions/latest")

  api_key = secret.payload.data.decode("UTF-8")

  ```

- **Enable idle shutdown**: Prevents runaway costs

- **Restrict notebook sharing**: Use IAM, not public links

- **Organization policies**: Enforce notebook configuration at org level

 

📖 [Vertex AI Workbench security](https://cloud.google.com/vertex-ai/docs/workbench/user-managed/security-overview)

 

---

 

### Developing Models Using Common Frameworks

 

#### PyTorch

 

```python

import torch

import torch.nn as nn

 

class SimpleNet(nn.Module):

    def __init__(self, input_dim, hidden_dim, output_dim):

        super().__init__()

        self.layers = nn.Sequential(

            nn.Linear(input_dim, hidden_dim),

            nn.ReLU(),

            nn.Dropout(0.3),

            nn.Linear(hidden_dim, output_dim)

        )

 

    def forward(self, x):

        return self.layers(x)

 

model = SimpleNet(input_dim=10, hidden_dim=64, output_dim=1)

optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)

criterion = nn.BCEWithLogitsLoss()

```

 

#### Scikit-learn

 

```python

from sklearn.pipeline import Pipeline

from sklearn.preprocessing import StandardScaler

from sklearn.ensemble import GradientBoostingClassifier

from sklearn.model_selection import cross_val_score

 

pipeline = Pipeline([

    ('scaler', StandardScaler()),

    ('model', GradientBoostingClassifier(n_estimators=100, max_depth=3))

])

 

scores = cross_val_score(pipeline, X_train, y_train, cv=5, scoring='roc_auc')

print(f"AUC: {scores.mean():.3f} +/- {scores.std():.3f}")

pipeline.fit(X_train, y_train)

```

 

#### JAX

 

JAX is NumPy-compatible with automatic differentiation and XLA compilation — used for high-performance research models.

 

```python

import jax

import jax.numpy as jnp

 

@jax.jit  # compile for speed

def loss_fn(params, x, y):

    preds = jnp.dot(x, params['w']) + params['b']

    return jnp.mean((preds - y) ** 2)

 

grad_fn = jax.grad(loss_fn)

grads = grad_fn(params, X_batch, y_batch)

```

 

📖 [JAX docs](https://jax.readthedocs.io/) | [PyTorch on Vertex AI](https://cloud.google.com/vertex-ai/docs/training/pytorch-gpu)

 

---

 

### Using Foundational and Open-Source Models in Model Garden

 

Accessing models from the Model Garden in a notebook:

 

```python

import vertexai

from vertexai.generative_models import GenerativeModel

 

vertexai.init(project="my-project", location="us-central1")

 

# Use Gemini directly

model = GenerativeModel("gemini-1.5-flash")

response = model.generate_content("Summarize this text: ...")

print(response.text)

 

# Deploy open-source model (e.g., Llama) from Model Garden to endpoint

# Done via console or Vertex AI SDK deploy call

```

 

---

 

## 2.3 Tracking and Running ML Experiments

 

### Choosing the Appropriate Google Cloud Environment

 

| Environment | Use Case | Framework Support |

|---|---|---|

| Vertex AI Experiments | Track metrics/params for any training job | Any |

| Vertex AI Pipelines | Orchestrate multi-step ML workflows | KFP, TFX |

| Kubeflow Pipelines (KFP) on GKE | Custom pipeline orchestration on Kubernetes | KFP |

| Colab Enterprise | Interactive experimentation | Any |

 

### Tracking Experiments with Vertex AI Experiments

 

```python

import vertexai

from vertexai.preview.ml_metadata import MetadataServiceClient

 

vertexai.init(project="my-project", location="us-central1", experiment="my-experiment")

 

# Start a run

with vertexai.preview.metadata.start_run(run="run-001"):

    # Log hyperparameters

    vertexai.preview.metadata.log_params({"learning_rate": 0.01, "epochs": 50})

 

    # ... training loop ...

 

    # Log metrics

    vertexai.preview.metadata.log_metrics({"accuracy": 0.91, "loss": 0.23})

```

 

Compare runs in the Vertex AI console or programmatically:

 

```python

experiment = vertexai.Experiment("my-experiment")

df = experiment.get_data_frame()

print(df.sort_values("metric.accuracy", ascending=False))

```

 

📖 [Vertex AI Experiments](https://cloud.google.com/vertex-ai/docs/experiments/intro-vertex-ai-experiments)

 

---

 

### Evaluating Predictive and Gen AI Solutions

 

#### Traditional ML Metrics

 

| Task | Key Metrics |

|---|---|

| Binary Classification | AUC-ROC, precision, recall, F1, log loss |

| Multi-class | Macro/micro F1, confusion matrix |

| Regression | RMSE, MAE, R² |

| Forecasting | MAPE, WAPE, RMSSE |

| Clustering | Silhouette score, Davies-Bouldin |

 

```python

from sklearn.metrics import classification_report, roc_auc_score

 

y_pred = model.predict(X_test)

y_prob = model.predict_proba(X_test)[:, 1]

 

print(classification_report(y_test, y_pred))

print(f"AUC-ROC: {roc_auc_score(y_test, y_prob):.4f}")

```

 

#### LLM-as-a-Judge

 

Use a powerful LLM (e.g., Gemini Pro) to evaluate outputs of another model:

 

```python

from vertexai.generative_models import GenerativeModel

 

judge = GenerativeModel("gemini-1.5-pro")

 

def evaluate_response(question, response, reference):

    prompt = f"""

    Question: {question}

    Reference Answer: {reference}

    Model Response: {response}

 

    Rate the model response on a scale of 1-5 for:

    1. Accuracy

    2. Completeness

    3. Clarity

 

    Respond in JSON format.

    """

    return judge.generate_content(prompt).text

 

score = evaluate_response(q, model_response, ground_truth)

```

 

**LLM-as-a-judge is useful when**: human evaluation is too slow, reference answers exist, you need automated quality gates in a pipeline.

 

📖 [Vertex AI model evaluation](https://cloud.google.com/vertex-ai/docs/evaluation/introduction)

 

---

 

### Tracking and Comparing Model Artifacts with ML Metadata

 

**ML Metadata** (MLMD) automatically tracks lineage: datasets → training jobs → models → endpoints.

 

```python

from google.cloud import aiplatform

 

# List all models in the registry

models = aiplatform.Model.list(filter="display_name=my_model")

for model in models:

    print(model.display_name, model.version_id, model.create_time)

 

# Get artifact lineage

model = aiplatform.Model("projects/my-project/locations/us-central1/models/12345")

print(model.gca_resource.training_pipeline)  # which pipeline created this model

```

 

**Key lineage concepts:**

- **Artifact**: A dataset, model, or metric

- **Execution**: A training job or pipeline step

- **Context**: Groups related artifacts and executions (e.g., an experiment)

- **Event**: Links an execution to its inputs/outputs

 

📖 [Vertex ML Metadata](https://cloud.google.com/vertex-ai/docs/ml-metadata/introduction)

 

---

 

## Key Exam Tips for Section 2

 

- **Feature Store** = solve training-serving skew; share features across teams

- **Dataflow** = large-scale preprocessing with consistent logic for train and serve

- **BigQuery SQL** = easiest for tabular transformations at scale

- **DLP** = detect and redact PII before training

- **Workbench** = persistent VM; **Colab Enterprise** = serverless, auto-shutdown

- **LLM-as-a-judge** = automated eval for generative outputs when ground truth exists

- **ML Metadata** = tracks lineage (dataset → model → endpoint) automatically

- Always use **Secret Manager** for credentials in notebooks, never hardcode them

 

 