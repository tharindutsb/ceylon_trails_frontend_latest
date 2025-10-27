# Ceylon Trails Backend API

Machine Learning backend for itinerary suitability predictions.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Train the model:
```bash
python train_model.py
```

3. Start the server:
```bash
python app.py
```

The server will run on `http://localhost:5000`

## API Endpoints

### Health Check
`GET /health`

### Predict Suitability
`POST /api/predict/suitability`

Request body:
```json
{
  "group_size": 2,
  "min_age": 19,
  "max_age": 56,
  "n_fully_mobile": 1,
  "n_assisted": 1,
  "n_wheelchair_user": 0,
  "n_limited_endurance": 0,
  "n_child_carried": 0,
  "location_name": "Royal Botanic Gardens",
  "location_type": "nature",
  "terrain_level": "flat",
  "accessibility": "full",
  "heat_exposure_level": "high",
  "preferred_visit_start": "08:00",
  "preferred_visit_end": "11:00",
  "best_time_window": "Morning"
}
```

Response:
```json
{
  "suitability_score": 0.85,
  "is_suitable": true,
  "recommended_duration_min": 90,
  "best_time_window": "Morning",
  "confidence": 0.7
}
```

### Optimize Itinerary
`POST /api/optimize/itinerary`

Request body:
```json
{
  "locations": [
    {"name": "Location 1", "duration_min": 60},
    {"name": "Location 2", "duration_min": 90}
  ],
  "start_time": "08:00",
  "end_time": "18:00",
  "include_breakfast": true,
  "include_lunch": true,
  "include_dinner": true
}
```

