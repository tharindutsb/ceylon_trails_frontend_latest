"""
Ceylon Trails Backend API Server
Handles ML predictions for itinerary planning
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import numpy as np
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Load trained model
MODEL_PATH = 'model/itinerary_model.pkl'
if os.path.exists(MODEL_PATH):
    model = joblib.load(MODEL_PATH)
    print(f"Model loaded from {MODEL_PATH}")
else:
    model = None
    print(f"Model not found at {MODEL_PATH}. Please train the model first.")

# Load location encodings
LOCATION_ENCODINGS_PATH = 'model/location_encodings.pkl'
if os.path.exists(LOCATION_ENCODINGS_PATH):
    location_encodings = joblib.load(LOCATION_ENCODINGS_PATH)
else:
    location_encodings = {}
    print("Location encodings not found. Creating new encodings.")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None
    })

@app.route('/api/predict/suitability', methods=['POST'])
def predict_suitability():
    """Predict location suitability for a group"""
    try:
        data = request.json
        
        if model is None:
            return jsonify({
                'error': 'Model not loaded. Please train the model first.'
            }), 503
        
        # Extract features from request
        group_size = data.get('group_size', 1)
        min_age = data.get('min_age', 30)
        max_age = data.get('max_age', 50)
        n_fully_mobile = data.get('n_fully_mobile', group_size)
        n_assisted = data.get('n_assisted', 0)
        n_wheelchair_user = data.get('n_wheelchair_user', 0)
        n_limited_endurance = data.get('n_limited_endurance', 0)
        n_child_carried = data.get('n_child_carried', 0)
        has_wheelchair_user = n_wheelchair_user > 0
        
        location_name = data.get('location_name', '')
        location_type = data.get('location_type', 'cultural')
        terrain_level = data.get('terrain_level', 'flat')
        accessibility = data.get('accessibility', 'full')
        heat_exposure_level = data.get('heat_exposure_level', 'medium')
        preferred_visit_start = data.get('preferred_visit_start', '08:00')
        preferred_visit_end = data.get('preferred_visit_end', '17:00')
        best_time_window = data.get('best_time_window', 'Morning')
        
        # Encode categorical features
        terrain_encoded = {'flat': 0, 'mild_elevation': 1, 'hilly': 2, 'steep': 3, 'mixed': 4}.get(terrain_level, 0)
        accessibility_encoded = {'full': 0, 'partial': 1, 'limited': 2}.get(accessibility, 0)
        heat_encoded = {'low': 0, 'medium': 1, 'high': 2}.get(heat_exposure_level, 1)
        location_type_encoded = {'nature': 0, 'religious': 1, 'cultural': 2, 'shopping': 3}.get(location_type, 2)
        
        time_window_encoded = {'Morning': 0, 'Midday': 1, 'Afternoon': 2, 'Evening': 3}.get(best_time_window, 1)
        
        # Parse time to cyclical encoding (sin/cos)
        start_hour, start_min = map(int, preferred_visit_start.split(':'))
        start_time_total_min = start_hour * 60 + start_min
        start_time_sin = np.sin(2 * np.pi * start_time_total_min / 1440)
        start_time_cos = np.cos(2 * np.pi * start_time_total_min / 1440)
        
        # Feature vector (in order of training)
        features = np.array([[
            group_size,
            min_age,
            max_age,
            n_fully_mobile,
            n_assisted,
            n_wheelchair_user,
            n_limited_endurance,
            n_child_carried,
            1 if has_wheelchair_user else 0,
            terrain_encoded,
            accessibility_encoded,
            heat_encoded,
            location_type_encoded,
            time_window_encoded,
            start_time_sin,
            start_time_cos,
        ]])
        
        # Get prediction
        suitability_score = float(model.predict(features)[0])
        is_suitable = suitability_score >= 0.5
        
        # Calculate recommended duration (in minutes)
        base_duration = 60
        if terrain_level in ['hilly', 'steep']:
            base_duration += 20
        if location_type == 'cultural':
            base_duration += 30
        if group_size >= 5:
            base_duration += 15
        if has_wheelchair_user:
            base_duration += 20
        
        # Adjust based on predicted suitability
        if not is_suitable:
            base_duration = int(base_duration * 0.8)
        
        return jsonify({
            'suitability_score': float(suitability_score),
            'is_suitable': bool(is_suitable),
            'recommended_duration_min': int(base_duration),
            'best_time_window': best_time_window,
            'confidence': float(np.clip(abs(suitability_score - 0.5) * 2, 0, 1))
        })
        
    except Exception as e:
        return jsonify({
            'error': str(e)
        }), 400

@app.route('/api/predict/duration', methods=['POST'])
def predict_duration():
    """Predict visit duration for a location"""
    try:
        data = request.json
        
        location_type = data.get('location_type', 'cultural')
        terrain_level = data.get('terrain_level', 'flat')
        group_size = data.get('group_size', 1)
        has_accessibility_needs = data.get('has_accessibility_needs', False)
        
        # Base duration by location type
        duration_map = {
            'nature': 60,
            'religious': 45,
            'cultural': 90,
            'shopping': 120
        }
        base_duration = duration_map.get(location_type, 60)
        
        # Adjustments
        if terrain_level in ['hilly', 'steep']:
            base_duration += 15
        if group_size >= 5:
            base_duration += 10
        if has_accessibility_needs:
            base_duration += 20
        
        return jsonify({
            'duration_min': int(base_duration),
            'estimated_variance_min': 15
        })
        
    except Exception as e:
        return jsonify({
            'error': str(e)
        }), 400

@app.route('/api/optimize/itinerary', methods=['POST'])
def optimize_itinerary():
    """Optimize itinerary with meal times and travel durations"""
    try:
        data = request.json
        
        locations = data.get('locations', [])
        start_time = data.get('start_time', '08:00')
        end_time = data.get('end_time', '18:00')
        include_breakfast = data.get('include_breakfast', True)
        include_lunch = data.get('include_lunch', True)
        include_dinner = data.get('include_dinner', True)
        
        if not locations:
            return jsonify({
                'error': 'No locations provided'
            }), 400
        
        # Parse times
        start_hour, start_min = map(int, start_time.split(':'))
        end_hour, end_min = map(int, end_time.split(':'))
        start_total_min = start_hour * 60 + start_min
        end_total_min = end_hour * 60 + end_min
        available_minutes = end_total_min - start_total_min
        
        # Calculate meal times
        breakfast_time = start_total_min
        lunch_time = start_total_min + (end_total_min - start_total_min) // 2
        dinner_time = end_total_min - 60  # 1 hour before end
        
        # Optimize itinerary
        optimized_schedule = []
        current_time = start_total_min
        
        for i, location in enumerate(locations):
            # Check if we need to add breakfast
            if include_breakfast and i == 0 and current_time < breakfast_time + 60:
                optimized_schedule.append({
                    'type': 'meal',
                    'name': 'Breakfast',
                    'start_time': f"{breakfast_time // 60:02d}:{breakfast_time % 60:02d}",
                    'duration_min': 30
                })
                current_time = breakfast_time + 30
            
            # Add location
            duration = location.get('duration_min', 60)
            travel_time = 15 if i > 0 else 0  # Add travel time between locations
            
            optimized_schedule.append({
                'type': 'location',
                'name': location.get('name', 'Unknown'),
                'start_time': f"{current_time // 60:02d}:{current_time % 60:02d}",
                'duration_min': duration
            })
            current_time += duration + travel_time
            
            # Check if we need to add lunch
            if include_lunch and lunch_time <= current_time <= lunch_time + 120:
                optimized_schedule.append({
                    'type': 'meal',
                    'name': 'Lunch Break',
                    'start_time': f"{lunch_time // 60:02d}:{lunch_time % 60:02d}",
                    'duration_min': 45
                })
                current_time = lunch_time + 45
            
            # Check if we need to add dinner
            if include_dinner and i == len(locations) - 1:
                optimized_schedule.append({
                    'type': 'meal',
                    'name': 'Dinner',
                    'start_time': f"{dinner_time // 60:02d}:{dinner_time % 60:02d}",
                    'duration_min': 60
                })
                current_time = dinner_time + 60
        
        return jsonify({
            'optimized_schedule': optimized_schedule,
            'total_duration_min': current_time - start_total_min
        })
        
    except Exception as e:
        return jsonify({
            'error': str(e)
        }), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

