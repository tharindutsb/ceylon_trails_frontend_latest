"""
Ceylon Trails Backend API Server
Handles ML predictions for itinerary planning using FastAPI
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional
import pandas as pd
import joblib
import numpy as np
from datetime import datetime
import os

app = FastAPI(
    title="Ceylon Trails API",
    description="ML-powered itinerary planning API for Ceylon Trails",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

# Pydantic models for request/response validation
class HealthResponse(BaseModel):
    status: str
    model_loaded: bool

class SuitabilityRequest(BaseModel):
    group_size: int = Field(default=1, ge=1)
    min_age: int = Field(default=30, ge=0)
    max_age: int = Field(default=50, ge=0)
    n_fully_mobile: int = Field(default=1, ge=0)
    n_assisted: int = Field(default=0, ge=0)
    n_wheelchair_user: int = Field(default=0, ge=0)
    n_limited_endurance: int = Field(default=0, ge=0)
    n_child_carried: int = Field(default=0, ge=0)
    location_name: str = ""
    location_type: str = Field(default="cultural")
    terrain_level: str = Field(default="flat")
    accessibility: str = Field(default="full")
    heat_exposure_level: str = Field(default="medium")
    preferred_visit_start: str = Field(default="08:00")
    preferred_visit_end: str = Field(default="17:00")
    best_time_window: str = Field(default="Morning")

class SuitabilityResponse(BaseModel):
    suitability_score: float
    is_suitable: bool
    recommended_duration_min: int
    best_time_window: str
    confidence: float

class DurationRequest(BaseModel):
    location_type: str = Field(default="cultural")
    terrain_level: str = Field(default="flat")
    group_size: int = Field(default=1, ge=1)
    has_accessibility_needs: bool = Field(default=False)

class DurationResponse(BaseModel):
    duration_min: int
    estimated_variance_min: int

class Location(BaseModel):
    name: str
    duration_min: int = Field(default=60)

class ItineraryRequest(BaseModel):
    locations: List[Location]
    start_time: str = Field(default="08:00")
    end_time: str = Field(default="18:00")
    include_breakfast: bool = Field(default=True)
    include_lunch: bool = Field(default=True)
    include_dinner: bool = Field(default=True)

class ScheduleItem(BaseModel):
    type: str
    name: str
    start_time: str
    duration_min: int

class ItineraryResponse(BaseModel):
    optimized_schedule: List[ScheduleItem]
    total_duration_min: int

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return {
        'status': 'healthy',
        'model_loaded': model is not None
    }

@app.post("/api/predict/suitability", response_model=SuitabilityResponse)
async def predict_suitability(request: SuitabilityRequest):
    """Predict location suitability for a group"""
    if model is None:
        raise HTTPException(
            status_code=503,
            detail='Model not loaded. Please train the model first.'
        )
    
    try:
        # Extract features from request
        has_wheelchair_user = request.n_wheelchair_user > 0
        
        # Encode categorical features
        terrain_encoded = {
            'flat': 0, 'mild_elevation': 1, 'hilly': 2, 
            'steep': 3, 'mixed': 4
        }.get(request.terrain_level, 0)
        
        accessibility_encoded = {
            'full': 0, 'partial': 1, 'limited': 2
        }.get(request.accessibility, 0)
        
        heat_encoded = {
            'low': 0, 'medium': 1, 'high': 2
        }.get(request.heat_exposure_level, 1)
        
        location_type_encoded = {
            'nature': 0, 'religious': 1, 'cultural': 2, 'shopping': 3
        }.get(request.location_type, 2)
        
        time_window_encoded = {
            'Morning': 0, 'Midday': 1, 'Afternoon': 2, 'Evening': 3
        }.get(request.best_time_window, 1)
        
        # Parse time to cyclical encoding (sin/cos)
        start_hour, start_min = map(int, request.preferred_visit_start.split(':'))
        start_time_total_min = start_hour * 60 + start_min
        start_time_sin = np.sin(2 * np.pi * start_time_total_min / 1440)
        start_time_cos = np.cos(2 * np.pi * start_time_total_min / 1440)
        
        # Feature vector
        features = np.array([[
            request.group_size,
            request.min_age,
            request.max_age,
            request.n_fully_mobile,
            request.n_assisted,
            request.n_wheelchair_user,
            request.n_limited_endurance,
            request.n_child_carried,
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
        
        # Calculate recommended duration
        base_duration = 60
        if request.terrain_level in ['hilly', 'steep']:
            base_duration += 20
        if request.location_type == 'cultural':
            base_duration += 30
        if request.group_size >= 5:
            base_duration += 15
        if has_wheelchair_user:
            base_duration += 20
        
        if not is_suitable:
            base_duration = int(base_duration * 0.8)
        
        return {
            'suitability_score': float(suitability_score),
            'is_suitable': bool(is_suitable),
            'recommended_duration_min': int(base_duration),
            'best_time_window': request.best_time_window,
            'confidence': float(np.clip(abs(suitability_score - 0.5) * 2, 0, 1))
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/predict/duration", response_model=DurationResponse)
async def predict_duration(request: DurationRequest):
    """Predict visit duration for a location"""
    try:
        # Base duration by location type
        duration_map = {
            'nature': 60,
            'religious': 45,
            'cultural': 90,
            'shopping': 120
        }
        base_duration = duration_map.get(request.location_type, 60)
        
        # Adjustments
        if request.terrain_level in ['hilly', 'steep']:
            base_duration += 15
        if request.group_size >= 5:
            base_duration += 10
        if request.has_accessibility_needs:
            base_duration += 20
        
        return {
            'duration_min': int(base_duration),
            'estimated_variance_min': 15
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/optimize/itinerary", response_model=ItineraryResponse)
async def optimize_itinerary(request: ItineraryRequest):
    """Optimize itinerary with meal times and travel durations"""
    try:
        if not request.locations:
            raise HTTPException(
                status_code=400,
                detail='No locations provided'
            )
        
        # Parse times
        start_hour, start_min = map(int, request.start_time.split(':'))
        end_hour, end_min = map(int, request.end_time.split(':'))
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
        
        for i, location in enumerate(request.locations):
            # Check if we need to add breakfast
            if request.include_breakfast and i == 0 and current_time < breakfast_time + 60:
                optimized_schedule.append(ScheduleItem(
                    type='meal',
                    name='Breakfast',
                    start_time=f"{breakfast_time // 60:02d}:{breakfast_time % 60:02d}",
                    duration_min=30
                ))
                current_time = breakfast_time + 30
            
            # Add location
            travel_time = 15 if i > 0 else 0  # Add travel time between locations
            
            optimized_schedule.append(ScheduleItem(
                type='location',
                name=location.name,
                start_time=f"{current_time // 60:02d}:{current_time % 60:02d}",
                duration_min=location.duration_min
            ))
            current_time += location.duration_min + travel_time
            
            # Check if we need to add lunch
            if request.include_lunch and lunch_time <= current_time <= lunch_time + 120:
                optimized_schedule.append(ScheduleItem(
                    type='meal',
                    name='Lunch Break',
                    start_time=f"{lunch_time // 60:02d}:{lunch_time % 60:02d}",
                    duration_min=45
                ))
                current_time = lunch_time + 45
            
            # Check if we need to add dinner
            if request.include_dinner and i == len(request.locations) - 1:
                optimized_schedule.append(ScheduleItem(
                    type='meal',
                    name='Dinner',
                    start_time=f"{dinner_time // 60:02d}:{dinner_time % 60:02d}",
                    duration_min=60
                ))
                current_time = dinner_time + 60
        
        return {
            'optimized_schedule': optimized_schedule,
            'total_duration_min': current_time - start_total_min
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)