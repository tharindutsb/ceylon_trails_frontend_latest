# Ceylon Trails - Complete Project Setup Guide

## Overview
This is a complete travel itinerary planning app with:
- ✅ Real-time GPS tracking
- ✅ Weather API integration (Open-Meteo)
- ✅ Machine Learning backend for suitability predictions
- ✅ Meal time scheduling (Breakfast, Lunch, Dinner)
- ✅ Enhanced itinerary optimization
- ✅ Bottom navigation on all screens

## Prerequisites

### Backend (Python)
- Python 3.8+
- pip

### Frontend (Flutter)
- Flutter SDK 3.3.0 or higher
- Android Studio / VS Code
- Android SDK or iOS SDK

## Setup Instructions

### 1. Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Create a virtual environment (recommended):
```bash
python -m venv venv

# On Windows:
venv\Scripts\activate

# On Mac/Linux:
source venv/bin/activate
```

3. Install Python dependencies:
```bash
pip install -r requirements.txt
```

4. Train the ML model:
```bash
python train_model.py
```

This will:
- Load the dataset from `test/dataset/ceylon_trails_synthetic_v2.csv`
- Train a Random Forest model
- Save the model to `model/itinerary_model.pkl`

5. Start the backend server:
```bash
python app.py
```

The server will run on `http://localhost:5000`

### 2. Frontend Setup (Flutter)

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
# For Android:
flutter run

# For iOS (Mac only):
flutter run -d ios

# For web:
flutter run -d chrome
```

## Key Features

### 1. Machine Learning Predictions
The backend provides AI-powered suitability predictions for locations based on:
- Group size and composition
- Age ranges
- Mobility needs (wheelchair users, elderly, children)
- Terrain and accessibility
- Heat exposure levels
- Time preferences

### 2. Real-Time GPS Tracking
The app tracks your trip in real-time using GPS:
- Automatic location updates every 10 meters
- Distance calculations to destinations
- Travel time estimation
- Arrival confirmation

### 3. Weather Integration
Real-time weather data using Open-Meteo API:
- Current conditions
- Temperature and humidity
- Weather recommendations for travel
- Location-based forecasts

### 4. Meal Time Scheduling
Automatic meal time insertion into itineraries:
- **Breakfast**: 30 minutes at trip start
- **Lunch**: 45 minutes at midday
- **Dinner**: 60 minutes before trip end

Can be enabled/disabled in trip settings.

### 5. Enhanced Itinerary Optimization
Smart algorithm that:
- Sorts locations by preferred visit times
- Accounts for travel durations
- Includes buffer times for transitions
- Optimizes for accessibility needs
- Adjusts for group size

### 6. Bottom Navigation
Persistent navigation available on all screens:
- Home (Planning hub)
- Explore (Browse locations)
- Schedule (Active trips)
- Profile (Settings & account)

## API Endpoints

### Predict Suitability
```http
POST /api/predict/suitability
Content-Type: application/json

{
  "group_size": 2,
  "min_age": 19,
  "max_age": 56,
  "n_fully_mobile": 1,
  "n_assisted": 1,
  "location_name": "Royal Botanic Gardens",
  "location_type": "nature",
  "terrain_level": "flat",
  "accessibility": "full",
  "heat_exposure_level": "high"
}
```

### Optimize Itinerary
```http
POST /api/optimize/itinerary
Content-Type: application/json

{
  "locations": [...],
  "start_time": "08:00",
  "end_time": "18:00",
  "include_breakfast": true,
  "include_lunch": true,
  "include_dinner": true
}
```

## Project Structure

```
ceylon_trails_frontend_latest/
├── backend/                    # Python Flask API
│   ├── app.py                 # Main server
│   ├── train_model.py         # ML model training
│   ├── requirements.txt       # Python dependencies
│   └── model/                 # Trained models
│
├── lib/
│   ├── features/              # Feature modules
│   │   ├── home/              # Home page
│   │   ├── plan/              # Trip planning
│   │   ├── schedule/          # Schedule builder
│   │   ├── tracking/           # Live tracking
│   │   └── profile/             # User profile
│   │
│   ├── core/
│   │   ├── models/             # Data models
│   │   ├── services/           # Business logic
│   │   │   ├── weather_service.dart
│   │   │   ├── live_tracking_service.dart
│   │   │   ├── itinerary_optimizer.dart
│   │   │   └── backend_api_service.dart
│   │   ├── router/             # Navigation
│   │   └── theme/              # App theming
│   │
│   └── widgets/                # Reusable widgets
│
└── test/dataset/               # Training dataset
    └── ceylon_trails_synthetic_v2.csv
```

## Testing

### Backend
```bash
cd backend
python -m pytest tests/
```

### Frontend
```bash
flutter test
```

## Running the Full Stack

### Terminal 1 - Backend
```bash
cd backend
python app.py
```

### Terminal 2 - Flutter App
```bash
flutter run
```

## Configuration

### Backend Port
Edit `lib/core/services/backend_api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:5000';
```

### Weather API
Already configured to use Open-Meteo (no API key required)

### GPS Settings
Configured in `lib/core/services/live_tracking_service.dart`:
- Accuracy: High
- Distance filter: 10 meters
- Update interval: 30 seconds

## Troubleshooting

### Backend won't start
- Check if port 5000 is available
- Verify Python version (3.8+)
- Ensure all dependencies are installed

### ML Model not found
- Run `python train_model.py` first
- Check that dataset exists at `test/dataset/ceylon_trails_synthetic_v2.csv`

### Flutter build errors
```bash
flutter clean
flutter pub get
flutter run
```

### GPS not working
- Check device location permissions
- Verify location services are enabled
- On Android, add permissions in AndroidManifest.xml
- On iOS, add location permissions in Info.plist

## Next Steps

1. ✅ Backend API created
2. ✅ ML model training implemented
3. ✅ GPS tracking added
4. ✅ Weather integration complete
5. ✅ Meal times integrated
6. ✅ Bottom navigation implemented

## Future Enhancements

- Multi-day trip support
- Offline mode
- Social sharing
- User reviews and ratings
- Push notifications for weather alerts
- Cloud sync

## Support

For issues or questions, please contact the development team.

