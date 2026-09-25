# Section 5: Automating and Orchestrating ML Pipelines (~18% of the Exam)

---

## 5.1 Developing End-to-End ML Pipelines

### What is an ML Pipeline?
An ML pipeline automates the sequence of steps from raw data to a deployed model:
```
Data Ingestion → Validation → Preprocessing → Training → Evaluation → Model Registry → Deployment
```

Benefits:
- **Reproducibility**: Same code produces same results
- **Reusability**: Share components across teams
- **Auditability**: Every step is logged and versioned
- **Automation**: Trigger retraining on schedule or data events

---

### Validating Data and Models

#### Data Validation with TensorFlow Data Validation (TFDV)
```python
import tensorflow_data_validation as tfdv

# Generate statistics from training data
train_stats = tfdv.generate_statistics_from_csv("gs://bucket/train.csv")

# Infer schema
schema = tfdv.infer_schema(statistics=train_stats)
tfdv.display_schema(schema=schema)

# Validate new data against schema
serving_stats = tfdv.generate_statistics_from_csv("gs://bucket/serving.csv")
anomalies = tfdv.validate_statistics(statistics=serving_stats, schema=schema)
tfdv.display_anomalies(anomalies)

# Key anomaly types to watch:
# - SCHEMA_NEW_COLUMN: unexpected feature in serving data
# - SCHEMA_MISSING_COLUMN: expected feature is absent
# - INT_TYPE_SMALL_INT: value out of expected range
# - FEATURE_TYPE_LOW_NUMBER_DISTINCT: categorical has fewer values than expected
```

#### Model Validation (Before Promotion)
```python
# Evaluate challenger model vs. champion
def validate_model(new_model, champion_model, test_dataset, threshold=0.01):
    new_metrics = evaluate(new_model, test_dataset)
    champion_metrics = evaluate(champion_model, test_dataset)

    improvement = new_metrics["auc"] - champion_metrics["auc"]
    if improvement >= threshold:
        print(f"Model validated: +{improvement:.4f} AUC improvement")
        return True
    else:
        print(f"Model rejected: insufficient improvement ({improvement:.4f})")
        return False
```

**Standard model validation gates:**
1. Accuracy/AUC is above minimum threshold
2. New model outperforms or matches current champion
3. Inference latency is within SLA
4. No anomalous feature attributions
5. Fairness metrics pass (if required)

---

### Building and Orchestrating Pipelines

#### Vertex AI Pipelines (Kubeflow Pipelines v2 SDK)
The primary pipeline orchestration tool on GCP. Define components as Python functions, wire them together into a pipeline.

```python
from kfp import dsl
from kfp.v2 import compiler
from google.cloud import aiplatform

# Define a reusable component
@dsl.component(
    base_image="python:3.10",
    packages_to_install=["pandas", "scikit-learn", "google-cloud-bigquery"]
)
def preprocess_data(
    bq_table: str,
    output_path: dsl.Output[dsl.Dataset]
):
    from google.cloud import bigquery
    import pandas as pd

    client = bigquery.Client()
    df = client.query(f"SELECT * FROM `{bq_table}`").to_dataframe()
    df.to_csv(output_path.path, index=False)

@dsl.component(
    base_image="python:3.10",
    packages_to_install=["scikit-learn", "joblib"]
)
def train_model(
    data: dsl.Input[dsl.Dataset],
    model: dsl.Output[dsl.Model],
    learning_rate: float = 0.01,
    max_depth: int = 3
) -> float:
    import pandas as pd
    from sklearn.ensemble import GradientBoostingClassifier
    import joblib

    df = pd.read_csv(data.path)
    X, y = df.drop("label", axis=1), df["label"]
    clf = GradientBoostingClassifier(max_depth=max_depth)
    clf.fit(X, y)
    joblib.dump(clf, model.path)

    score = clf.score(X, y)
    return score

@dsl.component(
    base_image="python:3.10",
    packages_to_install=["google-cloud-aiplatform"]
)
def deploy_model(
    model: dsl.Input[dsl.Model],
    accuracy: float,
    threshold: float = 0.85
):
    from google.cloud import aiplatform

    if accuracy < threshold:
        raise ValueError(f"Model accuracy {accuracy} below threshold {threshold}")

    aiplatform.init(project="my-project", location="us-central1")
    vertex_model = aiplatform.Model.upload(
        display_name="my-model",
        artifact_uri=model.uri,
        serving_container_image_uri="us-docker.pkg.dev/vertex-ai/prediction/sklearn-cpu.1-0:latest"
    )
    vertex_model.deploy(machine_type="n1-standard-4")

# Define the pipeline
@dsl.pipeline(name="my-ml-pipeline", description="End-to-end ML pipeline")
def ml_pipeline(
    bq_table: str = "my_project.dataset.training",
    learning_rate: float = 0.01
):
    preprocess_op = preprocess_data(bq_table=bq_table)

    train_op = train_model(
        data=preprocess_op.outputs["output_path"],
        learning_rate=learning_rate
    )

    deploy_model(
        model=train_op.outputs["model"],
        accuracy=train_op.output
    )

# Compile the pipeline
compiler.Compiler().compile(
    pipeline_func=ml_pipeline,
    package_path="ml_pipeline.json"
)

# Submit pipeline run
aiplatform.init(project="my-project", location="us-central1")
pipeline_job = aiplatform.PipelineJob(
    display_name="my-ml-pipeline-run",
    template_path="ml_pipeline.json",
    parameter_values={
        "bq_table": "my_project.dataset.training",
        "learning_rate": 0.005
    }
)
pipeline_job.submit()
```

