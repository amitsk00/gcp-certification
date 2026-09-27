# Exam papers and wrong answers

## correct answers

* Scikit-learn Execution Model: Standard scikit-learn algorithms are CPU-bound and designed for single-node execution. They do not natively support distributed multi-node training or GPU/TPU acceleration out of the box.

* RunInference allows an Apache Beam pipeline running on Dataflow to perform ML inference directly as part of batch or streaming processing. WatchFilePattern is specifically designed for automatic model refresh

* scikit-learn relies heavily on NumPy and SciPy, and many computationally expensive operations ultimately execute through optimized native numerical implementations rather than interpreted Python code. NumPy and SciPy can invoke multithreaded BLAS and LAPACK implementations, while scikit-learn itself can also use joblib and OpenMP for supported operations. Using vectorized NumPy and SciPy functionality instead of Python-level loops therefore allows the application to benefit from optimized compiled numerical routines and CPU parallelism with minimal changes to the model itself.

* Gemini Enterprise Agent Platform Pipelines can determine whether a pipeline task has a matching previous execution based on factors such as its component specification and inputs. When a matching execution is available in the pipeline metadata, the outputs from that previous execution can be reused and the task can be skipped.

* when a newly developed deep learning model shows almost no reduction in either training loss or validation loss, the first priority is to determine whether the model and training pipeline are fundamentally capable of learning

* Agent Platform Vizier is a managed black-box optimization service and can be used for optimization problems, including machine learning hyperparameters. However, directly integrating a custom training workflow with Vizier requires the application to manage more of the study and trial interaction itself.

* Data split
    - time based split - when the goal is to evaluate whether a model trained on historical information performs well on later information
    - manual split - finding values for totally new feature (new store or so)

*  Gemini Enterprise Agent Platform supports multiple models or model versions on the same public endpoint and supports traffic splitting among deployed models

* Managed Lustre
    - Native, POSIX-compliant parallel file system designed for HPC and large AI clusters
    - Multi-terabytes per second (TB/s) aggregated throughput
    - Sub-millisecond read/write latency; handles high-concurrency metadata operations with zero jitter.

* for standard numerical and categorical STRING columns with the "least preprocessing effort", relying on BigQuery ML's built-in automatic preprocessing requires zero extra lines of feature transformation code

* TPU VMs as appropriate for SSH command execution and debugging

* `federated learning` is specifically designed for machine learning over decentralized data. A shared model can be distributed to participating clients, training computations can occur against data retained locally by those clients, and model updates can then contribute to improving the shared model without requiring the original training records to be collected into a central repository

* `custom inference routines` are specifically designed for situations where a custom-trained model requires preprocessing or postprocessing but the team wants to avoid writing and maintaining a complete custom serving stack. 
    - With a custom inference routine, the developer implements the required Python prediction logic, including preprocessing before the scikit-learn model is invoked

* even if we have to mask using DLP, if we need to retain some value and fields are not sensitive, like is_returning_customer, we can leave it as it is, no masking or anything

* PCA (Principal Component Analysis)
    - PCA relies on calculating variance and a covariance matrix across continuous, **linearly correlated numerical variables**
    - not applicable when binary or bucketed or 2D/spatial features
    - PCA is not a de-identification technique

*  Pre Built Vision models
    - Vertex AI Vision Occupancy Analytics    --> "Video stream" + "Count people in a zone / crossing a line"  
    - Vertex AI Vision Person/vehicle detector --> detect and count people or vehicles

* word embeddings represent individual words as relatively low-dimensional dense vectors rather than extremely large sparse vectors

* image segmentation assigns image regions or individual pixels to categories, allowing the model to determine the detailed boundaries

* `papermill` is a tool for parameterizing and executing notebooks. It is pre-installed in many Vertex AI Notebooks environments
    ```bash
    papermill train.ipynb output.ipynb -p output_dir /gcs/my-bucket/model
    ```


## tips 

