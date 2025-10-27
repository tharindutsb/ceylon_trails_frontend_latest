"""
Train ML model for itinerary suitability prediction
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
import joblib
import os

def train_model():
    """Train the model on the dataset"""
    print("Starting model training...")
    
    # Load dataset
    dataset_path = '../test/dataset/ceylon_trails_synthetic_v2.csv'
    
    if not os.path.exists(dataset_path):
        print(f"Dataset not found at {dataset_path}")
        print("Please ensure the dataset is in the correct location.")
        return
    
    print("Loading dataset...")
    df = pd.read_csv(dataset_path)
    print(f"Loaded {len(df)} records")
    
    # Prepare features
    print("Preparing features...")
    
    # Map categorical to numeric
    terrain_map = {'flat': 0, 'mild_elevation': 1, 'hilly': 2, 'steep': 3, 'mixed': 4}
    accessibility_map = {'full': 0, 'partial': 1, 'limited': 2}
    heat_map = {'low': 0, 'medium': 1, 'high': 2}
    location_type_map = {'nature': 0, 'religious': 1, 'cultural': 2, 'shopping': 3}
    time_window_map = {'Morning': 0, 'Midday': 1, 'Afternoon': 2, 'Evening': 3}
    
    df['terrain_encoded'] = df['terrain_level'].map(terrain_map).fillna(0)
    df['accessibility_encoded'] = df['accessibility'].map(accessibility_map).fillna(0)
    df['heat_encoded'] = df['heat_exposure_level'].map(heat_map).fillna(1)
    df['location_type_encoded'] = df['location_type'].map(location_type_map).fillna(2)
    df['time_window_encoded'] = df['best_time_window'].map(time_window_map).fillna(1)
    
    # Parse time to cyclical encoding (sin/cos)
    def parse_time(time_str):
        hour, min = map(int, time_str.split(':'))
        return hour * 60 + min
    
    df['start_time_total_min'] = df['preferred_visit_start'].apply(parse_time)
    df['start_time_sin'] = np.sin(2 * np.pi * df['start_time_total_min'] / 1440)
    df['start_time_cos'] = np.cos(2 * np.pi * df['start_time_total_min'] / 1440)
    
    # Select features
    feature_columns = [
        'group_size',
        'min_age',
        'max_age',
        'n_fully_mobile',
        'n_assisted',
        'n_wheelchair_user',
        'n_limited_endurance',
        'n_child_carried',
        'has_wheelchair_user',
        'terrain_encoded',
        'accessibility_encoded',
        'heat_encoded',
        'location_type_encoded',
        'time_window_encoded',
        'start_time_sin',
        'start_time_cos',
    ]
    
    X = df[feature_columns]
    y = df['suitability_score']  # Using suitability_score as target
    
    print(f"Features shape: {X.shape}")
    print(f"Target shape: {y.shape}")
    
    # Split data
    print("Splitting data...")
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    print(f"Training set: {len(X_train)} samples")
    print(f"Test set: {len(X_test)} samples")
    
    # Train model
    print("Training Random Forest model...")
    model = RandomForestRegressor(
        n_estimators=100,
        max_depth=10,
        min_samples_split=5,
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1
    )
    
    model.fit(X_train, y_train)
    
    # Evaluate
    train_score = model.score(X_train, y_train)
    test_score = model.score(X_test, y_test)
    
    print(f"\nModel Performance:")
    print(f"Training R² score: {train_score:.4f}")
    print(f"Test R² score: {test_score:.4f}")
    
    # Feature importance
    print("\nFeature Importance:")
    feature_importance = list(zip(feature_columns, model.feature_importances_))
    feature_importance.sort(key=lambda x: x[1], reverse=True)
    for feature, importance in feature_importance:
        print(f"  {feature}: {importance:.4f}")
    
    # Save model
    os.makedirs('model', exist_ok=True)
    model_path = 'model/itinerary_model.pkl'
    joblib.dump(model, model_path)
    print(f"\nModel saved to {model_path}")
    
    # Save feature names for reference
    feature_info = {
        'feature_names': feature_columns,
        'feature_importance': dict(feature_importance)
    }
    joblib.dump(feature_info, 'model/feature_info.pkl')
    print("Feature info saved")
    
    print("\nTraining completed successfully!")

if __name__ == '__main__':
    train_model()

