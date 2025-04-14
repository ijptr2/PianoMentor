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
  
  // Convert to JSON for API transmission
  Map<String, dynamic> toJson() {
    return {
      'midiNote': midiNote,
      'velocity': velocity,
      'timestamp': timestamp,
      'isNoteOn': isNoteOn,
    };
  }
  
  // Create from JSON data
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      midiNote: json['midiNote'] as int,
      velocity: json['velocity'] as int,
      timestamp: json['timestamp'] as int,
      isNoteOn: json['isNoteOn'] as bool,
    );
  }
}