* Deep Learning VM Images are optimized for data science and machine learning workloads and include packages such as NumPy, SciPy, and scikit-learn.

* when model is split across GPU (multiMirroredStrategy), the batch size must be increased

* GPU to TPU may need code refactoring, config changes and compatibility 

* endpoint --> online ineference. batch inference --> scheudled pipeline (can avoid Cloud Run here)

* A declining training loss paired with a rising validation loss after epoch 4 is the classic signature of overfitting (high variance)

* underfitting is high bias

* `Product-defect identification` from static images is instead a `computer vision problem` in which the model needs to recognize visual features such as edges, textures, shapes, cracks, and missing parts

* for this binary classification requirement. For binary classification, metrics such as precision, recall, F1 score, AuPRC, and AuROC are more directly relevant.

* execution caching allows Gemini Enterprise Agent Platform Pipelines to reuse the output of a previously completed pipeline step when its cache key matches a previous execution. The cache key considers information such as the step inputs, output definitions, and component specification

* `Automatic side-by-side`, or `AutoSxS`, is specifically designed for pairwise model-based evaluation of LLM responses and runs through the Gemini Enterprise Agent Platform evaluation pipeline service

* if cost is a concern, daily training should be avoided, even if data comes daily - unless drift is detected

* `parentModel` parameter tells Model Registry  that the newly uploaded model is a new version of the existing registered model rather than an unrelated model resource

* __custom TensorFlow operations written in C++__ inside the training loop are not **supported on Cloud TPUs** without complex custom XLA kernel implementations

* regression-based imputation can estimate the missing values of an important numerical feature by learning its relationship with other available features

*  `XRAI` generally performs better on natural images, while `Integrated Gradients` is recommended instead for images from artificial environments such as manufacturing lines, laboratories, diagnostic equipment, and quality-control cameras

*  ARIMA-based models are intended for forecasting observations indexed over time

* XAI - Aggregation helps identify consistently influential patterns that may not be visible from a handful of individual explanations

* `Experiments` can organize and compare parameters, metrics, and runs, while `Model Registry` manages model resources and model versions

* normalizing numerical features that cover distinctly different ranges because, without scaling, a model can pay disproportionately high attention to features with wider ranges and insufficient attention to features with narrower ranges

* `Class inbalance` -  **Downsample** the data with **upweighting** to create a sample with 10% positive examples

* `Collaborative filtering models`, a core technique in **recommender** systems, predict user preferences by analyzing interactions between users and items, identifying **similar users or items**, and recommending items liked by similar users or the user in question

* handling features: 
    - One-hot encoding is suitable only for low-cardinality features - typically < 50 to 100 unique values, such as days of the week, device type, or order status
    - Whenever you see high-cardinality discrete values (IDs, search queries, postal codes, product tags) fed into a DNN / TensorFlow model, the answer almost always involves an Embedding layer (tf.keras.layers.Embedding or tf.feature_column.embedding_column)
    - If the question specifies a Boosted Trees (XGBoost / LightGBM) or BigQuery ML context, target encoding or frequency encoding might be favored

* Document AI or Speech-to-Text sits in a hybrid tier where you get pre-built architectures that can be adapted or fine-tuned

* if needed Py DF/pandas can be used for model if data size is less, needs faster and cheaper outputs

* ARIMA / Forecasting: Predicting an aggregated trend or future metric values sequentially over time - like daily volume per zip code or hourly scans by warehouse etc

* bfloat16 as a standard precision for modern model training because it combines a float32-like dynamic range with approximately half the memory footprint

*  TFRecord is TensorFlow's record-oriented binary format and is well suited to large TensorFlow training datasets. Instead of performing an individual object access for every image, the team can serialize images and their associated labels or metadata into a manageable number of sharded TFRecord files in Cloud Storage

* Core ML is specifically intended for running models on iOS and macOS devices

* increasing the penalty for mistakes on the minority class is a cost-sensitive learning technique that directly addresses class imbalance during model optimization

