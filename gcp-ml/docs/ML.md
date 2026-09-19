# ML basics and some deep dive


## ML Types
### Deep Neural Networks
A Deep Neural Network (DNN) is a type of machine learning model inspired by the structure of the human brain. It's excellent for finding complex, non-linear patterns in data.
*   **Use Cases:** Image recognition, natural language processing (NLP), and audio processing.
*   **GCP Context:** Typically trained on Vertex AI using custom containers with frameworks like TensorFlow or PyTorch. They benefit greatly from hardware acceleration using GPUs or TPUs.
### LLM
Large Language Models (LLMs) are a specialized type of deep neural network designed to understand, generate, and reason about human language.
*   **Use Cases:** Text generation, summarization, translation, question-answering, and chatbots.
*   **GCP Context:** Google's foundational models (like Gemini and PaLM) are available in the Vertex AI Model Garden. You can interact with them via APIs or tune them for specific tasks using techniques like Parameter-Efficient Fine-Tuning (PEFT).
### Logistic Regression
A fundamental classification algorithm used to predict a binary outcome (e.g., yes/no, true/false). It's valued for its simplicity, speed, and high interpretability.
*   **Use Cases:** Fraud detection, spam filtering, and medical diagnosis.
*   **GCP Context:** A core model type supported directly within BigQuery ML, allowing you to train classification models on tabular data using only SQL.
### Linear Regression
A fundamental regression algorithm used to predict a continuous numerical value based on one or more input features. Like logistic regression, it is simple and interpretable.
*   **Use Cases:** Predicting house prices, forecasting sales, or estimating customer lifetime value.
*   **GCP Context:** Also a core model type supported in BigQuery ML for easy, scalable regression tasks.
### Decision trees
A supervised learning model that uses a tree-like structure of decisions to arrive at a conclusion. It's highly interpretable and can be used for both classification and regression.
*   **Use Cases:** Customer churn prediction, loan approval decisions.
*   **GCP Context:** While simple, they are the building blocks for more powerful ensemble models like Random Forest and XGBoost (which is available in BQML).
### K-Means CLustering
An unsupervised learning algorithm that groups data into a specified number (K) of clusters based on feature similarity. It's used to discover underlying patterns or structures in a dataset without pre-existing labels.
*   **Use Cases:** Customer segmentation, document clustering, and anomaly detection.
*   **GCP Context:** Supported in BigQuery ML, enabling large-scale clustering directly on data stored in BigQuery.
### ARIMA_PLUS
An advanced time-series forecasting model available in BigQuery ML. It's an enhancement of the standard ARIMA model.
*   **Use Cases:** Forecasting product demand, stock prices, or website traffic.
*   **GCP Context:** A key feature of BQML, `ARIMA_PLUS` automatically handles common time-series challenges like seasonality, holidays, missing data, and anomalies.
### Random Forest
An ensemble learning method that builds multiple decision trees during training and outputs the mode of the classes (classification) or mean prediction (regression) of the individual trees. It generally has higher accuracy and is more robust against overfitting than a single decision tree.
*   **Use Cases:** A powerful, general-purpose algorithm for complex classification and regression tasks on tabular data.


### XGBoost
XGBoost (eXtreme Gradient Boosting) is a highly optimized and popular implementation of the gradient boosting algorithm, a type of ensemble learning. It builds a strong predictive model by sequentially adding weak learner models (typically decision trees) and correcting the errors of the previous models. It is renowned for its performance, speed, and accuracy, often being the algorithm of choice for winning machine learning competitions on structured data.

*   **Use Cases:** Widely used for classification, regression, and ranking problems on tabular/structured data, such as sales forecasting, fraud detection, and customer churn prediction.
*   **GCP Context:** XGBoost is a supported model type in **BigQuery ML**, allowing you to train powerful models directly in BigQuery with SQL. It can also be trained as a custom model on Vertex AI Training.

