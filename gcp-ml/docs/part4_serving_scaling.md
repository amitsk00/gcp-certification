# Section 4: Serving and Scaling Models (~20% of the Exam)

---

## 4.1 Serving Models

### Deploying Models for Batch and Online Inference

#### Online vs. Batch Inference
| Dimension | Online Inference | Batch Inference |
|---|---|---|
| Latency | Milliseconds | Minutes to hours |
| Trigger | Real-time request | Scheduled / on-demand |
| Use case | Fraud detection, recommendations | Nightly scoring, report generation |
| Cost model | Always-on endpoint | Pay per prediction job |
| GCP service | Vertex AI Endpoint | Vertex AI Batch Prediction |

#### Online Prediction with Vertex AI Endpoint
```python
from google.cloud import aiplatform

aiplatform.init(project="my-project", location="us-central1")

# Deploy a model to an endpoint
model = aiplatform.Model("projects/my-project/locations/us-central1/models/MODEL_ID")

endpoint = model.deploy(
    machine_type="n1-standard-4",
    min_replica_count=1,
    max_replica_count=5,       # auto-scaling
    accelerator_type="NVIDIA_TESLA_T4",
    accelerator_count=1,
    traffic_split={"0": 100},  # 100% to this model version
    display_name="my-endpoint"
)

# Predict
response = endpoint.predict(instances=[{"feature1": 1.0, "feature2": "category_A"}])
print(response.predictions)
```

#### Batch Prediction
```python
batch_prediction_job = model.batch_predict(
    job_display_name="batch-scoring",
    gcs_source="gs://my-bucket/batch_input/*.jsonl",
    gcs_destination_prefix="gs://my-bucket/batch_output/",
    machine_type="n1-standard-4",
    starting_replica_count=2,
    max_replica_count=10,
    sync=True
)
```

Input JSONL format:
```json
{"instances": [{"feature1": 1.0, "feature2": "A"}]}
{"instances": [{"feature1": 2.5, "feature2": "B"}]}
```

#### Cloud Run for Model Serving
Use Cloud Run when you need a custom serving container without Vertex AI's overhead:
```python
# Dockerfile
FROM python:3.11-slim
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
```

```python
# app.py (FastAPI serving)
from fastapi import FastAPI
import joblib, numpy as np

app = FastAPI()
model = joblib.load("model.pkl")

@app.post("/predict")
def predict(data: dict):
    features = np.array(data["instances"])
    predictions = model.predict(features).tolist()
    return {"predictions": predictions}
```

```bash
# Deploy to Cloud Run
gcloud run deploy my-model-service \
  --image gcr.io/my-project/my-model:v1 \
  --platform managed \
  --region us-central1 \
  --memory 2Gi
```

#### GKE for Model Serving
Use GKE when you need fine-grained Kubernetes control, custom autoscaling, or GPU serving at scale:
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: model-server
  template:
    spec:
      containers:
      - name: model-server
        image: gcr.io/my-project/model-server:v1
        resources:
          limits:
            nvidia.com/gpu: 1
        ports:
        - containerPort: 8080
```

📖 [Vertex AI online prediction](https://cloud.google.com/vertex-ai/docs/predictions/get-online-predictions)
📖 [Vertex AI batch prediction](https://cloud.google.com/vertex-ai/docs/predictions/get-batch-predictions)

---

### Packaging and Serving Models with Prebuilt and Custom Containers

#### Prebuilt Containers
Google provides optimized serving containers for common frameworks — no Dockerfile required.

| Framework | Prebuilt Container URI |
|---|---|
| TensorFlow 2.12 | `us-docker.pkg.dev/vertex-ai/prediction/tf2-cpu.2-12:latest` |
| TensorFlow GPU | `us-docker.pkg.dev/vertex-ai/prediction/tf2-gpu.2-12:latest` |
| PyTorch | `us-docker.pkg.dev/vertex-ai/prediction/pytorch-cpu.1-13:latest` |
| Scikit-learn | `us-docker.pkg.dev/vertex-ai/prediction/sklearn-cpu.1-0:latest` |
| XGBoost | `us-docker.pkg.dev/vertex-ai/prediction/xgboost-cpu.1-6:latest` |

#### Custom Container Serving
Required when: custom preprocessing, non-standard framework, special business logic.

```python
# predictor.py — implement the Predictor interface
from google.cloud.aiplatform.prediction.sklearn import SklearnPredictor
import joblib, numpy as np

