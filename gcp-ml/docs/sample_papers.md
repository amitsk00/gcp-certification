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





| Workload / Model Characteristic   | Recommended Hardware Platform     |
|---|---|
| Scikit-learn / LightGBM / ARIMA   | Compute-Optimized CPU (c2/n2)     |
| Custom C++ CUDA Kernels / Ops     | Multi-GPU (NVIDIA A100 / L4)      |
| Low-QPS Real-Time Serving (<50ms) | CPU (n2-standard / c2)            |
| High-Throughput Real-Time Vision  | GPU (NVIDIA T4 / L4)              |
| Large Transformer Pretraining     | Cloud TPU Pod (v4/v5e) or A3 GPU  |
| Irregular Graphs / Dynamic Shapes | GPU (NVIDIA A100)                 |
| Extreme Batch Size (e.g. 2048+)   | Cloud TPU Pod                     |








Try in COnolse
pipelines
experiments
workbench vs colab
MLMD
