import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/note_model.dart';

class LocalStorageService {
  final String _baseUrl = 'http://localhost:5000/api';
  late String _sessionId;
  
  void initialize() {
    // Create a unique session ID for this practice session
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // We don't need to initialize anything on the server side here
    // The first note sent will create the session
  }
  
  // Send note data to backend server
  Future<void> sendNoteData(NoteModel note) async {
    try {
      // Send note to backend for real-time notes and session history
      await http.post(
        Uri.parse('$_baseUrl/save-note'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'note': note.toJson(),
          'sessionId': _sessionId
        }),
      );
    } catch (e) {
      print('Error sending note data to server: $e');
    }
  }
  
  // Update session metadata (e.g., change mode, update session info)
  Future<void> updateSessionData(Map<String, dynamic> data) async {
    try {
      // This would add more functionality to update session data
      // For now, we'll just print that we would update this data
      print('Updating session data: $data');
    } catch (e) {
      print('Error updating session data: $e');
    }
  }
  
  // Clean up resources
  Future<void> dispose() async {
    try {
      // In a real app, this would mark the session as ended
      print('Session $sessionId ended');
    } catch (e) {
      print('Error ending session: $e');
    }
  }
  
  // Get session ID
  String get sessionId => _sessionId;
}
