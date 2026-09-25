Git repo

```bash
!git clone https://github.com/GoogleCloudPlatform/training-data-analyst
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
```

---

# PMLE Exam High-Yield Study Guide

---

## 1. Data Preprocessing & Ingestion

### TF-Transform (TFT) with Apache Beam / Dataflow
* **Core Problem Solved:** Eliminates **Training-Serving Skew**.
* **How it works:** Preprocessing transformations (normalization, vocabulary generation, bucketing) run on Dataflow during training and produce a **preprocessing graph**.
* **Exam Key:** This preprocessing graph is exported and embedded **directly inside the serving model** (as a TensorFlow SavedModel / Keras layer). Online serving runs the exact same preprocessing logic without external preprocessing scripts.

### TFRecord Format
* **What it is:** TensorFlow's native, sharded, record-oriented binary format stored in Cloud Storage.
* **Exam Trigger:** "Large deep learning / computer vision dataset with millions of small images causing slow I/O and GPU starvation."
* **Solution:** Serialize images and labels into sharded `TFRecord` files in GCS and read with `tf.data.TFRecordDataset` for sequential streaming throughput.

### Cloud DLP (Sensitive Data Protection)
* **Exam Rule:** Mask or pseudonymize PII before data ingestion/training.
* **Exam Trap:** Retain non-sensitive behavioral flags (e.g. `is_returning_customer`, `visit_frequency`) untouched—do NOT blanket-mask non-PII numerical/categorical features needed for model accuracy.

### Data Splitting Strategies
* **Time-Based Split:** Mandatory when evaluating whether a model trained on historical data generalizes to future observations (e.g. financial forecasting, demand prediction). Prevents lookahead/future data leakage.
* **Group / Entity Split:** Split by entities (e.g. customer ID, store ID, hospital ID) when the model needs to generalize to **completely unseen entities**.

---

## 2. Feature Engineering & Feature Store

### Vertex AI Feature Store
* **Online Serving:** Low-latency (<10ms) lookup backed by Bigtable; fetches feature values by Entity ID for real-time predictions.
* **Offline Serving:** High-throughput batch export backed by BigQuery; provides **point-in-time lookup ("Time Travel")** to avoid data leakage by joining historical entity timestamps with features valid at that exact moment.

### High-Cardinality vs. Low-Cardinality Features
* **Low-Cardinality (<50–100 unique values):** One-Hot Encoding (`tf.feature_column.indicator_column` or `OneHotEncoder`).
* **High-Cardinality (IDs, search queries, postal codes, product tags):** Embeddings (`tf.keras.layers.Embedding` or `embedding_column`) to map sparse discrete values into low-dimensional dense vectors.

### Class Imbalance
* **Best Strategy:** **Downsample** the majority class and **upweight** the downsampled examples (calibrates expected loss so the model outputs true real-world probabilities).
* **Evaluation:** Never rely on accuracy; use **PR-AUC (Precision-Recall AUC)** when positive class is extremely rare (e.g., fraud, defect detection).

---

## 3. Distributed Training & Hardware Selection

### TensorFlow Distribution Strategies
* **`ParameterServerStrategy`:**
  * **Architecture:** Dedicated **Parameter Servers** (store and update variables) + **Workers** (compute gradients).
  * **Exam Cue:** Model weights **exceed single GPU/worker memory** (e.g., massive embedding tables in Recommendation Systems with billions of items), or asynchronous multi-machine CPU clusters.
* **`MirroredStrategy`:** Single-node, multi-GPU synchronous all-reduce. Full model must fit in one GPU.
* **`MultiWorkerMirroredStrategy`:** Multi-node, multi-GPU synchronous all-reduce. Requires proportionally scaling up global batch size.
* **`TPUStrategy`:** Synchronous training on Cloud TPU Pods. Requires static shapes and operations supported by XLA compiler (no custom C++ CUDA ops).

### Hardware Platform Selection (Exam Decision Rules)
* **Compute-Optimized CPU (c2 / n2):** Scikit-learn, LightGBM, XGBoost CPU, ARIMA, low-QPS inference (<50ms).
* **GPU (NVIDIA A100 / L4 / T4):** Custom C++ CUDA kernels, dynamic tensor shapes, PyTorch, high-throughput vision inference.
* **Cloud TPU Pod (v4 / v5e):** Large Transformer pretraining (LLMs), extreme batch sizes (e.g., 2048+), bfloat16 mixed precision.