class MyCustomPredictor(SklearnPredictor):
    def load(self, artifacts_uri: str):
        self.model = joblib.load(f"{artifacts_uri}/model.pkl")

    def preprocess(self, prediction_input):
        # Custom preprocessing
        instances = prediction_input["instances"]
        return np.array([[i["feature1"], i["feature2"]] for i in instances])

    def predict(self, instances):
        return self.model.predict(instances).tolist()

    def postprocess(self, prediction_results):
        return {"predictions": prediction_results}
```

```python
# Build and upload custom serving container
from google.cloud.aiplatform.prediction import LocalModel

local_model = LocalModel.build_cpr_model(
    src_dir=".",
    output_image_uri="gcr.io/my-project/my-predictor:v1",
    predictor=MyCustomPredictor,
    requirements_path="requirements.txt"
)
local_model.push_image()
```

📖 [Custom prediction routines](https://cloud.google.com/vertex-ai/docs/predictions/custom-prediction-routines)

#### Custom Prediction Routine (CPR) — Deep Dive
CPR is Vertex AI's mechanism to embed custom pre/postprocessing **inside the serving container** alongside your model artifact.

**The four methods you override (in order of execution):**
| Method | When called | What you put here |
|---|---|---|
| `load(artifacts_uri)` | Container start-up | Load model + scaler + any artifact from GCS |
| `preprocess(prediction_input)` | Every request | Parse request JSON, apply transforms, scale features |
| `predict(instances)` | Every request | Run model inference — usually just `self.model.predict()` |
| `postprocess(prediction_results)` | Every request | Format output, apply business rules, threshold |

**When to use CPR vs. prebuilt container:**
| Situation | Use |
|---|---|
| Pure sklearn/XGBoost/TF model, no custom logic | Prebuilt container |
| Need to apply a fitted scaler / encoder at serve time | CPR (`preprocess`) |
| Business rules on outputs (e.g., cap scores, map labels) | CPR (`postprocess`) |
| Non-standard framework not in prebuilt list | CPR with custom base image |
| Prevent training-serving skew via shared transform logic | CPR (embed the same Pipeline object used at train time) |

**Full working example with scaler:**
```python
# predictor.py
from google.cloud.aiplatform.prediction.sklearn import SklearnPredictor
import joblib, numpy as np

class ChurnPredictor(SklearnPredictor):
    def load(self, artifacts_uri: str):
        # load BOTH the model and the scaler that was fit at training time
        self.model  = joblib.load(f"{artifacts_uri}/model.pkl")
        self.scaler = joblib.load(f"{artifacts_uri}/scaler.pkl")

    def preprocess(self, prediction_input: dict):
        instances = prediction_input["instances"]  # list of dicts
        arr = np.array([[i["tenure"], i["monthly_charges"], i["num_products"]]
                        for i in instances])
        return self.scaler.transform(arr)           # same scaler as training → no skew

    def predict(self, instances):
        probs = self.model.predict_proba(instances)[:, 1]
        return probs.tolist()

    def postprocess(self, prediction_results):
        # Apply a business-rule threshold and label
        return {
            "predictions": [
                {"churn_probability": p, "label": "HIGH" if p > 0.7 else "LOW"}
                for p in prediction_results
            ]
        }
```

```python
# build_and_deploy.py
from google.cloud.aiplatform.prediction import LocalModel
from google.cloud import aiplatform

local_model = LocalModel.build_cpr_model(
    src_dir=".",                                        # directory containing predictor.py
    output_image_uri="gcr.io/my-project/churn-predictor:v1",
    predictor=ChurnPredictor,
    requirements_path="requirements.txt"
)
local_model.push_image()

