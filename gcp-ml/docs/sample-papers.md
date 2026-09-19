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




## tips 

* Deep Learning VM Images are optimized for data science and machine learning workloads and include packages such as NumPy, SciPy, and scikit-learn.

* when model is split across GPU (multiMirroredStrategy), the batch size must be increased

* GPU to TPU may need code refactoring, config changes and compatibility 

* endpoint --> online ineference. batch inference --> scheudled pipeline (can avoid Cloud Run here)

* A declining training loss paired with a rising validation loss after epoch 4 is the classic signature of overfitting (high variance)

* Product-defect identification from static images is instead a computer vision problem in which the model needs to recognize visual features such as edges, textures, shapes, cracks, and missing parts

* for this binary classification requirement. For binary classification, metrics such as precision, recall, F1 score, AuPRC, and AuROC are more directly relevant.

* execution caching allows Gemini Enterprise Agent Platform Pipelines to reuse the output of a previously completed pipeline step when its cache key matches a previous execution. The cache key considers information such as the step inputs, output definitions, and component specification

* Automatic side-by-side, or AutoSxS, is specifically designed for pairwise model-based evaluation of LLM responses and runs through the Gemini Enterprise Agent Platform evaluation pipeline service

* if cost is a concern, daily training should be avoided, even if data comes daily - unless drift is detected

* `parentModel` parameter tells Model Registry  that the newly uploaded model is a new version of the existing registered model rather than an unrelated model resource

* __custom TensorFlow operations written in C++__ inside the training loop are not **supported on Cloud TPUs** without complex custom XLA kernel implementations

* regression-based imputation can estimate the missing values of an important numerical feature by learning its relationship with other available features


which cpu/gpu/tpu for which model
ResNet model
which metric for which model
Managed Lustre
    Native, POSIX-compliant parallel file system designed for HPC and large AI clusters
    Multi-terabytes per second (TB/s) aggregated throughput
    Sub-millisecond read/write latency; handles high-concurrency metadata operations with zero jitter.