* `Stratified Sampling` is a sampling method where the entire dataset is first divided into distinct, non-overlapping subgroups called strata (based on a shared characteristic like a class label or categorical feature), and then samples are drawn from each stratum independently - for train and test

* Nested cross-validation is used for robust hyperparameter optimization and bias-reduced generalization estimation

* in case of K-Means, one-hot encoded sparse vector/feature can add problems, so we should take top-N, and for numerical one, standardization is must

---



| Workload / Model Characteristic   | Recommended Hardware Platform     |
|---|---|
| Scikit-learn / LightGBM / ARIMA   | Compute-Optimized CPU (c2/n2)     |
| Low-QPS Real-Time Serving (<50ms) | CPU (n2-standard / c2)            |
| Custom C++ CUDA Kernels / Ops     | Multi-GPU (NVIDIA A100 / L4)      |
| High-Throughput Real-Time Vision  | GPU (NVIDIA T4 / L4)              |
| Irregular Graphs / Dynamic Shapes | GPU (NVIDIA A100)                 |
| Large Transformer Pretraining     | Cloud TPU Pod (v4/v5e) or A3 GPU  |
| Extreme Batch Size (e.g. 2048+)   | Cloud TPU Pod                     |
| high cardinal huge features (wide deep data)   | Cloud TPU Pod |
|  lower precision accelerators designed for TensorFlow | Clpoud TPU |
| specify only one worker pool. That worker pool can have only one replica | Cloud TPU | 

---

# Vertex AI Experiment Metrics Reference

| Method | Metric / Artifact Category | Specific Metrics Calculated & Visualized | Description & Purpose |
| :--- | :--- | :--- | :--- |
| **`aiplatform.log_metrics`** | **Scalar Classification Metrics** | • Accuracy<br>• Balanced Accuracy<br>• Precision<br>• Recall / Sensitivity<br>• Specificity<br>• F1-Score / $F_{\beta}$ Score<br>• AUC-ROC<br>• Log Loss / Cross-Entropy | Single float values representing overall classification performance across the entire test/validation set. |
| | **Scalar Regression Metrics** | • Mean Squared Error (MSE)<br>• Root Mean Squared Error (RMSE)<br>• Mean Absolute Error (MAE)<br>• Mean Absolute Percentage Error (MAPE)<br>• $R^2$ Score (Coefficient of Determination)<br>• Explained Variance Score | Evaluates prediction error distance and variance explained for continuous target variables. |
| | **Scalar Ranking / Recommendation Metrics** | • Mean Reciprocal Rank (MRR)<br>• Normalized Discounted Cumulative Gain (NDCG@K)<br>• Precision@K<br>• Recall@K<br>• Mean Average Precision (MAP) | Measures relevance ranking quality and item placement in recommendation systems. |
| | **Operational / Efficiency Metrics** | • Training Duration (seconds)<br>• Inference Latency (p50, p95, p99 ms)<br>• Throughput (queries/second)<br>• Total Cost ($) | System performance metrics logged alongside model performance. |
| **`aiplatform.log_classification_metrics`** | **Confusion Matrix** | • True Positives (TP)<br>• True Negatives (TN)<br>• False Positives (FP)<br>• False Negatives (FN)<br>• Normalized Cell Percentages | Stored as an $N \times N$ 2D array; rendered in Vertex AI Console as an interactive, row/column-normalized heatmap to detect class-level misclassifications. |
| | **ROC Curve (Receiver Operating Characteristic)** | • False Positive Rate (FPR) per threshold<br>• True Positive Rate (TPR / Recall) per threshold<br>• Decision Threshold Values | Series of $(x, y)$ coordinate pairs across varying confidence cutoffs; visualizes classifier trade-offs and discriminatory power independent of decision threshold. |
| | **Precision-Recall (PR) Curve** | • Precision values per threshold<br>• Recall values per threshold<br>• Decision Threshold Values | Evaluates classification trade-offs specifically for imbalanced datasets where True Negatives vastly outnumber True Positives. |