# Upload to Vertex AI Model Registry
model = aiplatform.Model.upload(
    display_name="churn-cpr-model",
    artifact_uri="gs://my-bucket/model-artifacts/",    # contains model.pkl + scaler.pkl
    local_model=local_model
)

endpoint = model.deploy(machine_type="n1-standard-4")
```

**Exam traps for CPR:**
- "You need to apply a StandardScaler that was fit on training data at inference time" → CPR `preprocess()`, NOT a separate preprocessing step — doing it separately risks training-serving skew.
- "Your model needs to return business-readable labels instead of raw class indices" → CPR `postprocess()`.
- `build_cpr_model()` is **not** a Docker build command — it wraps the predictor class using the Prediction SDK's HTTP server framework.
- If you're asked which approach avoids training-serving skew: **CPR** (shared transform code in the container) or **Feature Store** (shared computed features).

---

### Organizing and Versioning Models in Model Registry
**Model Registry** is the central repository for all trained models on Vertex AI.

```python
from google.cloud import aiplatform

# Upload model to registry
model = aiplatform.Model.upload(
    display_name="churn-classifier",
    artifact_uri="gs://my-bucket/model/",
    serving_container_image_uri="us-docker.pkg.dev/vertex-ai/prediction/sklearn-cpu.1-0:latest",
    description="XGBoost churn classifier v2",
    labels={"team": "risk", "env": "prod"}
)

# List all versions
versions = aiplatform.Model.list(filter='display_name="churn-classifier"')
for v in versions:
    print(v.version_id, v.version_create_time, v.description)

# Set default version
model.manage_labels(add_labels={"default": "true"})
```

**Best practices:**
- Use labels for metadata (`env`, `team`, `model_type`)
- Keep model artifacts in Cloud Storage, linked by URI
- Use version aliases (`champion`, `challenger`) for traffic management
📖 [Vertex AI Model Registry](https://cloud.google.com/vertex-ai/docs/model-registry/introduction)

---

### Implementing Model Rollout Strategies

#### A/B Testing
Split live traffic between two model versions to compare performance:
```python
# Deploy two models to same endpoint with traffic split
endpoint = aiplatform.Endpoint.create(display_name="ab-test-endpoint")

# Deploy champion (v1) with 90% traffic
endpoint.deploy(
    model=model_v1,
    machine_type="n1-standard-4",
    traffic_split={"model_v1_id": 90, "model_v2_id": 10}
)

# Deploy challenger (v2) with 10% traffic
endpoint.deploy(
    model=model_v2,
    machine_type="n1-standard-4",
    traffic_split={"model_v1_id": 90, "model_v2_id": 10}
)

# After sufficient data, promote v2 if it wins
endpoint.update(traffic_split={"model_v2_id": 100})
endpoint.undeploy(deployed_model_id="model_v1_id")
```

#### Canary Deployment
```python
# Start with 5% to new model, monitor, then ramp
stages = [5, 20, 50, 100]
for pct in stages:
    endpoint.update(traffic_split={
        "new_model_id": pct,
        "old_model_id": 100 - pct
    })
    # Monitor metrics for 30 minutes before next stage
    time.sleep(1800)
    metrics = check_error_rate(endpoint)
    if metrics["error_rate"] > threshold:
        rollback(endpoint)
        break
```

#### Blue/Green Deployment
```python
# "Blue" = current prod endpoint
# "Green" = new version endpoint

# 1. Deploy new version to "green" endpoint
green_endpoint = model_v2.deploy(display_name="green-endpoint", ...)

# 2. Run smoke tests against green
run_integration_tests(green_endpoint)

# 3. Switch load balancer / API gateway to green
update_dns_or_gateway(target=green_endpoint)