#### Managed Service for Apache Airflow (Cloud Composer)
Use Cloud Composer when you need complex scheduling, dependencies on non-ML systems, or existing Airflow DAGs.

```python
from airflow import DAG
from airflow.providers.google.cloud.operators.vertex_ai.custom_job import CreateCustomTrainingJobOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryExecuteQueryOperator
from datetime import datetime, timedelta

default_args = {
    "owner": "ml-team",
    "retries": 2,
    "retry_delay": timedelta(minutes=5)
}

with DAG(
    dag_id="ml_retraining_dag",
    schedule_interval="0 2 * * 1",  # Weekly on Monday at 2am
    start_date=datetime(2024, 1, 1),
    default_args=default_args,
    catchup=False
) as dag:
    preprocess = BigQueryExecuteQueryOperator(
        task_id="preprocess_features",
        sql="sql/preprocess.sql",
        use_legacy_sql=False,
        destination_dataset_table="my_project.dataset.processed"
    )

    train = CreateCustomTrainingJobOperator(
        task_id="train_model",
        project_id="my-project",
        region="us-central1",
        display_name="weekly-retrain",
        script_path="gs://bucket/train.py",
        container_uri="us-docker.pkg.dev/vertex-ai/training/sklearn-cpu.0-23:latest",
        machine_type="n1-standard-8"
    )

    preprocess >> train
```

#### Ray on Vertex AI
Use Ray when you need distributed Python for data processing, hyperparameter search, or reinforcement learning.

```python
import ray
from ray import tune

# Initialize Ray on Vertex AI
vertex_ray = vertexai.preview.vertex_ray
runtime_env = {"pip": ["xgboost", "scikit-learn"]}
ray.init(address=vertex_ray.get_ray_address(), runtime_env=runtime_env)

# Distributed hyperparameter search with Ray Tune
def train_model(config):
    from sklearn.ensemble import GradientBoostingClassifier
    from sklearn.metrics import roc_auc_score
    import pandas as pd

    df = pd.read_csv("gs://bucket/data.csv")
    X, y = df.drop("label", axis=1), df["label"]

    clf = GradientBoostingClassifier(
        learning_rate=config["lr"],
        max_depth=config["depth"]
    )
    clf.fit(X, y)
    auc = roc_auc_score(y, clf.predict_proba(X)[:, 1])
    tune.report(auc=auc)

analysis = tune.run(
    train_model,
    config={
        "lr": tune.loguniform(1e-4, 1e-1),
        "depth": tune.randint(2, 8)
    },
    num_samples=20,
    resources_per_trial={"cpu": 2}
)
```

