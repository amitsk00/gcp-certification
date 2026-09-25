# Section 3: Scaling Prototypes into ML Models (~21% of the Exam)
This is the **largest section** of the exam. Focus on training infrastructure, model selection, hyperparameter tuning, and distributed training.

---

## 3.1 Building Models Given the Task: Cost, Complexity, Latency, Scalability

### Choosing the Model Type

#### Model Type Decision Guide
| Problem Type | Data | Recommended Model |
|---|---|---|
| Time-series forecasting | Sequential, timestamped | ARIMA Plus, LSTM, Temporal Fusion Transformer |
| Tabular classification | Structured rows | GBM (XGBoost), DNN, Logistic Regression |
| Tabular regression | Structured rows | Linear Regression, GBM, DNN |
| Text classification | Short text | BERT fine-tune, Gemini |
| Large-scale text generation | Any text | LLM (Gemini, Llama) |
| Image classification | Images | CNN (ResNet, EfficientNet), AutoML Vision |
| Object detection | Images | YOLO, Faster R-CNN, AutoML |
| Recommendation | User-item matrix | Matrix Factorization, DNN, Two-Tower |

#### Tabular Classification — Architecture Choice by Interpretability
This is a frequent exam trap. The right answer depends on whether the business requires the model to be self-explanatory, or just explainable after the fact.

**The interpretability spectrum:**
| Model | Inherently interpretable? | Accuracy | Choose when |
|---|---|---|---|
| **Logistic Regression** | Yes — coefficients are the explanation | Lower | Regulatory compliance, need to explain every decision (lending, insurance) |
| **Decision Tree (shallow, depth ≤ 5)** | Yes — readable if-then path | Medium | Non-technical stakeholders, auditable rules, small feature set |
| **Linear SVM** | Yes — weighted feature sum | Medium | Binary classification, high-dimensional sparse features |
| **Random Forest** | No — ensemble of trees | High | Good accuracy, don't need per-decision explanation |
| **XGBoost / GBM** | No — boosted ensemble | Highest | Maximum accuracy, use SHAP for post-hoc attribution |
| **DNN** | No — nonlinear black box | High | Complex feature interactions, tabular + embeddings |

**Two levels of "interpretable" — know which level the exam is using:**
- **Level 1 — Inherently interpretable**: the model structure IS the explanation. No tool needed. Logistic Regression (coefficient = feature weight) or shallow Decision Tree (readable if-then path). Used in heavy regulatory contexts (credit scoring statutes, clinical audit).
- **Level 2 — Explainable via exact attribution**: a black-box model + an exact explanation method. XGBoost + TreeSHAP = exact per-prediction feature attributions. This is what the GCP exam means by "interpretable" for tabular classification, because the explanation is exact (not an approximation) and fast.

The GCP Professional ML Engineer exam uses **Level 2** when asking about interpretable tabular models. The realistic choice is between XGBoost and DNN — and XGBoost wins on interpretability every time.

**XGBoost vs DNN for interpretability on tabular:**
| | XGBoost | DNN |
|---|---|---|
| Model structure | Ensemble of trees — tree logic is inspectable | Layered nonlinear transforms — opaque |
| Per-prediction explanation | **TreeSHAP — exact, fast** | Integrated Gradients — path integral approximation |
| Feature importance | Native, built-in | Not native |
| Accuracy on tabular | Highest (usually) | Lower without heavy tuning |
| Interpretability verdict | **More interpretable** | Least interpretable tabular option |

> **The exam answer:** "structured tabular dataset + highly interpretable + explain to customers" → **XGBoost** (not DNN, not logistic regression). XGBoost + TreeSHAP gives exact per-prediction attribution; DNN + IG gives only an approximation.

> **Exam trap — DNN:** Integrated Gradients on a DNN is an approximation (path integral sampled at `step_count` points). TreeSHAP on XGBoost is mathematically exact. "Exact explanation" = tree model, not neural net.

> **Exam trap — Logistic Regression:** Would be correct only if the question specifically mentions regulatory compliance, auditable decision rules, or a need to explain the model itself (not just individual predictions). If the question just says "interpretable" with accuracy as a constraint, LR sacrifices too much accuracy on tabular data — XGBoost is the practical answer.

