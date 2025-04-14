import os
import json
import time
from pathlib import Path
from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import learning_ai

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Initialize the AI module
ai_engine = learning_ai.LearningAI()

# Create data directory for local storage
data_dir = Path('data')
data_dir.mkdir(exist_ok=True)
notes_file = data_dir / 'notes.json'
sessions_file = data_dir / 'sessions.json'

# Initialize local storage files if they don't exist
if not notes_file.exists():
    with open(notes_file, 'w') as f:
        json.dump([], f)

if not sessions_file.exists():
    with open(sessions_file, 'w') as f:
        json.dump({}, f)

@app.route('/')
def index():
    return render_template(
        'index.html',
        prototype_version="1.0"
    )

@app.route('/api/suggestions', methods=['POST'])
def get_suggestions():
    """
    Generate AI suggestions based on played notes
    Expected JSON body:
    {
        "notes": [{"midiNote": 60, "velocity": 100, "timestamp": 1623456789, "isNoteOn": true}, ...],
        "sessionId": "12345"
    }
    """
    try:
        data = request.json
        notes = data.get('notes', [])
        session_id = data.get('sessionId')
        
        if not notes or not session_id:
            return jsonify({
                'error': 'Missing notes or sessionId in request'
            }), 400
        
        # Generate suggestions using the AI engine
        suggestions = ai_engine.generate_suggestions(notes)
        
        # Save suggestions to local storage
        with open(sessions_file, 'r') as f:
            sessions = json.load(f)
        
        if session_id not in sessions:
            sessions[session_id] = {
                'startTime': int(time.time() * 1000),
                'notes': [],
                'deviceInfo': 'Unknown Device'
            }
        
        sessions[session_id]['aiSuggestions'] = suggestions
        sessions[session_id]['lastAnalyzed'] = int(time.time() * 1000)
        
        with open(sessions_file, 'w') as f:
            json.dump(sessions, f)
        
        return jsonify({
            'suggestions': suggestions
        })
    
    except Exception as e:
        print(f"Error generating suggestions: {e}")
        return jsonify({
            'error': 'Failed to generate suggestions'
        }), 500

@app.route('/api/analyze-scale', methods=['POST'])
def analyze_scale():
    """
    Analyze the scale/key based on played notes
    Expected JSON body:
    {
        "notes": [60, 62, 64, 65, 67, 69, 71, 72]  # MIDI note numbers
    }
    """
    try:
        data = request.json
        midi_notes = data.get('notes', [])
        
        if not midi_notes:
            return jsonify({
                'error': 'Missing notes in request'
            }), 400
        
        # Analyze the scale using the AI engine
        scale_info = ai_engine.identify_scale(midi_notes)
        
        return jsonify(scale_info)
    
    except Exception as e:
        print(f"Error analyzing scale: {e}")
        return jsonify({
            'error': 'Failed to analyze scale'
        }), 500

@app.route('/api/progress-report', methods=['GET'])
def progress_report():
    """
    Generate a progress report for a user's practice sessions
    Query parameter: sessionId (optional)
    """
    try:
        session_id = request.args.get('sessionId')
        
        # Load sessions from local storage
        with open(sessions_file, 'r') as f:
            sessions_data = json.load(f)
        
        if not sessions_data:
            return jsonify({
                'error': 'No sessions found'
            }), 404
        
        if session_id:
            # Get specific session data
            if session_id not in sessions_data:
                return jsonify({
                    'error': 'Session not found'
                }), 404
                
            session_data = sessions_data[session_id]
            # Analyze this specific session
            report = ai_engine.analyze_session(session_data)
        else:
            # Get the last 5 sessions for overall progress
            # Sort sessions by start time and get the last 5
            sorted_sessions = dict(sorted(
                sessions_data.items(), 
                key=lambda item: item[1].get('startTime', 0), 
                reverse=True
            )[:5])
            
            if not sorted_sessions:
                return jsonify({
                    'error': 'No sessions found'
                }), 404
            
            # Analyze overall progress
            report = ai_engine.analyze_progress(sorted_sessions)
        
        return jsonify(report)
    
    except Exception as e:
        print(f"Error generating progress report: {e}")
        return jsonify({
            'error': 'Failed to generate progress report'
        }), 500

@app.route('/api/daily-goal', methods=['GET'])
def get_daily_goal():
    """Get the daily practice goal for the user"""
    try:
        # Generate a random daily goal
        daily_goal = ai_engine.generate_daily_goal()
        
        return jsonify({
            'goal': daily_goal
        })
    
    except Exception as e:
        print(f"Error generating daily goal: {e}")
        return jsonify({
            'error': 'Failed to generate daily goal'
        }), 500

# New endpoint to save note data
@app.route('/api/save-note', methods=['POST'])
def save_note():
    """
    Save a note to local storage
    Expected JSON body:
    {
        "note": {"midiNote": 60, "velocity": 100, "timestamp": 1623456789, "isNoteOn": true},
        "sessionId": "12345"
    }
    """
    try:
        data = request.json
        note = data.get('note', {})
        session_id = data.get('sessionId')
        
        if not note or not session_id:
            return jsonify({
                'error': 'Missing note or sessionId in request'
            }), 400
        
        # Add note to real-time notes
        with open(notes_file, 'r') as f:
            notes = json.load(f)
        
        # Keep only the last 20 notes (to simulate real-time)
        if len(notes) >= 20:
            notes.pop(0)
        
        notes.append(note)
        
        with open(notes_file, 'w') as f:
            json.dump(notes, f)
        
        # Add note to session
        with open(sessions_file, 'r') as f:
            sessions = json.load(f)
        
        if session_id not in sessions:
            sessions[session_id] = {
                'startTime': int(time.time() * 1000),
                'notes': [],
                'deviceInfo': 'Mobile Piano App',
                'mode': 'practice'
            }
        
        sessions[session_id]['notes'].append(note)
        
        with open(sessions_file, 'w') as f:
            json.dump(sessions, f)
        
        return jsonify({
            'success': True
        })
    
    except Exception as e:
        print(f"Error saving note: {e}")
        return jsonify({
            'error': 'Failed to save note'
        }), 500

# Get real-time notes
@app.route('/api/notes', methods=['GET'])
def get_notes():
    """Get real-time notes"""
    try:
        with open(notes_file, 'r') as f:
            notes = json.load(f)
        
        return jsonify({
            'notes': notes
        })
    
    except Exception as e:
        print(f"Error getting notes: {e}")
        return jsonify({
            'error': 'Failed to get notes'
        }), 500

# Get sessions
@app.route('/api/sessions', methods=['GET'])
def get_sessions():
    """Get all practice sessions"""
    try:
        with open(sessions_file, 'r') as f:
            sessions = json.load(f)
        
        # Format for easier consumption by the client
        formatted_sessions = []
        for session_id, session_data in sessions.items():
            session_data['id'] = session_id
            formatted_sessions.append(session_data)
        
        # Sort by start time (newest first)
        formatted_sessions.sort(key=lambda s: s.get('startTime', 0), reverse=True)
        
        return jsonify({
            'sessions': formatted_sessions
        })
    
    except Exception as e:
        print(f"Error getting sessions: {e}")
        return jsonify({
            'error': 'Failed to get sessions'
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