### Vertex AI Vizier & `ConditionalParameterSpec`
* **What it is:** Managed black-box Bayesian hyperparameter optimization.
* **`ConditionalParameterSpec`:** Defines hyperparameters that are **only evaluated conditional upon the value of a parent parameter** (e.g., tune `beta_1` only if `optimizer == "adam"`; tune `momentum` only if `optimizer == "sgd"`). Prunes invalid trials and saves massive compute costs.

---

## 4. Dataflow for ML Inference (Batch & Streaming)

### Apache Beam `RunInference` PTransform
* **What it is:** The official, optimized transform for running local model inference inside batch or streaming Dataflow pipelines.
* **Supported Frameworks:** PyTorch, TensorFlow, Scikit-learn, ONNX, TensorRT.
* **Key Advantages (Exam Highlights):**
  * **Memory Sharing:** Loads model weights **once per worker process** (shared across threads), preventing Out-Of-Memory (OOM) errors on multi-core workers.
  * **Dynamic Batching:** Automatically micro-batches incoming streaming elements to maximize GPU/CPU utilization without exceeding latency SLAs.
  * **Dynamic Model Updates (`WatchFilePattern`):** Watches a Cloud Storage path pattern (e.g., `gs://bucket/models/*.pt`). When a new model checkpoint appears, workers **automatically hot-swap the model** without restarting or redeploying the Dataflow pipeline.
  * **Multi-Model Pipelines:** Allows chaining multiple models in a single DAG (e.g., Text Preprocessing -> Embedding Model -> Classifier).

### In-Pipeline `RunInference` vs. Remote Vertex AI Endpoint Calls
* **Use In-Pipeline `RunInference` (Local Model):** When processing high-throughput batch or streaming data. Zero network RPC latency, no API quota throttling, cost-effective worker execution.
* **Use Remote Endpoint (RPC Call):** Only when the model requires a specialized, heavy hardware environment (e.g. massive LLM on multi-GPU) that cannot run on standard Dataflow workers; requires client-side rate limiting and retries.

---

## 5. Gemini / Vertex AI Pipeline Components (All-in-One Ops Directory)
*Pre-built components from `google_cloud_pipeline_components` (GCPC) and KFP DSL with 1-line descriptions for PMLE:*

### Data Ingestion & Preprocessing
* `BigQueryQueryJobOp`: Executes a BigQuery SQL query to extract, transform, or prepare datasets.
* `BigQueryCreateJobOp`: Runs arbitrary BigQuery jobs (queries, loads, copies, extracts) within the pipeline.
* `BigQueryExtractJobOp`: Exports BigQuery table data directly to Cloud Storage as CSV, Parquet, or Avro.
* `DataflowPythonJobOp` / `DataflowJobOp`: Launches an Apache Beam pipeline on Dataflow for distributed batch or stream preprocessing.
* `DataflowFlexTemplateJobOp`: Runs a packaged Dataflow Flex Template from Cloud Storage or Artifact Registry.
* `DataprocPySparkBatchOp`: Submits a serverless PySpark batch job to Dataproc for massive distributed Spark transformations.

### Feature Store Operations
* `ImportFeatureValuesOp`: Ingests batch feature updates from BigQuery or GCS into Vertex AI Feature Store.
* `BatchReadFeatureValuesOp`: Performs point-in-time offline feature lookups ("Time Travel") to construct training data without data leakage.

### Dataset Management
* `TabularDatasetCreateOp`: Creates a Vertex AI managed Tabular Dataset linked to GCS or BigQuery.
* `TimeSeriesDatasetCreateOp`: Creates a Vertex AI managed Time Series Dataset for forecasting workflows.
* `ImageDatasetCreateOp`: Creates a Vertex AI managed Image Dataset for classification or object detection.
* `TextDatasetCreateOp`: Creates a Vertex AI managed Text Dataset for NLP classification and entity extraction.
* `DatasetImportDataOp`: Imports new raw data or ground-truth annotations into an existing Vertex AI Dataset.
* `DatasetExportDataOp`: Exports a Vertex AI Dataset and metadata to Cloud Storage.