---


# TensorFlow & TFX Ecosystem Components Reference

| Sequence | Component / Module | Full Name | 1–2 Line Description & Purpose |
| :---: | :--- | :--- | :--- |
| **1** | **ExampleGen** | TFX ExampleGen | Ingests raw data from external sources (BigQuery, CSV, TFRecord) and splits it into training/eval sets formatted as `tf.train.Example`. |
| **2** | **TFDV** | TensorFlow Data Validation | Computes descriptive statistics, infers data schemas, and validates incoming data to detect anomalies, missing values, or schema drift. |
| **3** | **Transform / TFT** | TensorFlow Transform (`tf.Transform`) | Preprocesses features at scale using Apache Beam and exports the transformation logic as a TensorFlow graph to eliminate training-serving skew. |
| **4** | **Trainer** | TFX Trainer | Trains the machine learning model using TensorFlow/Keras and outputs SavedModel artifacts for both production serving and evaluation. |
| **5** | **Tuner** | TFX Tuner (KerasTuner / Vizier) | Automates hyperparameter optimization using algorithms like Bayesian optimization or Hyperband to discover the best model configuration. |
| **6** | **TFMA / Evaluator** | TensorFlow Model Analysis (TFX Evaluator) | Evaluates model performance across user-defined data slices using Apache Beam and validates metrics against baseline models or thresholds. |
| **7** | **InfraValidator** | TFX InfraValidator | Deploys the trained model to a sandboxed serving environment to verify it can load and serve predictions without runtime crashes or OOM errors. |
| **8** | **Pusher** | TFX Pusher | Deploys validated models to their final serving destination, such as Vertex AI Endpoints, TensorFlow Serving clusters, or Cloud Storage buckets. |
| **9** | **TF Serving / LiteRT** | TensorFlow Serving / LiteRT (TFLite) | High-performance inference runtimes; TF Serving provides low-latency gRPC/REST APIs in the cloud, while LiteRT executes models on mobile and edge devices. |
| **—** | **MLMD** | ML Metadata | Centralized metadata store that records execution history, lineage, schemas, and input/output artifacts across all pipeline steps. |


---


# Kubeflow Pipelines (KFP) vs. TensorFlow Extended (TFX)

| Feature | Kubeflow Pipelines (KFP) | TensorFlow Extended (TFX) |
| :--- | :--- | :--- |
| **Primary Scope & Nature** | **General-purpose workflow orchestrator** for running containerized steps in a DAG. | **Opinionated, end-to-end MLOps production framework** designed around production ML standards. |
| **Framework Agnostic vs. Specific** | **Framework-agnostic**: Treats any tool equally (PyTorch, Scikit-learn, TensorFlow, XGBoost, Spark, JAX). | **TensorFlow-centric**: Deeply optimized for TensorFlow, SavedModel, and the broader TF ecosystem. |
| **Core Architecture & Abstraction** | Any Docker container with inputs/outputs can be a step (`@dsl.component`). | Pre-built, standardized C++ and Python pipeline components (ExampleGen, Transform, Trainer, Evaluator, Pusher). |
| **Underlying Compute & Execution** | Orchestrates tasks on **Kubernetes (GKE)** or serverless on **Vertex AI Pipelines**. | Orchestrated by KFP, Airflow, or Beam; data-heavy tasks run via **Apache Beam (Cloud Dataflow)**. |
| **Data Validation & Quality Checks** | Custom logic: Must import third-party libraries (e.g., Great Expectations, custom scripts) into a container. | Native & Automated: **TFDV** detects anomalies, infers schemas, and catches data/schema drift out-of-the-box. |
| **Feature Preprocessing & Skew** | Manual: Done inside custom steps; developer must ensure train/serving parity manually. | Native: **`tf.Transform`** creates a preprocessing graph stitched into the SavedModel, eliminating training-serving skew. |
| **Model Evaluation & Slicing** | Manual: Custom metrics code running in a Python component (e.g., standard Scikit-learn metrics). | Native: **TFMA** provides distributed slice-based evaluation, fairness checks, and automated candidate-vs-baseline gating. |
| **Runtime Container Flexibility** | **Extreme**: Package any custom binary, Bash script, Python environment, or specialized CUDA container. | **Structured**: Uses standardized TFX container templates; customization requires extending base TFX component classes. |
| **Deployment & Serving Integration** | Flexible: Pusher step can deploy to Triton, KServe, Seldon, Vertex AI, or raw REST APIs. | Built-in: Natively targets **TF Serving**, **LiteRT (TFLite)**, and **Vertex AI Endpoints**. |
| **Metadata & Lineage Tracking** | Built-in lineage via MLMD (Kubeflow Metadata) or Vertex ML Metadata across pipeline artifacts. | Built-in lineage via **MLMD** natively recording schemas, statistics, transforms, and model evaluations. |
| **Learning Curve & Customization** | Low barrier to entry: Simple to wrap existing Python functions into pipeline steps. | Steeper learning curve: Requires adhering to TFX schemas, artifact types, and Apache Beam concepts. |
| **Exam Trigger / Best Use Case** | *"Multi-framework pipelines, custom container workflows, flexible step orchestration on Vertex AI Pipelines."* | *"TensorFlow models, strict production MLOps, automated drift detection, eliminating training-serving skew with `tf.Transform`."* |