# 4. Keep blue live as fallback for quick rollback
# 5. Decommission blue after confidence period
blue_endpoint.undeploy_all()
```

📖 [Traffic split on Vertex AI endpoints](https://cloud.google.com/vertex-ai/docs/predictions/deploy-model-api#deploy-model-traffic-split)

---

### Inference Preprocessing and Postprocessing
Keep preprocessing logic consistent between training and serving. Options:
1. **Custom container**: embed preprocessing in the serving container
2. **Vertex AI Feature Store**: fetch pre-computed features at serving time
3. **Dataflow + Pub/Sub**: stream preprocessing before hitting the model
4. **TFX Serving**: SavedModel includes tf.Transform preprocessing graph

```python
# TensorFlow: include preprocessing in SavedModel
class ServingModel(tf.Module):
    def __init__(self, model, vocab_table):
        self.model = model
        self.vocab_table = vocab_table

    @tf.function(input_signature=[tf.TensorSpec(shape=[None], dtype=tf.string)])
    def serve(self, raw_text):
        # Preprocessing embedded in the model graph
        tokens = tf.strings.lower(raw_text)
        ids = self.vocab_table.lookup(tokens)
        padded = tf.keras.preprocessing.sequence.pad_sequences([ids.numpy()], maxlen=128)
        return self.model(padded)

tf.saved_model.save(ServingModel(model, vocab), "gs://bucket/model/")
```

---

## 4.2 Scaling Online Model Serving

### Managing and Serving Features Using Feature Store
At serving time, retrieve features from Feature Store for low-latency lookups:
```python
from google.cloud import aiplatform

fv = aiplatform.FeatureView("projects/my-project/locations/us-central1/featureOnlineStores/my-store/featureViews/user-fv")

# Single entity lookup at serving time
result = fv.read(key=["user_123"])
features = result.to_dict()

# Use features in prediction
response = endpoint.predict(instances=[features])
```

**Feature Store latency**: ~10ms for online serving (p99). Pre-compute features offline, load into online store, serve at request time.

---

### Deploying Models to Public and Private Endpoints

#### Public Endpoint
Default — accessible over the internet with IAM authentication.

```python
endpoint = model.deploy(
    machine_type="n1-standard-4",
    # No VPC config = public endpoint
)
# Access with Bearer token (IAM)
```

#### Private Endpoint
Accessible only within your VPC — required for sensitive data or compliance.

```python
endpoint = aiplatform.PrivateEndpoint.create(
    display_name="private-endpoint",
    network="projects/my-project/global/networks/my-vpc"
)

model.deploy(
    endpoint=endpoint,
    machine_type="n1-standard-4"
)

# Access via Private Service Connect or VPC peering
```

**When to use private endpoints:**
- Regulated industries (finance, healthcare)
- Models processing PII
- Need to enforce network policies (VPC Service Controls)
📖 [Private endpoints](https://cloud.google.com/vertex-ai/docs/predictions/using-private-endpoints)

---

### Choosing Appropriate Hardware for Serving
| Workload | Hardware | Reasoning |
|---|---|---|
| Small tabular model, high QPS | CPU (n1-standard) | Cost-effective, parallelism via replicas |
| Large DNN, latency-sensitive | GPU T4 | GPU acceleration without A100 cost |
| LLM inference, high throughput | GPU A100/H100 | Large model fits in GPU memory |
| Edge inference (IoT, mobile) | TPU Edge / ARM | Low power, on-device |
| Batch scoring, cost priority | CPU with many replicas | No idle GPU cost |

---

### Scaling the Serving Backend

#### Auto-scaling on Vertex AI Endpoints
```python
endpoint = model.deploy(
    machine_type="n1-standard-4",
    min_replica_count=1,    # always at least 1 replica
    max_replica_count=10,   # scale up to 10 under load
    accelerator_type="NVIDIA_TESLA_T4",
    accelerator_count=1
)
```

Vertex AI auto-scales based on CPU/GPU utilization and request queue depth.

#### Gemini Enterprise Agent Platform Inference
For foundation model serving, use Vertex AI Inference which provides:
- Managed LLM serving with auto-scaling
- Dynamic batching (groups concurrent requests)
- Speculative decoding (faster LLM inference)
- Quantization support (INT8/INT4 for smaller memory footprint)

#### Containerized Serving with GKE + HPA
```yaml
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: model-server-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: model-server
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

### Tuning ML Models for Training and Serving in Production

