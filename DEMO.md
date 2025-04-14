# AI Piano Learning System Demo Guide

This guide demonstrates how to test and showcase the prototype's features.

## Setup Steps

1. Start the backend server:
   ```bash
   cd backend
   python -m flask run --host=0.0.0.0 --port=5000
   ```

2. Open the web dashboard in a browser:
   - Navigate to http://localhost:5000

3. Simulate piano notes with the API:
   ```bash
   # Play a C major chord (C-E-G)
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 60, "velocity": 100, "timestamp": 1623456789, "isNoteOn": true}, "sessionId": "demo-session-1"}' http://localhost:5000/api/save-note
   
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 64, "velocity": 100, "timestamp": 1623456790, "isNoteOn": true}, "sessionId": "demo-session-1"}' http://localhost:5000/api/save-note
   
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 67, "velocity": 100, "timestamp": 1623456791, "isNoteOn": true}, "sessionId": "demo-session-1"}' http://localhost:5000/api/save-note
   ```

## Demo Scenarios

### 1. Real-time Note Visualization

**Objective:** Demonstrate the web dashboard visualizing notes in real-time.

**Steps:**
1. Open the web dashboard
2. Run the following commands to simulate playing notes:
   ```bash
   # Play C
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 60, "velocity": 100, "timestamp": 1623456789, "isNoteOn": true}, "sessionId": "demo-session-1"}' http://localhost:5000/api/save-note
   
   # Play E
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 64, "velocity": 100, "timestamp": 1623456790, "isNoteOn": true}, "sessionId": "demo-session-1"}' http://localhost:5000/api/save-note
   
   # Play G
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 67, "velocity": 100, "timestamp": 1623456791, "isNoteOn": true}, "sessionId": "demo-session-1"}' http://localhost:5000/api/save-note
   ```
3. Observe the piano visualization showing the played notes

### 2. AI Practice Suggestions

**Objective:** Show how the AI generates practice suggestions based on played notes.

**Steps:**
1. Simulate playing a C major scale:
   ```bash
   # Play C major scale notes
   curl -X POST -H "Content-Type: application/json" -d '{"notes": [{"midiNote": 60, "velocity": 100, "timestamp": 1623456789, "isNoteOn": true}, {"midiNote": 62, "velocity": 100, "timestamp": 1623456790, "isNoteOn": true}, {"midiNote": 64, "velocity": 100, "timestamp": 1623456791, "isNoteOn": true}, {"midiNote": 65, "velocity": 100, "timestamp": 1623456792, "isNoteOn": true}, {"midiNote": 67, "velocity": 100, "timestamp": 1623456793, "isNoteOn": true}, {"midiNote": 69, "velocity": 100, "timestamp": 1623456794, "isNoteOn": true}, {"midiNote": 71, "velocity": 100, "timestamp": 1623456795, "isNoteOn": true}, {"midiNote": 72, "velocity": 100, "timestamp": 1623456796, "isNoteOn": true}], "sessionId": "demo-session-1"}' http://localhost:5000/api/suggestions
   ```
2. View the AI-generated suggestions on the dashboard

### 3. Scale Analysis

**Objective:** Demonstrate how the system identifies the scale being played.

**Steps:**
1. Simulate playing an A minor scale:
   ```bash
   curl -X POST -H "Content-Type: application/json" -d '{"notes": [69, 71, 72, 74, 76, 77, 79, 81]}' http://localhost:5000/api/analyze-scale
   ```
2. Check the analysis output showing "A Minor" scale identification

### 4. Practice History

**Objective:** Show how the system tracks practice sessions over time.

**Steps:**
1. Create several practice sessions:
   ```bash
   # Create another session from yesterday
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 60, "velocity": 100, "timestamp": 1623370389, "isNoteOn": true}, "sessionId": "demo-session-2"}' http://localhost:5000/api/save-note
   
   # Add a few more notes
   curl -X POST -H "Content-Type: application/json" -d '{"note": {"midiNote": 62, "velocity": 100, "timestamp": 1623370390, "isNoteOn": true}, "sessionId": "demo-session-2"}' http://localhost:5000/api/save-note
   ```
2. Navigate to the Practice History tab in the dashboard
3. View the session data and practice statistics

### 5. Daily Goal

**Objective:** Demonstrate the daily practice goal feature.

**Steps:**
1. Fetch the daily goal:
   ```bash
   curl http://localhost:5000/api/daily-goal
   ```
2. Observe the goal displayed on the dashboard

## Complete System Demo

For a full experience demonstration with the mobile piano app:

1. Start the backend server
2. Launch the web dashboard in a browser
3. Run the mobile piano app on a device
4. Play notes on the mobile app
5. Observe the real-time visualization on the web dashboard
6. View the AI suggestions generated based on your playing
7. Check the practice history after your session