**Decision rule for the exam:**
```
"explain decisions to customers" + tabular data
  → XGBoost (exact TreeSHAP attributions via Vertex Explainable AI)

"regulators must audit the model logic / stable auditable rules required"
  → Logistic Regression or shallow Decision Tree (inherently interpretable)

"accuracy is the only priority, no explanation needed"
  → XGBoost (still — it beats DNN on tabular)

"complex feature interactions, embeddings, very large dataset"
  → DNN
```

**Why XGBoost usually beats DNN on tabular data:**
- Tabular data lacks spatial/sequential structure that makes NNs shine
- XGBoost handles mixed types, missing values, and varying feature scales natively
- DNNs need careful tuning (learning rate, batch norm, regularization) just to match XGBoost baseline
- Rule of thumb: default to XGBoost on tabular; use DNN only when you have embeddings or sequential structure

#### ARIMA vs. DNN vs. LLM
| Dimension | ARIMA Plus | DNN | LLM |
|---|---|---|---|
| Data needed | Small (hundreds of points) | Medium (thousands+) | Large or pre-trained |
| Interpretability | High (explicit seasonality/trend) | Low | Very low |
| Training cost | Very low | Medium | Very high (or zero if using MaaS) |
| Latency | Low | Medium | Medium-High |
| Custom data types | Tabular time-series only | Tabular, images, text | Text, images, audio, video |

---

### Choosing the Product
| Scenario | Product |
|---|---|
| SQL-only team, tabular data, fast iteration | **BigQuery ML** |
| No ML expertise, structured/image/text data | **AutoML (Agent Platform)** |
| Custom model, full control, any framework | **Agent Platform Custom Training** |
| Multi-step ML workflow automation | **Agent Platform Pipelines** |
| Existing Spark/Hadoop infrastructure | **Dataproc** |
| Kubernetes workloads | **Kubeflow on GKE** |

---

### Choosing the Deployment Strategy
| Strategy | Description | Use Case |
|---|---|---|
| Single endpoint | One model version on endpoint | Simple, low-traffic |
| A/B testing | Split traffic between two model versions | Comparing models in production |
| Canary deployment | Route small % to new version, ramp up | Safe rollout with monitoring |
| Shadow deployment | Mirror traffic to new model, don't return results | Test without user impact |
| Blue/Green | Switch all traffic at once with fallback | Zero-downtime deployments |

---

### Modeling Techniques for Interpretability
| Level | Technique | Tool |
|---|---|---|
| Global | Feature importance | SHAP, sklearn `.feature_importances_` |
| Global | Partial dependence plots (PDP) | `sklearn.inspection.PartialDependenceDisplay` |
| Local | SHAP values per prediction | `shap` library |
| Local | LIME | `lime` library |
| GCP-native | Feature attributions | `ML.EXPLAIN_PREDICT` (BQML), Vertex Explainable AI |

```python
import shap

explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)
shap.summary_plot(shap_values, X_test)
```