---

# Global Explainability vs. Local Explainability

| Feature | Global Explainability | Local Explainability |
| :--- | :--- | :--- |
| **Core Question Answered** | *"How does the model behave overall across the entire population?"* | *"Why did the model make this specific prediction for this single instance?"* |
| **Scope of View** | **Macro / Dataset-wide**: Inspects global decision logic, general feature relationships, and overall directional impact. | **Micro / Instance-level**: Inspects the exact feature values of one user, transaction, or image that drove that specific outcome. |
| **Typical Techniques / Algorithms** | • Global Feature Importance (MDI, Permutation Importance)<br>• Partial Dependence Plots (PDP)<br>• Accumulated Local Effects (ALE)<br>• Mean Absolute SHAP values across all rows | • SHAP values (Shapley Additive exPlanations) for a single row<br>• LIME (Local Interpretable Model-agnostic Explanations)<br>• Integrated Gradients (feature attributions per input)<br>• Saliency Maps / Grad-CAM (for vision) |
| **Primary Audience & Use Case** | • **Data Scientists & ML Engineers**: Debugging overall bias, feature selection, and sanity-checking global learned patterns.<br>• **Auditors & Regulators**: Validating fairness, governance, and policy compliance before model deployment. | • **End Users & Operators**: Customer support explaining loan denials, fraud analysts investigating an alert, doctors reviewing a diagnostic recommendation.<br>• **Adverse Action Notices**: Generating mandated reason codes (e.g., FCRA/ECOA in banking). |
| **Concrete Real-World Example (Credit Card Application)** | *"Across all 500,000 applicants, Credit Score and Debt-to-Income (DTI) ratio have the highest overall influence on approvals."* | *"Applicant #48291 was rejected specifically because their DTI ratio was 54% and they had 3 late payments in the last 12 months."* |
| **Vertex AI Integration** | **Vertex Explainable AI - Model-level Feature Attributions**: Aggregate attribution charts displayed in the Model Registry evaluation tab. | **Vertex Explainable AI - Online Explanations (`predict` with attributions)**: Returns an explanation payload with baseline attributions alongside each real-time prediction score. |

---

# Deep Learning & ML Hyperparameter Reference Guide