#### Training-Side Optimizations
```python
# Mixed precision training (faster, less memory)
tf.keras.mixed_precision.set_global_policy('mixed_float16')

# Gradient accumulation (simulate large batch with small memory)
accumulation_steps = 4
for step, (x, y) in enumerate(dataset):
    with tf.GradientTape() as tape:
        loss = model(x, training=True)
    grads = tape.gradient(loss, model.trainable_variables)
    if (step + 1) % accumulation_steps == 0:
        optimizer.apply_gradients(zip(accumulated_grads, model.trainable_variables))
        accumulated_grads = [tf.zeros_like(g) for g in grads]
```

#### Serving-Side Optimizations
| Technique | Description | Speedup |
|---|---|---|
| Quantization (INT8) | Reduce weight precision | 2-4x faster, 75% smaller |
| Pruning | Remove near-zero weights | Model-dependent |
| Knowledge distillation | Train small model to mimic large | Smaller model, similar accuracy |
| Model compilation (TensorRT, XLA) | Fuse ops, optimize for hardware | 2-5x faster on GPU |
| Dynamic batching | Group concurrent requests | Higher throughput |

**Quantization bit-width trade-offs** — all reduce memory vs FP32 (32-bit), but differ in how aggressively they trade accuracy for size:
| Bit-width | Memory vs FP32 | Accuracy Impact | Pros | Cons | Best For |
|---|---|---|---|---|---|
| **INT8** | 4x smaller | Minimal (~0.5–1% drop) | Broadly supported (NVIDIA, TPU, CPU VNNI); safe default; fast calibration | Slight loss on highly sensitive tasks | Production NLP/vision; safest first step for any model |
| **INT4** | 8x smaller | Moderate (1–5% drop) | Fits larger LLMs on smaller GPUs; significant latency gains on supported hardware | Needs careful post-training calibration or QAT; patchy hardware support | LLM inference on memory-constrained GPUs (e.g., LLaMA, Mistral on a single A100/H100) |
| **INT2** | 16x smaller | High (often 5–15%+ drop) | Maximum compression; enables very large models in tiny memory budgets | Major accuracy degradation; hardware support is rare; requires QAT to be usable at all | Research/experimental only; extreme edge where memory dominates over accuracy |

> **Rule of thumb:** start with INT8 for production. Move to INT4 only if the model doesn't fit memory at INT8. Avoid INT2 outside of research unless you've validated accuracy is acceptable for your task.

```python
# TF SavedModel → TensorRT optimized
import tensorflow as tf
from tensorflow.python.compiler.tensorrt import trt_convert as trt

converter = trt.TrtGraphConverterV2(
    input_saved_model_dir="gs://bucket/model/",
    precision_mode=trt.TrtPrecisionMode.INT8
)
converter.convert()
converter.save("gs://bucket/model-trt/")
```

📖 [Model optimization](https://cloud.google.com/vertex-ai/docs/predictions/optimizing-predictions)

---

## Key Exam Tips for Section 4
- **Online** = real-time, always-on endpoint; **Batch** = scheduled, cost-efficient for large volumes
- **Cloud Run** = stateless, serverless; great for custom serving without Vertex AI lock-in
- **GKE** = full Kubernetes control, custom autoscaling, GPU node pools
- **Model Registry** = version tracking and management; use labels for metadata
- **A/B test** = compare two live models with traffic split; **canary** = gradual rollout
- **Private endpoint** = required when VPC Service Controls or compliance is needed
- **Feature Store** for serving = sub-10ms feature lookup, avoids training-serving skew
- **CPR (Custom Prediction Routine)** = 4 override methods: `load` → `preprocess` → `predict` → `postprocess`; use when you need scaler/transform embedded in serving container
- "Apply fitted scaler at serve time" → CPR `preprocess()`; "format output with business rules" → CPR `postprocess()`
- `build_cpr_model()` wraps your predictor class into a Vertex-compatible serving image — not raw Docker
- For LLM serving, **speculative decoding** and **dynamic batching** are key latency/throughput levers
- Auto-scaling: set `min_replica_count > 0` to avoid cold-start latency
- **Quantization** = fastest path to smaller, faster serving model; INT8 is most common
