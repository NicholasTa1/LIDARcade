import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import coremltools

# Load the dataset (assumed to have only "Accuracy", "Score", and "Goal Score" columns)
df = pd.read_csv("accuracy_scores_100_rows.csv")

# (Optional) Clean the dataset: drop rows with missing values and reset the index.
df.dropna(inplace=True)
df.reset_index(drop=True, inplace=True)

# Define features and target
X = df[["Accuracy", "Score"]]
y = df["Goal Score"]

# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Create and fit the StandardScaler on the training data
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# Train the Linear Regression model on scaled training data
model = LinearRegression()
model.fit(X_train_scaled, y_train)

# Evaluate model performance using the R² score
X_test_scaled = scaler.transform(X_test)
score = model.score(X_test_scaled, y_test)
print("Model R² Score:", score)

# Create a pipeline that combines scaling and regression
pipeline = Pipeline([
    ('scaler', scaler),
    ('regressor', model)
])

# Convert the pipeline into a Core ML model.
coreml_model = coremltools.converters.sklearn.convert(
    pipeline,
    input_features=["Accuracy", "Score"],
    output_feature_names="Goal Score"
)

# Optionally, print the Core ML model summary and save it.
print(coreml_model)
coreml_model.save("LidarMLModel.mlmodel")

