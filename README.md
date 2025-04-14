# AI-Powered Piano Learning System

This prototype demonstrates a dual-device piano learning system with AI-powered suggestions and feedback. The system consists of three main components:

1. **Mobile Piano App** - A Flutter mobile application that serves as the piano keyboard interface
2. **Web Dashboard** - A Flutter web application that displays real-time feedback and visualizations
3. **Backend Server** - A Flask server that processes data, generates AI suggestions, and handles communication between components

## System Architecture

### Mobile Piano App
- Provides a touch interface simulating a piano keyboard
- Captures note press/release events and sends them to the backend
- Supports various playing modes (practice, freestyle)
- Features volume and sustain controls

### Web Dashboard
- Displays real-time visualization of played notes
- Shows AI-generated practice suggestions
- Provides practice history and statistics
- Presents daily practice goals

### Backend Server
- Processes note data using AI algorithms
- Generates practice suggestions based on playing patterns
- Analyzes which scales/chords are being played
- Tracks practice sessions and provides progress reports

## Data Flow
1. User presses keys on the mobile piano app
2. Note data is sent to the backend server
3. Backend processes the data and updates real-time note information
4. Web dashboard fetches current note data and displays visualizations
5. AI engine analyzes played notes and generates suggestions
6. Suggestions are served to the web dashboard

## Local Storage Implementation
For this prototype, all data is stored locally on the server using simple JSON files:
- `notes.json`: Stores the most recent notes being played (real-time data)
- `sessions.json`: Stores practice session history and associated note data

## Running the Prototype

### Backend Server
```bash
cd backend
python -m flask run --host=0.0.0.0 --port=5000
```

### Mobile Piano App
```bash
cd piano_app
flutter run -d <device_id>
```
Replace `<device_id>` with your mobile device ID or emulator.

### Web Dashboard
```bash
cd web_dashboard
flutter run -d chrome
```

## API Endpoints

The backend provides the following API endpoints:

- `GET /api/notes` - Get real-time notes being played
- `POST /api/save-note` - Save a new note event
- `GET /api/sessions` - Get practice session history
- `POST /api/suggestions` - Get AI-generated practice suggestions
- `POST /api/analyze-scale` - Analyze what scale is being played
- `GET /api/daily-goal` - Get the daily practice goal
- `GET /api/progress-report` - Get a progress report for sessions

## Future Enhancements

1. Real audio sampling for the piano app
2. User authentication and profiles
3. Enhanced AI suggestions based on learning progress
4. Sheet music integration and sight-reading exercises
5. Multiplayer/teacher-student interaction
6. More detailed analytics and progress tracking