### 1. `learning_rate`
* **What it controls:** The step size taken along the loss gradient vector during weight updates ($w \leftarrow w - \eta \nabla L$).
* **Typical default / search range:** `1e-5` to `1e-1` (Adam: `1e-4` to `3e-4`; SGD: `1e-2` to `1e-1`; LLM fine-tuning: `1e-5` to `5e-5`).
* **Compute & latency impact:** No impact on per-step compute time; dictates total training epochs needed for loss convergence.
* **Common pitfalls & symptoms:** 
  * *Too high:* Exploding loss, `NaN` values, training instability and divergence.
  * *Too low:* Premature plateau, excessively slow training, getting trapped in poor local minima.
* **When & how to tune:** Always tune this first. Use learning rate range tests (LR finder), warmup steps, and schedulers (Cosine Annealing, Linear Decay, or ReduceLROnPlateau).

---

### 2. `clip_grad_norm`
* **What it controls:** Caps the maximum $L_2$ norm of the gradient vector across all parameters to a threshold $c$ ($g \leftarrow g \cdot \min(1, \frac{c}{\Vert{}g\Vert{}})$).
* **Typical default / search range:** `0.5` to `5.0` (Standard default: `1.0`).
* **Compute & latency impact:** Negligible overhead (computes one global reduction vector norm per backward pass).
* **Common pitfalls & symptoms:** 
  * *Too low (< 0.1):* Artificially chokes gradient magnitude, severely dragging down learning speed.
  * *Unset or too high:* Gradient explosions in deep networks, RNNs, and Transformers (`NaN` loss).
* **When & how to tune:** Essential for Transformers, LLMs, and RNNs. Keep at `1.0` by default; adjust downward to `0.5` if loss exhibits sudden divergence spikes.

---

### 3. `clip_grad_value`
* **What it controls:** Clips each individual gradient element element-wise into a fixed interval $[-c, c]$ ($g_i \leftarrow \text{clip}(g_i, -c, c)$).
* **Typical default / search range:** `0.1` to `1.0` (Typically `0.5` or `1.0`).
* **Compute & latency impact:** Negligible overhead (element-wise clamping during backward pass).
* **Common pitfalls & symptoms:** Unlike `clip_grad_norm` which preserves vector direction and only scales magnitude, value clipping alters the direction of the gradient vector.
* **When & how to tune:** Prefer `clip_grad_norm` for Transformer attention blocks; use value clipping when individual outlier gradients dominate specific layers.

---

### 4. `batch_size`
* **What it controls:** Number of training samples processed in forward and backward passes before updating model weights.
* **Typical default / search range:** `16` to `2048` (Hardware-constrained; powers of 2: 32, 64, 128, 256).
* **Compute & latency impact:** Larger batches boost GPU compute saturation and throughput; small batches increase I/O thrashing and per-epoch wall time.
* **Common pitfalls & symptoms:** 
  * *Too high:* Generalization gap (converging to sharp minima), GPU Out-Of-Memory (OOM).
  * *Too low:* High gradient variance, erratic loss trajectory.
* **When & how to tune:** Scale batch size to maximize GPU memory without OOM. When scaling batch size by a factor of $k$, scale base learning rate linearly ($k \cdot \eta$) or square root ($\sqrt{k} \cdot \eta$).

---

### 5. `weight_decay` ($L_2$ Regularization)
* **What it controls:** Penalizes large model weights by subtracting a fraction of the weight at each step ($\mathcal{L}_{\text{total}} = \mathcal{L} + \frac{\lambda}{2}\Vert{}w\Vert{}^2$).
* **Typical default / search range:** `1e-4` to `1e-1` (AdamW: `0.01` to `0.1`; SGD: `1e-4` to `5e-4`).
* **Compute & latency impact:** Zero compute impact (folded into the parameter update step).
* **Common pitfalls & symptoms:** 
  * *Too high:* Underfitting, over-regularized model collapses predictions toward zero.
  * *Too low:* Overfitting, memorization of noise in the training set.
* **When & how to tune:** Tune when validation loss diverges from training loss. Use **AdamW** (decoupled weight decay) rather than classical Adam for Transformers and modern CNNs.

---

