import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:just_audio/just_audio.dart';

class AudioManager {
  late FlutterMidi _flutterMidi;
  double _volume = 0.8;
  bool _sustainEnabled = false;
  final Set<int> _activeNotes = {};
  
  AudioManager() {
    _flutterMidi = FlutterMidi();
  }
  
  Future<void> initialize() async {
    // Load soundfont
    await _flutterMidi.unmute();
    
    // Try to load a piano soundfont
    try {
      ByteData _byte = await rootBundle.load('assets/sf2/piano.sf2');
      await _flutterMidi.prepare(sf2: _byte);
    } catch (e) {
      print('Error loading soundfont: $e');
      // Fallback to default soundfont if needed
    }
  }
  
  // Play MIDI note
  void playNote(int midiNote) {
    // Apply volume to note velocity (MIDI velocity ranges from 0-127)
    final int velocity = (_volume * 127).toInt();
    
    // Send MIDI note on message
    _flutterMidi.playMidiNote(midi: midiNote, velocity: velocity);
    
    // Keep track of active notes (for sustain)
    _activeNotes.add(midiNote);
  }
  
  // Stop MIDI note
  void stopNote(int midiNote) {
    // Only stop if sustain is not enabled
    if (!_sustainEnabled) {
      _flutterMidi.stopMidiNote(midi: midiNote);
      _activeNotes.remove(midiNote);
    }
  }
  
  // Set volume level (0.0 to 1.0)
  void setVolume(double volume) {
    _volume = volume;
  }
  
  // Toggle sustain pedal
  void setSustain(bool enabled) {
    _sustainEnabled = enabled;
    
    // If sustain is disabled, stop all active notes
    if (!_sustainEnabled) {
      _releaseSustainedNotes();
    }
  }
  
  // Release all sustained notes
  void _releaseSustainedNotes() {
    for (final note in _activeNotes.toList()) {
      _flutterMidi.stopMidiNote(midi: note);
    }
    _activeNotes.clear();
  }
  
  // Clean up resources
  void dispose() {
    // Stop all playing notes
    _releaseSustainedNotes();
  }
}
