import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import pickle

# Load the dataset
df = pd.read_csv("accuracy_scores_100_rows.csv")
df.dropna(inplace=True)
df.reset_index(drop=True, inplace=True)

# Define features and target
X = df[["Accuracy", "Score"]]
y = df["Goal Score"]

# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Create and fit the StandardScaler
scaler = StandardScaler()
scaler.fit(X_train)

# Train the Linear Regression model on scaled data
model = LinearRegression()
model.fit(scaler.transform(X_train), y_train)

# Optional: Save the model separately
with open('linear_regression_model.pkl', 'wb') as f:
    pickle.dump(model, f)
# Create a pipeline that combines scaling and regression
pipeline = Pipeline([
    ('scaler', scaler),
    ('regressor', model)
])


# Test the pipeline on an example input
example_input = {"Accuracy": 0.9, "Score": 0.8}
# Note: If needed, convert the input to a DataFrame or array as expected by the pipeline.
import numpy as np
test_values = [[example_input["Accuracy"], example_input["Score"]]]
prediction = pipeline.predict(test_values)
print("Prediction:", prediction)



import coremltools

# Convert the pipeline into a Core ML model.
coreml_model = coremltools.converters.sklearn.convert(
    pipeline,
    input_features=["Accuracy", "Score"],
    output_feature_names="Goal Score"
)

# Optionally, view a summary of the Core ML model.
print(coreml_model)


coreml_model.save("LidarMLModel.mlmodel")


# Load the Core ML model for testing
loaded_model = coremltools.models.MLModel("LidarMLModel.mlmodel")

# Make a prediction with the Core ML model
example_input = {"Accuracy": 0.9, "Score": 0.8}
coreml_prediction = loaded_model.predict(example_input)
print("Core ML Prediction:", coreml_prediction)
