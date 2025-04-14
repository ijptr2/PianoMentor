import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/piano_visualizer.dart';
import 'widgets/ai_suggestion_panel.dart';

class LiveFeedbackView extends StatefulWidget {
  const LiveFeedbackView({Key? key}) : super(key: key);

  @override
  State<LiveFeedbackView> createState() => _LiveFeedbackViewState();
}

class _LiveFeedbackViewState extends State<LiveFeedbackView> {
  final String _baseUrl = 'http://localhost:5000/api';
  final Set<int> _activeNotes = {};
  List<String> _aiSuggestions = [];
  String _currentScale = '';
  String _dailyGoal = "Practice C major scale for 10 minutes";
  Timer? _notesFetchTimer;
  Timer? _aiUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    _fetchInitialAISuggestions();
    _fetchDailyGoal();
    
    // Set up periodic notes updates
    _notesFetchTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _fetchLiveNotes();
    });
    
    // Set up periodic AI updates
    _aiUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchAISuggestions();
    });
  }
  
  Future<void> _fetchLiveNotes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/notes'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notes = data['notes'] as List<dynamic>;
        
        // Update active notes
        final Set<int> newActiveNotes = {};
        
        for (var note in notes) {
          final int midiNote = note['midiNote'] as int;
          final bool isNoteOn = note['isNoteOn'] as bool;
          
          if (isNoteOn) {
            newActiveNotes.add(midiNote);
          }
        }
        
        // Update state if changes detected
        if (setEquals(newActiveNotes, _activeNotes) == false) {
          setState(() {
            _activeNotes.clear();
            _activeNotes.addAll(newActiveNotes);
          });
        }
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
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
  
  Future<void> _fetchDailyGoal() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/daily-goal'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          _dailyGoal = data['goal'] ?? "Practice C major scale for 10 minutes";
        });
      }
    } catch (e) {
      print('Error fetching daily goal: $e');
    }
  }
  
  Future<void> _fetchAISuggestions() async {
    try {
      // Get currently active notes for analysis
      List<Map<String, dynamic>> notesList = [];
      
      for (int midiNote in _activeNotes) {
        notesList.add({
          'midiNote': midiNote,
          'velocity': 100,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isNoteOn': true
        });
      }
      
      // Get suggestions from API if we have active notes
      if (notesList.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$_baseUrl/suggestions'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'sessionId': 'web-dashboard-${DateTime.now().millisecondsSinceEpoch}',
            'notes': notesList
          })
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _aiSuggestions = List<String>.from(data['suggestions'] ?? []);
          });
        }
      }
      
      // Analyze scale
      final List<int> midiNotes = _activeNotes.toList();
      if (midiNotes.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$_baseUrl/analyze-scale'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'notes': midiNotes
          })
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _currentScale = data['scale'] ?? "";
          });
        }
      }
    } catch (e) {
      print('Error fetching AI suggestions: $e');
    }
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
    _notesFetchTimer?.cancel();
    super.dispose();
  }
}