📖 [Vertex AI Pipelines](https://cloud.google.com/vertex-ai/docs/pipelines/introduction)
📖 [Cloud Composer](https://cloud.google.com/composer/docs/concepts/overview)
📖 [Ray on Vertex AI](https://cloud.google.com/vertex-ai/docs/open-source/ray-on-vertex-ai/overview)

---

### Ensuring Consistent Data Preprocessing Between Training and Serving
**Training-serving skew** is one of the most common production ML issues — the model receives different data at serving time than it was trained on.

#### Sources of Training-Serving Skew
| Source | Example | Fix |
|---|---|---|
| Different code paths | Pandas in training, SQL in serving | Use shared preprocessing (Beam/tf.Transform) |
| Feature drift | Training used old data, serving has new distribution | Monitor feature statistics |
| Missing features | Feature available at training but not at serving time | Feature availability audit before deployment |
| Different preprocessing libraries | sklearn StandardScaler vs custom zscore | Export scaler with model |

#### Solutions
**Option 1: Export preprocessing with the model (sklearn Pipeline)**

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import GradientBoostingClassifier
import joblib

pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model', GradientBoostingClassifier())
])
pipeline.fit(X_train, y_train)

# Save entire pipeline — scaler is embedded
joblib.dump(pipeline, "model.pkl")

# At serving time, scaler is automatically applied
predictions = pipeline.predict(X_new)
```

**Option 2: TFX Transform (same code, train and serve)**

```python
# preprocessing_fn runs identically during training and serving
def preprocessing_fn(inputs):
    return {
        'x_scaled': tft.scale_to_z_score(inputs['x']),
        'y_vocab': tft.compute_and_apply_vocabulary(inputs['y'])
    }
```

**Option 3: Feature Store (pre-compute, serve same values)**

- Compute features in a Dataflow batch job
- Write to Feature Store
- Training reads from Feature Store
- Serving reads from Feature Store (same values)

---

## 5.2 Automating Model Retraining

### Determining an Appropriate Retraining Policy
| Trigger Type | When to Use | Example |
|---|---|---|
| **Schedule-based** | Data arrives regularly, gradual drift | Retrain every Monday at 2am |
| **Data-volume trigger** | Retrain when N new samples arrive | 10,000 new transactions collected |
| **Drift-based trigger** | Retrain when drift exceeds threshold | PSI > 0.2 detected |
| **Performance-based trigger** | Retrain when live accuracy drops | AUC drops > 5% from baseline |
| **Event-based** | External events change data distribution | New product launch, regulatory change |

#### Drift Detection for Retraining Triggers
```python
from scipy.stats import ks_2samp
import numpy as np

def detect_drift(reference_data, current_data, threshold=0.05):
    """Kolmogorov-Smirnov test for distribution drift."""
    results = {}
    for feature in reference_data.columns:
        stat, p_value = ks_2samp(reference_data[feature], current_data[feature])
        results[feature] = {"statistic": stat, "p_value": p_value, "drift": p_value < threshold}
    return results

drift_report = detect_drift(train_df, serving_df)
if any(v["drift"] for v in drift_report.values()):
    trigger_retraining_pipeline()
```

#### Population Stability Index (PSI)
PSI measures how much a feature distribution has shifted:
```
PSI < 0.1  → No significant change
0.1-0.2    → Moderate change, monitor
> 0.2      → Significant drift, retrain
```

```python
def calculate_psi(expected, actual, buckets=10):
    expected_perc = np.histogram(expected, bins=buckets)[0] / len(expected)
    actual_perc = np.histogram(actual, bins=buckets)[0] / len(actual)

    # Avoid log(0)
    expected_perc = np.where(expected_perc == 0, 0.0001, expected_perc)
    actual_perc = np.where(actual_perc == 0, 0.0001, actual_perc)

    psi = np.sum((actual_perc - expected_perc) * np.log(actual_perc / expected_perc))
    return psi
```

📖 [Vertex AI Model Monitoring](https://cloud.google.com/vertex-ai/docs/model-monitoring/overview)

---

### Deploying Models in CI/CD/CT Pipelines

#### What is CI/CD/CT?
| Term | What | Trigger |
|---|---|---|
| **CI** (Continuous Integration) | Test code, validate data, unit test pipeline components | Git push |
| **CD** (Continuous Delivery) | Deploy trained model to staging/production | Model passes evaluation |
| **CT** (Continuous Training) | Automatically retrain on new data | Schedule or data/drift trigger |

#### Full CI/CD/CT Pipeline Architecture
```
[Git Push to main]
       ↓
[Cloud Build — CI]
  - Run unit tests
  - Validate pipeline components
  - Build/push container images
       ↓
[Vertex AI Pipeline — CT]
  - Ingest new training data
  - Preprocess & validate
  - Train model
  - Evaluate vs. champion
       ↓
[Model Validation Gate]
  - AUC > threshold?
  - Latency within SLA?
       ↓ (if pass)
[Vertex AI — CD]
  - Register model in Model Registry
  - Deploy to staging endpoint
  - Run integration tests
  - Promote to production (canary → full)
```

#### Cloud Build Trigger Setup
```yaml
# cloudbuild.yaml
steps:
  # Step 1: Run unit tests
  - name: 'python:3.10'
    entrypoint: pip
    args: ['install', '-r', 'requirements.txt']
  - name: 'python:3.10'
    entrypoint: python
    args: ['-m', 'pytest', 'tests/']

  # Step 2: Build and push training container
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/trainer:$COMMIT_SHA', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/trainer:$COMMIT_SHA']

  # Step 3: Trigger Vertex AI Pipeline
  - name: 'python:3.10'
    entrypoint: python
    args: ['scripts/trigger_pipeline.py',
           '--image', 'gcr.io/$PROJECT_ID/trainer:$COMMIT_SHA',
           '--project', '$PROJECT_ID']

