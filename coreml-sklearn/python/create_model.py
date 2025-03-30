import coremltools as ct
import numpy as np
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression

# Generate sample data
# n_features=2: number of features
# n_informative=2: number of informative features for classification
# n_redundant=0: number of redundant features
# n_repeated=0: number of repeated features
X, y = make_classification(
    n_samples=1000,
    n_features=2,
    n_informative=2,
    n_redundant=0,
    n_repeated=0,
    random_state=42
)

# Train the model
model = LogisticRegression(multi_class='ovr')  # One-vs-Rest multiclass strategy
model.fit(X, y)

# Create CoreML model
mlmodel = ct.converters.sklearn.convert(
    model
)

# Save the model
mlmodel.save("SimpleClassifier.mlmodel")