### TF-IDF
TF-IDF (Term Frequency-Inverse Document Frequency) is not a model itself, but a fundamental feature extraction technique used in Natural Language Processing (NLP) to convert a collection of text documents into a matrix of numerical features. It evaluates how important a word is to a document in a corpus.

*   **How it Works:**
    *   **Term Frequency (TF):** Measures how frequently a term appears in a document.
    *   **Inverse Document Frequency (IDF):** Measures how important a term is by weighing down common words (like "the", "a") and scaling up rare words that provide more unique information.
*   **Use Cases:** Information retrieval, text classification, and document clustering. It's a crucial preprocessing step before feeding text data to algorithms like Logistic Regression, SVMs, or even neural networks.
*   **GCP Context:** BigQuery ML provides the `ML.TF_IDF` function to perform this feature engineering step directly within a SQL query. It can also be implemented as part of a preprocessing pipeline in Vertex AI using libraries like scikit-learn or TensorFlow Transform.


### HistGradientBoostingClassifier
This is a modern and highly efficient implementation of the gradient boosting algorithm, available in the scikit-learn library. It is inspired by LightGBM and is designed to be very fast for datasets with a large number of samples.

*   **How it Works:** Instead of considering every unique value for a feature when creating splits in its decision trees, it bins the continuous features into a fixed number of buckets (a histogram). This dramatically reduces the number of split points to consider, speeding up training significantly with minimal loss in accuracy.
*   **Use Cases:** An excellent choice for classification on large, tabular datasets where training speed is a concern. It's a direct and powerful alternative to XGBoost or LightGBM within the scikit-learn ecosystem.
*   **GCP Context:** This model would typically be trained as part of a custom model on Vertex AI Training, often within a scikit-learn pipeline.

### Support Vector Machine (SVM)
A powerful and versatile supervised learning algorithm used for classification, regression, and outlier detection. The core idea of SVM for classification is to find the optimal hyperplane that best separates data points of different classes in a high-dimensional space.

*   **How it Works:** It identifies the hyperplane that has the maximum margin (distance) between the closest data points of the different classes (called "support vectors"). For non-linear data, SVMs can use the "kernel trick" to map the data into a higher dimension where a linear separation becomes possible.
*   **Use Cases:** Image classification, text classification, and bioinformatics. It is particularly effective on high-dimensional data and when there is a clear margin of separation between classes.
*   **GCP Context:** SVMs are not a built-in model type in BigQuery ML but are a standard part of scikit-learn, making them easy to use for custom model training on Vertex AI.

### Naive Bayes
A simple yet effective probabilistic classification algorithm based on Bayes' Theorem. It operates on the "naive" assumption that the features used for prediction are independent of each other, given the class label.

*   **How it Works:** It calculates the probability of each class given a set of input features. Despite its simplifying assumption, it performs surprisingly well in many real-world scenarios, especially for text-based problems.
*   **Use Cases:** Spam filtering, document classification, and sentiment analysis. It is very fast to train and works well with high-dimensional data like text.
*   **GCP Context:** Like SVM, Naive Bayes is a staple of scikit-learn and can be easily trained as a custom model on Vertex AI.

### LightGBM
LightGBM (Light Gradient Boosting Machine) is another high-performance, open-source gradient boosting framework, similar to XGBoost. It is known for its incredible speed and efficiency, often outperforming other algorithms on large datasets.

*   **How it Works:** LightGBM's speed comes from two main techniques: a histogram-based algorithm (which reduces the cost of finding splits, similar to `HistGradientBoostingClassifier`) and Gradient-based One-Side Sampling (GOSS), which focuses on training examples with larger gradients (i.e., the ones that are poorly predicted).
*   **Use Cases:** Ideal for the same tasks as XGBoost (classification, regression on tabular data) but can be significantly faster, especially with hundreds of thousands of data points or more.
*   **GCP Context:** LightGBM is not a native model in BigQuery ML, but it is a very popular choice for custom training on Vertex AI, especially in performance-sensitive applications or machine learning competitions.






