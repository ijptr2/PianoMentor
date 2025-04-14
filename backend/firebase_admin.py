import os
import firebase_admin
from firebase_admin import credentials, db
from datetime import datetime

class FirebaseAdmin:
    """
    Helper class for Firebase admin operations
    """
    def __init__(self):
        # Initialize Firebase Admin SDK if not already initialized
        if not firebase_admin._apps:
            cred = credentials.Certificate({
                "type": "service_account",
                "project_id": os.environ.get("FIREBASE_PROJECT_ID", ""),
                "private_key": os.environ.get("FIREBASE_PRIVATE_KEY", "").replace('\\n', '\n'),
                "client_email": os.environ.get("FIREBASE_CLIENT_EMAIL", ""),
                "token_uri": "https://oauth2.googleapis.com/token",
            })
            
            firebase_admin.initialize_app(cred, {
                'databaseURL': f"https://{os.environ.get('FIREBASE_PROJECT_ID')}.firebaseio.com/"
            })
    
    def get_sessions(self, limit=10):
        """
        Get recent practice sessions
        
        Args:
            limit: Maximum number of sessions to retrieve
            
        Returns:
            Dict of session data
        """
        try:
            ref = db.reference('sessions')
            sessions = ref.order_by_child('startTime').limit_to_last(limit).get()
            return sessions
        except Exception as e:
            print(f"Error retrieving sessions: {e}")
            return {}
    
    def get_session(self, session_id):
        """
        Get a specific session by ID
        
        Args:
            session_id: Session ID to retrieve
            
        Returns:
            Session data dict or None if not found
        """
        try:
            ref = db.reference(f'sessions/{session_id}')
            return ref.get()
        except Exception as e:
            print(f"Error retrieving session {session_id}: {e}")
            return None
    
    def update_session(self, session_id, data):
        """
        Update a session with new data
        
        Args:
            session_id: Session ID to update
            data: Dict of data to update
            
        Returns:
            True if successful, False otherwise
        """
        try:
            ref = db.reference(f'sessions/{session_id}')
            ref.update(data)
            return True
        except Exception as e:
            print(f"Error updating session {session_id}: {e}")
            return False
    
    def save_ai_suggestions(self, session_id, suggestions):
        """
        Save AI suggestions for a session
        
        Args:
            session_id: Session ID to update
            suggestions: List of suggestion strings
            
        Returns:
            True if successful, False otherwise
        """
        try:
            ref = db.reference(f'sessions/{session_id}')
            ref.update({
                'aiSuggestions': suggestions,
                'lastAnalyzed': db.ServerValue.TIMESTAMP
            })
            return True
        except Exception as e:
            print(f"Error saving AI suggestions for session {session_id}: {e}")
            return False
    
    def get_real_time_notes(self):
        """
        Get current real-time notes being played
        
        Returns:
            List of note objects
        """
        try:
            ref = db.reference('notes')
            notes_data = ref.get()
            
            notes = []
            if notes_data:
                for note_id, note in notes_data.items():
                    notes.append(note)
            
            return notes
        except Exception as e:
            print(f"Error retrieving real-time notes: {e}")
            return []