### Training & Hyperparameter Tuning
* `CustomTrainingJobOp`: Runs a custom training script on Vertex AI using Google pre-built framework containers.
* `CustomContainerTrainingJobOp`: Executes custom training using a fully custom user-built Docker image.
* `CustomPythonPackageTrainingJobOp`: Installs and runs a custom Python source distribution package for training.
* `HyperparameterTuningJobRunOp`: Runs Bayesian hyperparameter tuning trials via Vertex AI Vizier.
* `AutoMLTabularTrainingJobRunOp`: Launches an AutoML training job for tabular classification or regression.
* `AutoMLImageTrainingJobRunOp`: Launches an AutoML training job for image classification or object detection.

### Model Evaluation & Explainability
* `ModelEvaluationOp`: Runs an evaluation pipeline against test data to produce metrics, confusion matrices, and ROC curves.
* `ModelEvaluationClassificationOp`: Computes classification-specific metrics (ROC-AUC, PR-AUC, F1, log-loss).
* `ModelEvaluationRegressionOp`: Computes regression metrics (RMSE, MAE, R-squared) against test ground truth.
* `ModelEvaluationSliceOp`: Computes evaluation metrics across user-specified feature slices to detect fairness issues and bias.
* `ModelEvaluationFeatureAttributionOp`: Computes global and local feature attributions using Vertex Explainable AI (Shapley / Integrated Gradients).

### Model Monitoring & Bias Detection
* `ModelMonitoringJobOp`: Schedules continuous monitoring on an endpoint to track feature skew and drift against baseline data.
* `DetectModelDataDriftOp`: Calculates statistical distance (Jensen-Shannon divergence) between production serving features and baseline features.
* `DetectModelBiasOp`: Audits model prediction parity across protected demographic attributes for responsible AI compliance.

### Model Registry & Deployment
* `ModelUploadOp`: Registers trained model artifacts into Model Registry (pass `parent_model` parameter for versioning).
* `ModelGetOp`: Fetches an existing registered model artifact reference by resource name.
* `EndpointCreateOp`: Provisions a new Vertex AI Endpoint for low-latency online serving.
* `ModelDeployOp`: Deploys a registered model to an Endpoint with autoscaling, machine type, and `traffic_split` percentages.
* `ModelBatchPredictOp`: Executes serverless, asynchronous batch predictions on a dataset in GCS or BigQuery without an active endpoint.

### Pipeline Control Flow & Notifications (KFP DSL)
* `dsl.Condition`: Executes downstream tasks conditionally based on step output (e.g., only deploy if `accuracy > 0.85`).
* `dsl.ParallelFor`: Executes steps in parallel across dynamic input loops (e.g., training separate models per country/store).
* `dsl.ExitHandler`: Guarantees execution of cleanup or alerting steps regardless of whether the pipeline succeeded or failed.
* `dsl.importer`: Ingests an existing external artifact (e.g. pre-existing GCS model weights) into Vertex MLMD lineage tracking.
* `VertexNotificationEmailOp`: Sends an automated email notification to stakeholders upon pipeline success or failure.

---

## 6. Model Evaluation & Validation

### AutoSxS (Automatic Side-by-Side)
* **What it is:** Pairwise model-based evaluation for LLMs running on Vertex AI.
* **How it works:** Uses a powerful autorater model to compare responses between two LLMs based on predefined criteria, task instructions, or ground truth.

### Evaluation Metrics by Business Objective
* **High Precision:** Critical when False Positives are expensive (e.g., spam filters, automated account bans).
* **High Recall:** Critical when False Negatives are catastrophic (e.g., cancer detection, factory defect detection).
* **AuPRC (Area under Precision-Recall Curve):** Primary metric for imbalanced classification; focuses specifically on the minority positive class.
* **AuROC:** Measures general ranking ability across all classification thresholds; misleading on heavy class imbalance.

### Sliced Evaluation (TFMA - TensorFlow Model Analysis)
* Evaluates metrics across demographic or business slices (e.g., country, age group, device type) to uncover bias or regressions hidden by global aggregated metrics.

---

## 7. Model Explainability (Explainable AI / XAI)

### Feature Attribution Methods
* **Integrated Gradients:**
  * Computes path integrals along gradients from a baseline to the input.
  * **Best For:** Differentiable neural networks on structured/tabular data, text, and **artificial/industrial images** (manufacturing defect lines, laboratory diagnostics).