📖 [Vertex Explainable AI](https://cloud.google.com/vertex-ai/docs/explainable-ai/overview)

---

## 3.2 Training Models

### Organizing Training Data on Google Cloud

#### Storage Format Recommendations
| Format | Best For | Notes |
|---|---|---|
| TFRecord | TensorFlow training | Efficient binary, supports sharding |
| Parquet | Large tabular datasets | Columnar, efficient compression |
| CSV | Small tabular datasets | Human-readable, slow at scale |
| JSONL | Text/NLP datasets | One JSON object per line |
| Image files (JPEG/PNG) | Vision | Store in GCS with JSONL manifest |

#### Directory Structure Best Practice
```
gs://my-bucket/
├── data/
│   ├── train/
│   │   ├── part-00000.tfrecord
│   │   └── part-00001.tfrecord
│   ├── validation/
│   └── test/
├── models/
│   └── v1/
└── pipelines/
```

#### Writing TFRecords
```python
import tensorflow as tf

def serialize_example(feature, label):
    feature_dict = {
        'feature': tf.train.Feature(float_list=tf.train.FloatList(value=feature)),
        'label': tf.train.Feature(int64_list=tf.train.Int64List(value=[label]))
    }
    example = tf.train.Example(features=tf.train.Features(feature=feature_dict))
    return example.SerializeToString()

with tf.io.TFRecordWriter("gs://my-bucket/data/train/part-00000.tfrecord") as writer:
    for feature, label in zip(X_train, y_train):
        writer.write(serialize_example(feature, label))
```

---

### Ingesting Data into Training Pipelines

#### From BigQuery to Training
```python
from google.cloud import bigquery
import pandas as pd

client = bigquery.Client()
query = "SELECT * FROM `my_project.dataset.training_table`"
df = client.query(query).to_dataframe()
X, y = df.drop('label', axis=1), df['label']
```

#### From Cloud Storage with tf.data
```python
import tensorflow as tf

def parse_tfrecord(serialized):
    features = tf.io.parse_single_example(serialized, feature_description)
    return features['feature'], features['label']

dataset = (
    tf.data.TFRecordDataset(tf.io.gfile.glob("gs://bucket/data/train/*.tfrecord"))
    .map(parse_tfrecord, num_parallel_calls=tf.data.AUTOTUNE)
    .shuffle(10000)
    .batch(256)
    .prefetch(tf.data.AUTOTUNE)
)
```

---

### Model Training Using Different SDKs

#### Agent Platform Custom Training
```python
from google.cloud import aiplatform

aiplatform.init(project="my-project", location="us-central1")

job = aiplatform.CustomTrainingJob(
    display_name="my-training-job",
    script_path="train.py",
    container_uri="us-docker.pkg.dev/vertex-ai/training/tf-cpu.2-12:latest",
    requirements=["scikit-learn==1.3.0"],
    model_serving_container_image_uri="us-docker.pkg.dev/vertex-ai/prediction/tf2-cpu.2-12:latest"
)

model = job.run(
    dataset=my_dataset,
    model_display_name="my-model",
    machine_type="n1-standard-4",
    args=["--epochs=50", "--learning-rate=0.01"],
    replica_count=1
)
```

#### Kubeflow Pipelines on GKE
```python
import kfp
from kfp import dsl

@dsl.component
def preprocess(data_path: str) -> str:
    # preprocessing logic
    return output_path

@dsl.component
def train(data_path: str, model_path: str):
    # training logic
    pass

@dsl.pipeline(name="my-ml-pipeline")
def pipeline(data_path: str):
    preprocess_op = preprocess(data_path=data_path)
    train(data_path=preprocess_op.output, model_path="gs://bucket/model")

# Compile and submit
compiler.Compiler().compile(pipeline, "pipeline.yaml")
client = kfp.Client(host=https://my-kfp-endpoint)
client.create_run_from_pipeline_func(pipeline, arguments={"data_path": "gs://bucket/data"})
```

#### Tabular Workflows (AutoML Enhanced)
Tabular Workflows in Vertex AI automate training of tabular models using Neural Architecture Search and provides more control than pure AutoML.

---

### Troubleshooting ML Model Training Failures

#### Common Failures and Fixes
| Symptom | Likely Cause | Fix |
|---|---|---|
| OOM (Out of Memory) | Batch size too large | Reduce batch size, use gradient checkpointing |
| Loss is NaN | Learning rate too high / exploding gradients | Use gradient clipping, lower LR, check for inf in data |
| Loss not decreasing | Learning rate too low / data issue | LR finder, check data pipeline |
| Overfitting | Model too complex, not enough data | Dropout, L2 regularization, more data, early stopping |
| Underfitting | Model too simple | Increase model capacity, more features |
| Training hangs | Data pipeline bottleneck | Profile with TF Profiler, increase prefetch |
| Job fails immediately | Container image issue / dependency conflict | Check logs in Cloud Logging |

#### Viewing Training Logs
```bash
# View Vertex AI training job logs
gcloud ai custom-jobs describe JOB_ID --project=my-project --region=us-central1

# Streaming logs
gcloud logging read "resource.type=ml_job AND resource.labels.job_id=JOB_ID" --project=my-project
```

#### Gradient Issues
```python
# Gradient clipping to prevent explosions
optimizer = tf.keras.optimizers.Adam(learning_rate=1e-3, clipnorm=1.0)

# Gradient norm monitoring
@tf.function
def train_step(x, y):
    with tf.GradientTape() as tape:
        loss = loss_fn(model(x), y)
    grads = tape.gradient(loss, model.trainable_variables)
    grad_norm = tf.linalg.global_norm(grads)
    tf.summary.scalar('gradient_norm', grad_norm)
    optimizer.apply_gradients(zip(grads, model.trainable_variables))
```

---

### Hyperparameter Tuning

#### Manual vs. Automated Tuning
| Approach | Tool | Notes |
|---|---|---|
| Manual grid search | `sklearn.GridSearchCV` | Exhaustive, slow |
| Random search | `sklearn.RandomizedSearchCV` | Faster, good for large spaces |
| Bayesian optimization | Vertex AI Vizier | Smart, learns from past trials |
| Neural Architecture Search | AutoML / Tabular Workflows | Automated model design |

#### Vertex AI Vizier (Managed Hyperparameter Tuning)
```python
from google.cloud import aiplatform

job = aiplatform.HyperparameterTuningJob(
    display_name="hp-tuning",
    custom_job=custom_job,
    metric_spec={"accuracy": "maximize"},
    parameter_spec={
        "learning_rate": aiplatform.hyperparameter_tuning.DoubleParameterSpec(
            min=1e-4, max=1e-1, scale="log"
        ),
        "batch_size": aiplatform.hyperparameter_tuning.DiscreteParameterSpec(
            values=[32, 64, 128, 256], scale="linear"
        ),
        "num_layers": aiplatform.hyperparameter_tuning.IntegerParameterSpec(
            min=2, max=8, scale="linear"
        ),
    },
    max_trial_count=30,
    parallel_trial_count=5,
)

job.run()
```

In your training script, report metrics back to the tuner:
```python
from hypertune import HyperTune

ht = HyperTune()
ht.report_hyperparameter_tuning_metric(
    hyperparameter_metric_tag="accuracy",
    metric_value=val_accuracy,
    global_step=epoch
)
```

📖 [Vertex AI hyperparameter tuning](https://cloud.google.com/vertex-ai/docs/training/hyperparameter-tuning-overview)

---

### Fine-Tuning Foundational Models

#### When to Fine-Tune (vs. Prompt Engineering)
| Situation | Recommendation |
|---|---|
| Model consistently uses wrong tone/style | Fine-tune |
| Domain-specific terminology not in training data | Fine-tune |
| Need faster/cheaper inference for specific task | Fine-tune (smaller fine-tuned model) |
| Task is general and few-shot prompting works | Prompt engineer |
| Low data volume (<100 examples) | RAG or prompt engineering |
| High data volume (1000+ labeled examples) | Fine-tune |

#### Supervised Fine-Tuning of Gemini on Vertex AI
```python
from vertexai.preview.tuning import sft

sft_tuning_job = sft.train(
    source_model="gemini-1.5-pro-002",
    train_dataset="gs://my-bucket/training_data.jsonl",
    validation_dataset="gs://my-bucket/validation_data.jsonl",
    epochs=3,
    adapter_size=4,
    learning_rate_multiplier=1.0,
    tuned_model_display_name="my-fine-tuned-gemini"
)

sft_tuning_job.wait()
tuned_model = sft_tuning_job.tuned_model_endpoint_name
```

Training data format (JSONL):
```json
{"messages": [{"role": "user", "content": "Classify this review: 'Great product!'"},
              {"role": "model", "content": "positive"}]}
{"messages": [{"role": "user", "content": "Classify this review: 'Terrible quality'"},
              {"role": "model", "content": "negative"}]}
```

#### LoRA / PEFT (Parameter-Efficient Fine-Tuning)
**The core problem LoRA solves:** Full fine-tuning updates all model weights (billions of params), requiring massive compute and risking catastrophic forgetting. LoRA instead learns a tiny set of *adapter* weights — typically <1% of the full model — and freezes everything else.

**How LoRA works (mechanically):**
For a weight matrix W of shape (d_in × d_out):
- LoRA adds two small matrices: **A** (d_in × r) and **B** (r × d_out)
- Effective weight at inference = W + A × B
- Only A and B are trained; W stays frozen
- `rank r` = the bottleneck dimension (`adapter_size` in Vertex AI)

Total new params per layer = 2 × r × d — versus d² for full fine-tune.

**Rank selection guide (`adapter_size`):**
| Rank | Params added | When to use |
|---|---|---|
| 1–4 | Minimal | Simple style/tone/format adaptation |
| 8–16 | Standard | Most task-specific fine-tuning (classification, QA) |
| 32–64 | Higher | Complex multi-task or domain shift; rarely needed |

> Rule of thumb: start with rank 4–8. Only increase if validation loss plateaus.

**LoRA vs. full fine-tuning vs. prompting:**
| | Prompting | LoRA/PEFT | Full fine-tuning |
|---|---|---|---|
| Params updated | 0 | <1% | 100% |
| Training cost | None | Low | Very high |
| Data needed | 0 (few-shot in prompt) | 100–1000+ examples | 10k–100k+ examples |
| Catastrophic forgetting | None | Minimal | Risk is real |
| Latency overhead | Zero | Zero (weights merged) | Zero |
| When to choose | Task works via prompting | Task-specific behavior, format | Core capability change |

**On Vertex AI — SFT with LoRA:**
```python
from vertexai.preview.tuning import sft

# adapter_size IS the LoRA rank
sft_tuning_job = sft.train(
    source_model="gemini-1.5-pro-002",
    train_dataset="gs://my-bucket/train.jsonl",
    validation_dataset="gs://my-bucket/val.jsonl",
    epochs=3,
    adapter_size=4,              # LoRA rank — start here
    learning_rate_multiplier=1.0,
    tuned_model_display_name="my-lora-model"
)
sft_tuning_job.wait()
```

> Vertex AI's SFT always uses LoRA under the hood — you are NOT doing full fine-tuning even if it is called "Supervised Fine-Tuning."

**Other PEFT variants (know for exams, not always available on Vertex):**
| Method | Mechanism | Notes |
|---|---|---|
| LoRA | Low-rank adapter matrices | Most common; merged at inference |
| Prefix tuning | Train soft tokens prepended to input | No weight merging needed |
| Prompt tuning | Train task-embedding only | Lightest of all; only works for large models |

**Exam traps for LoRA/PEFT:**
- `adapter_size` in Vertex SFT = **LoRA rank** (not a hidden layer size, not number of layers).
- "Cheapest way to specialize a foundation model for a new task while keeping base weights intact" → **LoRA/PEFT**.
- LoRA has **zero inference latency overhead** because adapter matrices can be merged back into W before deployment.
- If the question says "you only have 50 labeled examples" → LoRA/prompting, NOT full fine-tune.
- If the question says "the model needs to gain entirely new reasoning capabilities" → full fine-tune (LoRA won't add fundamentally new knowledge).
📖 [Gemini fine-tuning on Vertex AI](https://cloud.google.com/vertex-ai/generative-ai/docs/models/tune-models)

---

## 3.3 Choosing Appropriate Hardware for Training

### Evaluation of Compute and Accelerator Options
| Accelerator | Best For | Notes |
|---|---|---|
| **CPU** | Small models, data preprocessing, inference on tabular | Cheapest, no parallelism limits |
| **GPU (T4, A100, H100)** | Most DL training and inference | High memory bandwidth, CUDA ecosystem |
| **TPU v4/v5** | Large TensorFlow/JAX models, LLM training | Fastest for matrix ops, GCP-native |

#### CPU vs. GPU vs. TPU Decision
```
Small tabular model → CPU (n1-standard)
Medium DNN, PyTorch → GPU (T4 for dev, A100 for production training)
Large LLM training → Multi-GPU A100/H100 or TPU Pod
Large JAX/TF model → TPU (natively supported on GCP)
```

#### Machine Types on Vertex AI
```python
# GPU training job
job = aiplatform.CustomTrainingJob(...)
model = job.run(
    machine_type="a2-highgpu-1g",  # 1x A100 GPU
    accelerator_type="NVIDIA_TESLA_A100",
    accelerator_count=1
)

# TPU training job
model = job.run(
    machine_type="cloud-tpu",
    accelerator_type="TPU_V4_POD",
    accelerator_count=8
)
```

📖 [Vertex AI compute resources](https://cloud.google.com/vertex-ai/docs/training/configure-compute)

---

### Distributed Training Strategies

#### Data Parallelism
Each worker gets a copy of the model and a different subset of the data. Gradients are aggregated across workers.

```python
import tensorflow as tf

# Multi-GPU data parallelism with MirroredStrategy
strategy = tf.distribute.MirroredStrategy()  # uses all GPUs on a single machine

with strategy.scope():
    model = build_model()
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')

model.fit(dataset, epochs=10)
```

For multi-machine:
```python
# MultiWorkerMirroredStrategy for multiple machines
strategy = tf.distribute.MultiWorkerMirroredStrategy()
```

#### Model Parallelism
The model is split across devices (used when model is too large for one device):
```python
# PyTorch model parallelism
class ParallelModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.layer1 = nn.Linear(1000, 512).to('cuda:0')
        self.layer2 = nn.Linear(512, 10).to('cuda:1')  # on different GPU

    def forward(self, x):
        x = self.layer1(x.to('cuda:0'))
        return self.layer2(x.to('cuda:1'))
```

#### Pipeline Parallelism
Splits model into stages, each on a different device, with micro-batches flowing through stages.

#### TPU Data Parallelism
```python
# JAX pmap for TPU data parallelism
import jax
import jax.numpy as jnp

@functools.partial(jax.pmap, axis_name='batch')
def train_step(params, batch):
    grads = jax.grad(loss_fn)(params, batch)
    # Average gradients across all TPU cores
    grads = jax.lax.pmean(grads, axis_name='batch')
    return update_params(params, grads)

# Replicate params across 8 TPU cores
params = jax.device_put_replicated(params, jax.devices())
```

#### Strategy Selection Guide
| Scenario | Strategy |
|---|---|
| Model fits on 1 GPU, want faster training | `MirroredStrategy` (multi-GPU, 1 machine) |
| Model fits on 1 GPU, very large dataset | `MultiWorkerMirroredStrategy` (multi-machine) |
| Model too large for 1 GPU | Model parallelism or Pipeline parallelism |
| LLM training (100B+ params) | `TPU Pod` with pipeline + tensor parallelism |
| PyTorch multi-GPU | `torch.nn.parallel.DistributedDataParallel` |
📖 [Distributed training on Vertex AI](https://cloud.google.com/vertex-ai/docs/training/distributed-training)
📖 [TF distribute strategies](https://www.tensorflow.org/guide/distributed_training)

---

## Key Exam Tips for Section 3
- **Largest exam section (21%)** — know training infrastructure deeply
- **ARIMA Plus** = time-series in BigQuery ML, no custom code needed
- **Vizier** = Bayesian hyperparameter tuning on Vertex AI
- **MirroredStrategy** = data parallelism on a single multi-GPU machine
- **MultiWorkerMirroredStrategy** = scale across multiple machines
- **TPUs** are best for TensorFlow/JAX, not PyTorch natively
- **Fine-tuning** needs 1000+ quality examples; fewer → use RAG or prompting
- **LoRA / PEFT** = `adapter_size` in Vertex SFT = LoRA rank (1–4 simple, 8–16 standard task fine-tuning)
- LoRA trains <1% of params; base weights stay frozen; zero inference overhead (weights merged before deploy)
- "Cheapest way to specialize a foundation model" → LoRA; "only 50 examples" → prompting or LoRA; "entirely new capability" → full fine-tune
- When a training job fails: check Cloud Logging first, then examine gradient norms and data pipeline
- `HyperTune` library is required in your training script to report metrics back to Vizier