### 6. `warmup_steps` / `warmup_ratio`
* **What it controls:** Number of initial training steps where the learning rate linearly ramps from 0 up to the maximum target `learning_rate`.
* **Typical default / search range:** `500` to `2000` steps, or `0.03` to `0.10` (3%–10% of total training steps).
* **Compute & latency impact:** No compute impact.
* **Common pitfalls & symptoms:** Without warmup, high initial learning rates applied to randomized weights destroy pre-trained representations and destabilize layer normalization.
* **When & how to tune:** Critical for Transformers, AdamW, and fine-tuning pre-trained foundation models. Tune based on total step count.

---

### 7. `momentum` / $\beta_1, \beta_2$
* **What it controls:** Moving average factors of historical gradients (momentum: $\beta_1 \approx 0.9$) and squared historical gradients (Adam second moment: $\beta_2 \approx 0.999$).
* **Typical default / search range:** Momentum: `0.9` to `0.99`; Adam: $\beta_1 = 0.9$, $\beta_2 = 0.98$ (Transformers) or $0.999$ (Standard).
* **Compute & latency impact:** Adds memory footprint for optimizer state tensors (2x model size in RAM for Adam).
* **Common pitfalls & symptoms:** Setting $\beta_2$ too close to 1.0 causes slow adaptation to changing gradient variance; setting it too low destabilizes step variance.
* **When & how to tune:** Rarely tuned from defaults; for large-batch Transformer pre-training, tuning $\beta_2 = 0.98$ prevents divergence.

---

### 8. `dropout`
* **What it controls:** Probability of randomly zeroing out hidden activation units during a forward training pass.
* **Typical default / search range:** `0.1` to `0.5` (Embedding/attention: `0.1`; Dense layers: `0.2` to `0.5`).
* **Compute & latency impact:** Very slight kernel overhead; zero memory footprint.
* **Common pitfalls & symptoms:** 
  * *Too high:* Model fails to learn sufficient representations (underfitting).
  * *Too low:* Severe overfitting on small datasets.
* **When & how to tune:** Tune after learning rate and batch size are locked. If training accuracy reaches 99% while validation plateaus early, increase dropout.

---

### 9. `label_smoothing`
* **What it controls:** Softens hard one-hot target distributions ($y_k = (1 - \epsilon)y_k + \frac{\epsilon}{K}$).
* **Typical default / search range:** `0.05` to `0.2` (Standard: `0.1`).
* **Compute & latency impact:** Negligible compute overhead during cross-entropy loss computation.
* **Common pitfalls & symptoms:** 
  * *Too high:* Prevents the model from making confident, correct predictions.
  * Can hurt calibration if downstream tasks rely strictly on raw softmax probabilities.
* **When & how to tune:** Use when dealing with noisy labels, high-class-count classification, or overconfident neural networks.

---

### 10. `gradient_accumulation_steps`
* **What it controls:** Number of forward/backward passes evaluated before calling `optimizer.step()` and `zero_grad()`.
* **Typical default / search range:** `1` (off) to `16` or `32` (Effective batch size = `per_device_batch_size * gradient_accumulation_steps * num_gpus`).
* **Compute & latency impact:** No speed improvement; enables large effective batch sizes without incurring GPU VRAM spikes.
* **Common pitfalls & symptoms:** Miscalculating effective learning rate scaling; forgetting to adjust learning rate schedules according to effective steps.
* **When & how to tune:** Use when GPU memory cannot fit the desired batch size; trades wall-clock execution time for bypassing the VRAM ceiling.

---


Try in Console:
pipelines
experiments
workbench vs colab
MLMD

give me details, in table for MD file copy, for below and any other important hyperparameter
clip_grad_norm
learning rate



### Important links

Creating Tabular data
https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/tabular-data/bp-tabular

GPU TPU details
https://docs.cloud.google.com/gemini-enterprise-agent-platform/machine-learning/training/configure-compute#gpu-compatibility-table
