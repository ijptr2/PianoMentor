class NoteModel {
  final int midiNote;
  final int velocity;
  final int timestamp;
  final bool isNoteOn;
  
  NoteModel({
    required this.midiNote,
    required this.velocity,
    required this.timestamp,
    required this.isNoteOn,
  });
  
  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'midiNote': midiNote,
      'velocity': velocity,
      'timestamp': timestamp,
      'isNoteOn': isNoteOn,
    };
  }
  
  // Create from JSON (for receiving from Firebase)
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      midiNote: json['midiNote'],
      velocity: json['velocity'],
      timestamp: json['timestamp'],
      isNoteOn: json['isNoteOn'],
    );
  }
  
  // Get note name from MIDI note number
  String get noteName {
    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = (midiNote ~/ 12) - 1;
    final noteIndex = midiNote % 12;
    return '${noteNames[noteIndex]}$octave';
  }
  
  // Check if this is a white key
  bool get isWhiteKey {
    final noteIndex = midiNote % 12;
    return [0, 2, 4, 5, 7, 9, 11].contains(noteIndex);
  }
}