# Trigger on push to main branch
trigger:
  branch: main
  includedFiles:
    - 'src/**'
    - 'requirements.txt'
```

#### Pipeline Trigger Script
```python
# scripts/trigger_pipeline.py
import argparse
from google.cloud import aiplatform

def trigger_pipeline(image_uri: str, project: str):
    aiplatform.init(project=project, location="us-central1")

    pipeline_job = aiplatform.PipelineJob(
        display_name=f"ci-triggered-pipeline",
        template_path="gs://bucket/pipelines/ml_pipeline.json",
        parameter_values={
            "training_image": image_uri,
            "bq_table": f"{project}.dataset.training"
        }
    )
    pipeline_job.submit()
    pipeline_job.wait()

    if pipeline_job.state == aiplatform.gapic.PipelineState.PIPELINE_STATE_SUCCEEDED:
        print("Pipeline succeeded — model promoted to staging")
    else:
        raise RuntimeError("Pipeline failed — no deployment")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", required=True)
    parser.add_argument("--project", required=True)
    args = parser.parse_args()
    trigger_pipeline(args.image, args.project)
```

📖 [MLOps on Google Cloud](https://cloud.google.com/vertex-ai/docs/start/introduction-unified-platform)
📖 [Cloud Build triggers](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers)

---

### MLOps Maturity Levels
Understanding maturity levels helps answer "which approach is best for this team?" questions on the exam.

| Level | Description | What's Automated |
|---|---|---|
| **Level 0** | Manual ML | Nothing — data scientist runs notebook manually |
| **Level 1** | ML pipeline automation | CT pipeline; model training automated, deployment manual |
| **Level 2** | CI/CD pipeline automation | Full CI/CD/CT; code change → automatic test → train → deploy |

**Exam tip**: Most companies start at Level 0 and progress. The exam often asks which MLOps improvement gives the most value for a given pain point.

---

## Key Exam Tips for Section 5
- **KFP v2 components** = Python functions decorated with `@dsl.component`; inputs/outputs are typed
- **Cloud Composer** = when you have non-ML dependencies (BigQuery jobs, email notifications, external APIs)
- **Ray on Vertex AI** = distributed Python; best for hyperparameter search and reinforcement learning
- **Training-serving skew** = most common production failure; fix with sklearn Pipeline, tf.Transform, or Feature Store
- **Retraining triggers**: schedule < data-volume < drift-based < performance-based (increasing sophistication)
- **CI** = test code; **CD** = deploy model; **CT** = retrain model automatically
- **Cloud Build** = CI/CD trigger; connects git events to Vertex AI Pipeline runs
- **PSI > 0.2** = retrain; **PSI 0.1-0.2** = monitor; **PSI < 0.1** = stable
- Pipelines store artifacts in Cloud Storage; components communicate via typed artifacts (`dsl.Dataset`, `dsl.Model`, `dsl.Metrics`)
- Always validate data **before** training and validate model **before** deployment
