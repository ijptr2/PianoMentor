import numpy as np
from datetime import datetime
from collections import Counter

class LearningAI:
    """Simple rule-based AI for piano learning suggestions"""
    
    def __init__(self):
        # Define common scales and their note patterns (0 = C, 1 = C#, etc.)
        self.scales = {
            'C Major': [0, 2, 4, 5, 7, 9, 11],
            'G Major': [7, 9, 11, 0, 2, 4, 6],
            'D Major': [2, 4, 6, 7, 9, 11, 1],
            'A Major': [9, 11, 1, 2, 4, 6, 8],
            'E Major': [4, 6, 8, 9, 11, 1, 3],
            'F Major': [5, 7, 9, 10, 0, 2, 4],
            'B Major': [11, 1, 3, 4, 6, 8, 10],
            
            'A Minor': [9, 11, 0, 2, 4, 5, 7],
            'E Minor': [4, 6, 7, 9, 11, 0, 2],
            'D Minor': [2, 4, 5, 7, 9, 10, 0],
            'G Minor': [7, 9, 10, 0, 2, 3, 5],
            'C Minor': [0, 2, 3, 5, 7, 8, 10],
            'F Minor': [5, 7, 8, 10, 0, 1, 3],
            'B Minor': [11, 1, 2, 4, 6, 7, 9],
        }
        
        # Define common chords
        self.chords = {
            'C Major': [0, 4, 7],
            'C Minor': [0, 3, 7],
            'G Major': [7, 11, 2],
            'G Minor': [7, 10, 2],
            'D Major': [2, 6, 9],
            'D Minor': [2, 5, 9],
            'A Major': [9, 1, 4],
            'A Minor': [9, 0, 4],
            'E Major': [4, 8, 11],
            'E Minor': [4, 7, 11],
            'F Major': [5, 9, 0],
            'F Minor': [5, 8, 0],
        }
        
        # Suggestions by skill level
        self.beginner_suggestions = [
            "Try practicing the C major scale slowly",
            "Focus on keeping even rhythm between notes",
            "Make sure your hand position is relaxed",
            "Practice transitioning between C, F, and G chords",
            "Try playing quarter notes with your right hand while holding whole notes with your left",
        ]
        
        self.intermediate_suggestions = [
            "Work on the chromatic scale to improve finger independence",
            "Practice arpeggios in various keys",
            "Try playing scales in thirds to improve coordination",
            "Practice with a metronome to improve your timing",
            "Try the circle of fifths to practice different key signatures",
        ]
        
        self.advanced_suggestions = [
            "Work on Bach's inventions to improve contrapuntal playing",
            "Practice octave passages to build hand strength",
            "Try improvising over common chord progressions",
            "Practice scales in contrary motion",
            "Work on trills and ornaments for expressive playing",
        ]
    
    def generate_suggestions(self, notes):
        """
        Generate practice suggestions based on played notes
        
        Args:
            notes: List of note objects with midiNote, velocity, timestamp and isNoteOn
            
        Returns:
            List of suggestion strings
        """
        if not notes:
            return self.beginner_suggestions[:3]
        
        # Extract just the MIDI note numbers that were pressed
        midi_notes = [n['midiNote'] for n in notes if n['isNoteOn']]
        
        # Analyze timing if we have timestamps
        timing_issues = self._analyze_timing([n for n in notes if n['isNoteOn']])
        
        # Analyze scale/key
        scale_info = self.identify_scale(midi_notes)
        
        # Find which notes were played most frequently
        note_counter = Counter([n % 12 for n in midi_notes])
        most_common_notes = [note for note, _ in note_counter.most_common(3)]
        
        # Generate suggestions based on analysis
        suggestions = []
        
        # Add scale-based suggestion
        if scale_info['scale']:
            suggestions.append(f"Try practicing the {scale_info['scale']} scale with both hands")
        
        # Add timing-based suggestion if issues found
        if timing_issues:
            suggestions.append("Work on your timing with a metronome - your note spacing is uneven")
        
        # Add chord suggestion based on most common notes
        chord_suggestion = self._generate_chord_suggestion(most_common_notes)
        if chord_suggestion:
            suggestions.append(chord_suggestion)
        
        # Add technique suggestions
        suggestions.append("Focus on keeping your wrists relaxed while playing")
        
        # Add difficulty-appropriate suggestions
        skill_level = self._estimate_skill_level(notes)
        if skill_level == "beginner":
            suggestions.extend(self.beginner_suggestions[:2])
        elif skill_level == "intermediate":
            suggestions.extend(self.intermediate_suggestions[:2])
        else:
            suggestions.extend(self.advanced_suggestions[:2])
        
        # Return top 3-5 unique suggestions
        unique_suggestions = list(dict.fromkeys(suggestions))
        return unique_suggestions[:5]
    
    def identify_scale(self, midi_notes):
        """
        Identify which scale the notes likely belong to
        
        Args:
            midi_notes: List of MIDI note numbers
            
        Returns:
            Dict with scale name and confidence
        """
        if not midi_notes:
            return {"scale": "", "confidence": 0}
        
        # Convert to pitch classes (0-11, where 0 is C)
        pitch_classes = [note % 12 for note in midi_notes]
        unique_pitches = set(pitch_classes)
        
        # Check each scale for match
        best_match = ""
        best_count = 0
        
        for scale_name, scale_notes in self.scales.items():
            # Count how many of the played notes are in this scale
            matches = sum(1 for pitch in unique_pitches if pitch in scale_notes)
            
            # Count how many notes aren't in the scale
            non_matches = len(unique_pitches) - matches
            
            # Calculate a match score (matches minus penalties for non-scale notes)
            match_score = matches - (non_matches * 0.5)
            
            if match_score > best_count:
                best_count = match_score
                best_match = scale_name
        
        # Calculate confidence (0-1)
        confidence = 0
        if unique_pitches:
            # Perfect match would be all 7 notes of the scale and no others
            confidence = min(1.0, best_count / 7)
        
        return {
            "scale": best_match,
            "confidence": confidence
        }
    
    def _analyze_timing(self, notes):
        """
        Analyze timing consistency between notes
        
        Args:
            notes: List of note objects with timestamps
            
        Returns:
            True if timing issues detected, False otherwise
        """
        if len(notes) < 4:
            return False
        
        # Calculate time intervals between successive notes
        intervals = []
        sorted_notes = sorted(notes, key=lambda n: n['timestamp'])
        
        for i in range(1, len(sorted_notes)):
            interval = sorted_notes[i]['timestamp'] - sorted_notes[i-1]['timestamp']
            if interval > 0 and interval < 2000:  # Ignore pauses over 2 seconds
                intervals.append(interval)
        
        if not intervals:
            return False
        
        # Calculate coefficient of variation (std dev / mean)
        # Higher values indicate more inconsistent timing
        mean_interval = np.mean(intervals)
        std_dev = np.std(intervals)
        
        cv = std_dev / mean_interval if mean_interval > 0 else 0
        
        # CV > 0.5 indicates significant timing inconsistency
        return cv > 0.5
    
    def _generate_chord_suggestion(self, common_notes):
        """Generate a chord suggestion based on most commonly played notes"""
        # Try to match common_notes to a chord
        best_match = ""
        best_score = 0
        
        for chord_name, chord_notes in self.chords.items():
            # Count matching notes
            matches = sum(1 for note in common_notes if note in chord_notes)
            if matches > best_score:
                best_score = matches
                best_match = chord_name
        
        if best_match and best_score >= 2:
            return f"Try practicing the {best_match} chord and its inversions"
        
        return ""
    
    def _estimate_skill_level(self, notes):
        """Estimate the user's skill level based on notes played"""
        if not notes:
            return "beginner"
        
        # Extract midi notes
        midi_notes = [n['midiNote'] for n in notes if n['isNoteOn']]
        
        # Look at note range as one indicator of skill
        note_range = max(midi_notes) - min(midi_notes) if midi_notes else 0
        
        # Count unique notes
        unique_notes = len(set(midi_notes))
        
        # More advanced players tend to use wider range and more unique notes
        if note_range > 24 and unique_notes > 12:
            return "advanced"
        elif note_range > 12 and unique_notes > 7:
            return "intermediate"
        else:
            return "beginner"
    
    def analyze_session(self, session_data):
        """
        Analyze a single practice session
        
        Args:
            session_data: Dict containing session info from Firebase
            
        Returns:
            Dict with analysis report
        """
        # Extract notes from session
        notes = []
        if 'notes' in session_data and isinstance(session_data['notes'], dict):
            for note_id, note_data in session_data['notes'].items():
                notes.append(note_data)
        
        # Calculate session stats
        start_time = session_data.get('startTime', 0)
        end_time = session_data.get('endTime', datetime.now().timestamp() * 1000)
        
        duration_mins = (end_time - start_time) / 60000
        
        # Note count by type (white keys vs black keys)
        white_keys = 0
        black_keys = 0
        
        for note in notes:
            midi_note = note.get('midiNote', 0)
            note_in_octave = midi_note % 12
            if note_in_octave in [1, 3, 6, 8, 10]:  # Black keys
                black_keys += 1
            else:
                white_keys += 1
        
        # Generate report
        return {
            'duration': round(duration_mins, 1),
            'totalNotes': len(notes),
            'whiteKeys': white_keys,
            'blackKeys': black_keys,
            'suggestions': self.generate_suggestions(notes),
            'scale': self.identify_scale([n.get('midiNote', 0) for n in notes])['scale'],
        }
    
    def analyze_progress(self, sessions_data):
        """
        Analyze progress across multiple sessions
        
        Args:
            sessions_data: Dict of session data from Firebase
            
        Returns:
            Dict with progress report
        """
        if not sessions_data:
            return {
                'error': 'No session data available'
            }
        
        # Extract data from sessions
        all_notes = []
        session_counts = []
        practice_duration = 0
        
        for session_id, session_data in sessions_data.items():
            # Extract session duration
            start_time = session_data.get('startTime', 0)
            end_time = session_data.get('endTime', start_time)
            session_duration = (end_time - start_time) / 60000  # in minutes
            practice_duration += session_duration
            
            # Count notes in this session
            session_notes = []
            if 'notes' in session_data and isinstance(session_data['notes'], dict):
                for note_id, note_data in session_data['notes'].items():
                    session_notes.append(note_data)
                    all_notes.append(note_data)
            
            session_counts.append(len(session_notes))
        
        # Calculate progress metrics
        avg_session_notes = sum(session_counts) / len(session_counts) if session_counts else 0
        
        # Check for improvement in note count over time
        improving = False
        if len(session_counts) >= 3:
            # Simple linear regression slope check
            x = list(range(len(session_counts)))
            slope = np.polyfit(x, session_counts, 1)[0]
            improving = slope > 0
        
        # Generate progress report
        return {
            'totalPracticeMinutes': round(practice_duration, 1),
            'averageNotesPerSession': round(avg_session_notes),
            'numberOfSessions': len(sessions_data),
            'improving': improving,
            'suggestions': self.generate_suggestions(all_notes),
            'focus': self._suggest_focus_area(all_notes)
        }
    
    def _suggest_focus_area(self, notes):
        """Suggest a focus area based on playing history"""
        if not notes:
            return "Basic scales and chord progressions"
        
        # Convert notes to pitch classes
        pitch_classes = [n.get('midiNote', 0) % 12 for n in notes if n.get('isNoteOn', False)]
        
        # Count occurrences of each pitch class
        pitch_counter = Counter(pitch_classes)
        
        # Check if any pitch classes are underrepresented
        total = sum(pitch_counter.values())
        expected_per_class = total / 12
        
        underplayed = []
        for pitch in range(12):
            count = pitch_counter.get(pitch, 0)
            if count < expected_per_class * 0.5:  # Less than half expected frequency
                note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
                underplayed.append(note_names[pitch])
        
        if underplayed:
            return f"Scales and exercises with {', '.join(underplayed)} notes"
        
        # Default focus areas by skill level
        skill_level = self._estimate_skill_level(notes)
        
        if skill_level == "beginner":
            return "Basic major and minor scales"
        elif skill_level == "intermediate":
            return "Arpeggios and chord inversions"
        else:
            return "Advanced scales and improvisation"
    
    def generate_daily_goal(self):
        """Generate a daily practice goal"""
        # In a real app, this would be personalized based on user history
        goals = [
            "Practice C major scale for 10 minutes",
            "Work on chord transitions between G, C, and D for 15 minutes",
            "Practice sight reading a new piece for 20 minutes",
            "Work on the first section of your current piece for 15 minutes",
            "Memorize the first 8 measures of your new piece",
            "Practice arpeggios in F major and D minor",
            "Work on finger independence exercises for 10 minutes",
        ]
        
        import random
        return random.choice(goals)