## HyperParameter Search Algo
### Random Search
A technique for hyperparameter tuning that samples a fixed number of parameter combinations from a specified statistical distribution. It is generally more efficient than Grid Search, as it doesn't waste time on unimportant parameters.
### Grid Search
A traditional hyperparameter tuning method that exhaustively tries every combination of a given set of parameter values. While thorough, it can be computationally very expensive and inefficient, especially with a large number of parameters.
### Bayesian Optimization
A sophisticated and efficient hyperparameter tuning algorithm that uses the results from previous trials to inform which set of parameters to try next. It builds a probabilistic model of the objective function and uses it to select the most promising parameters.
*   **GCP Context:** This is the optimization strategy used by **Vertex AI Vizier**. It is significantly more efficient than Random or Grid Search.
### Gradient Descent 
An iterative optimization algorithm used to find the minimum of a function. In machine learning, it's the primary method for training models like linear regression and deep neural networks by minimizing the model's loss (error) function. It works by taking steps in the opposite direction of the function's gradient at the current point.



## Activation functions

### Softmax
The Softmax function converts a vector of raw scores (logits) into a probability distribution. [1, 2] Each element in the output vector is between 0 and 1, and the sum of all elements equals 1. [1, 5] It is most often used in the final layer of a neural network for multi-class classification problems where the classes are mutually exclusive. [2, 3] By exponentiating the input values, it amplifies differences, making the model's prediction more pronounced. [1, 5]

*   **Input**: A vector of N real-valued scores (logits).
*   **Process**:
    1.  It calculates the exponential (`e^x`) of each score in the input vector. This makes all values positive.
    2.  It calculates the sum of all these exponential values.
    3.  It divides each individual exponential value by this sum to normalize them.
*   **Output**: A vector of N probabilities that sum to 1, representing the likelihood of each class.

### ELU
The Exponential Linear Unit (ELU) is an activation function that, for positive inputs, acts as an identity function (like ReLU), but for negative inputs, it has a smooth, saturating negative value. [10, 13] This helps to push the mean activations closer to zero, which can speed up learning. [14, 20] Unlike ReLU, ELU can produce negative outputs, which helps mitigate the "dying ReLU" problem where neurons can become permanently inactive. [10, 13] Its smoothness for negative inputs allows for better gradient flow compared to the sharp cutoff of ReLU. [13, 18]

*   **Behavior for positive inputs (x > 0)**: The function outputs `x`, just like ReLU.
*   **Behavior for negative inputs (x <= 0)**: The function outputs `α * (e^x - 1)`, where `α` (alpha) is a hyperparameter that controls the saturation point for negative inputs.
*   **Key Advantages**:
    *   It can produce negative outputs, which helps the network center its activations around zero and can accelerate learning.
    *   It has a non-zero gradient for negative values, preventing the "dying ReLU" problem.

### GELU
The Gaussian Error Linear Unit (GELU) is a smooth activation function that has become prominent in transformer models like BERT and GPT. [4, 6, 9] It weighs inputs by their magnitude rather than gating them strictly by their sign (as ReLU does). [6] GELU introduces a probabilistic element by using the Gaussian cumulative distribution function (CDF) to scale the input, meaning it stochastically determines the output based on the input's value. [8, 21] This non-monotonic and smooth nature helps in modeling complex data patterns more effectively and provides a better optimization landscape for deep models. [6, 9]

*   **Mechanism**: The function is defined as `x * Φ(x)`, where `Φ(x)` is the Cumulative Distribution Function (CDF) for the standard normal distribution.
*   **Intuition**: It "gates" the input `x` based on its value. Inputs with a higher value get a higher weight from the CDF, while inputs that are strongly negative are more likely to be zeroed out. However, unlike ReLU, it can still preserve some negative information.
*   **Properties**:
    *   **Smooth and Differentiable**: It doesn't have the sharp corner found in ReLU, which can aid optimization.
    *   **Non-monotonic**: The function can curve, allowing it to model more complex relationships in the data.
    *   **Stochastic Gating**: It can be interpreted as a probabilistic way of deciding whether to activate a neuron.
