import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'widgets/piano_visualizer.dart';
import 'widgets/ai_suggestion_panel.dart';

class LiveFeedbackView extends StatefulWidget {
  const LiveFeedbackView({Key? key}) : super(key: key);

  @override
  State<LiveFeedbackView> createState() => _LiveFeedbackViewState();
}

class _LiveFeedbackViewState extends State<LiveFeedbackView> {
  final DatabaseReference _notesRef = FirebaseDatabase.instance.ref('notes');
  final Set<int> _activeNotes = {};
  List<String> _aiSuggestions = [];
  String _currentScale = '';
  String _dailyGoal = "Practice C major scale for 10 minutes";
  Timer? _aiUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    _setupNotesListener();
    _fetchInitialAISuggestions();
    
    // Set up periodic AI updates (in a real app, these would come from the server)
    _aiUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchAISuggestions();
    });
  }
  
  void _setupNotesListener() {
    // Listen for note events from Firebase
    _notesRef.limitToLast(10).onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      
      // Get note information
      final int midiNote = data['midiNote'] as int;
      final bool isNoteOn = data['isNoteOn'] as bool;
      
      setState(() {
        if (isNoteOn) {
          _activeNotes.add(midiNote);
        } else {
          _activeNotes.remove(midiNote);
        }
      });
      
      // Auto-remove notes after a timeout (in case note-off events are missed)
      if (isNoteOn) {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _activeNotes.remove(midiNote);
          });
        });
      }
    });
  }
  
  void _fetchInitialAISuggestions() {
    // In a real app, these would come from the AI backend
    _aiSuggestions = [
      "Try practicing the C major scale slowly",
      "Focus on keeping even rhythm between notes",
      "Make sure your hand position is relaxed",
    ];
    
    _currentScale = "C Major";
  }
  
  void _fetchAISuggestions() {
    // Simulate AI suggestions based on currently played notes
    // In a real app, this would make an API call to the backend
    
    // Check what notes are being played to determine the scale
    List<int> activeNotesMod12 = _activeNotes.map((note) => note % 12).toList();
    
    if (activeNotesMod12.contains(0) && activeNotesMod12.contains(4) && activeNotesMod12.contains(7)) {
      _currentScale = "C Major";
      _aiSuggestions = [
        "You're playing C Major chord! Try adding the F chord next",
        "Practice transitioning between C and G chords smoothly",
        "Try playing the C Major scale with this chord"
      ];
    } else if (activeNotesMod12.contains(9) && activeNotesMod12.contains(0) && activeNotesMod12.contains(4)) {
      _currentScale = "A Minor";
      _aiSuggestions = [
        "You're playing A Minor chord! Try the relative harmonic minor scale",
        "Practice transitioning between A minor and E minor",
        "Focus on the emotion - minor chords often convey sadness"
      ];
    } else if (activeNotesMod12.length >= 2) {
      _currentScale = "Exploring intervals";
      _aiSuggestions = [
        "Try to maintain consistent timing between notes",
        "Focus on smooth transitions between intervals",
        "Listen carefully to how the intervals sound together"
      ];
    }
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with daily goal and current scale
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Goal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_dailyGoal),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.3,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Currently Playing',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              color: Colors.blue[800],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentScale.isNotEmpty ? _currentScale : 'No notes detected',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Piano visualization
          Expanded(
            flex: 3,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Piano Visualization',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PianoVisualizer(activeNotes: _activeNotes),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // AI suggestions
          Expanded(
            flex: 2,
            child: AISuggestionPanel(suggestions: _aiSuggestions),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _aiUpdateTimer?.cancel();
    super.dispose();
  }
}