* **XRAI (eXplainable Region-based AI):**
  * Segments images into super-pixels/regions and attributes importance to whole visual regions.
  * **Best For:** **Natural images** (identifying animals, everyday consumer objects).
* **Sampled Shapley:**
  * Approximates Shapley values from cooperative game theory.
  * **Best For:** Tree-based models (XGBoost, Random Forest, Scikit-learn) and tabular data.

### Concept-Based Explainability
* **TCAV (Testing with Concept Activation Vectors):** Quantifies whether a human-understandable abstract concept (e.g., "stripes", "texture", "gender") was influential in the model's decision.
* **ACE (Automatic Concept-based Explanations):** Automatically clusters image super-pixels to discover concepts without manual human tagging.

---

## 8. Model Serving, Deployment & BigQuery ML

### Vertex AI Endpoints
* **Online Serving:** Low-latency predictions with autoscaling, private VPC-SC endpoints, and **traffic splitting** across multiple model versions (canary / blue-green deployments).
* **Custom Prediction Routines (CPR):**
  * Provide custom Python code for pre/post-processing around a model (e.g. scikit-learn pipeline) without maintaining a full custom Docker web server from scratch.

### BigQuery ML: `EXPORT MODEL` vs. Remote Models
* **`EXPORT MODEL` (to GCS):**
  * Exports trained BQML models (TensorFlow SavedModel, XGBoost) to a **Cloud Storage bucket**.
  * **Use Case:** Low-latency (<20ms) real-time online serving on **Vertex AI Endpoints** or mobile/IoT deployment with TF Lite.
* **Remote Models (`REMOTE WITH CONNECTION`):**
  * Creates a model pointer in BigQuery that points to an external Vertex AI Endpoint or Cloud AI foundation model (Gemini, text-embedding, Cloud Vision) via a **Cloud Resource Connection**.
  * **Use Case:** Run batch predictions, text generation, or embeddings directly in SQL over massive datasets **without exporting data out of BigQuery** or managing batch Python compute.

### Time Series Forecasting with `ARIMA_PLUS`
* Fully automated time series algorithm in BQML.
* Automatically handles **multiple seasonalities** (daily, weekly, yearly), **holiday effects**, **outliers**, and **missing value imputation**.
* Uses `TIME_SERIES_ID_COL` to forecast millions of separate series in parallel in a single query.

---

## 9. MLOps Architecture Comparison & Governance

### Comparison Matrix

| Tool / Service | Core Function | PMLE Exam Cue / Best For |
|---|---|---|
| **Vertex AI Pipelines** | Serverless orchestration (KFP / TFX) | Reproducible, scheduled, automated training-eval-deploy workflows with **step caching**. |
| **Vertex AI Experiments** | Run tracking & comparison | Logging parameters, metrics (ROC, AUC, loss curves), and artifacts during iterative modeling. |
| **User-Managed Workbench** | Compute Engine VM with JupyterLab | Full root/sudo control, custom Docker images, private VPC-SC, GPU driver customization. |
| **Colab Enterprise / Managed Workbench** | Serverless notebook environment | Fast start, Google Workspace IAM sharing, real-time team collaboration, Gemini code assist. |
| **Vertex ML Metadata (MLMD)** | Artifact & Execution Lineage store | Governance, auditing, tracking which exact dataset/commit generated which model version. |

### Model Governance & Monitoring
* **Vertex AI Model Registry & `parentModel`:**
  * `parentModel` parameter links an uploaded model as a new version (`v2`, `v3`) under an existing model resource.
  * Manages version aliases (`default`, `prod`, `challenger`) and tracks evaluation metrics over time.
* **Vertex ML Metadata (MLMD):**
  * Automatic tracking of artifacts (datasets, models, metrics) and executions (pipeline tasks, training jobs).
  * Enables compliance auditing, full lineage tracking, and reproducibility.
* **Model Monitoring (Skew vs. Drift):**
  * **Training-Serving Skew:** Discrepancy between the training baseline dataset distribution and incoming production request distribution.
  * **Prediction / Feature Drift:** Statistical distribution shift in live serving features over time (detected using Jensen-Shannon divergence or L-infinity distance against baseline).
