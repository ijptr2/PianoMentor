import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // For a real app, we would have a soundfont or individual piano notes
  // For the prototype, we'll simulate the audio functionality
  
  final Map<int, AudioPlayer> _players = {};
  final Map<int, AudioCache> _audioCaches = {};
  double _volume = 0.8;
  bool _sustainEnabled = false;
  final Set<int> _sustainedNotes = {};
  
  Future<void> initialize() async {
    // In a real app, we would preload all the piano samples here
    print('Audio engine initialized');
  }
  
  void setVolume(double volume) {
    _volume = volume;
    
    // Update volume for all currently playing notes
    for (final player in _players.values) {
      player.setVolume(_volume);
    }
  }
  
  void setSustain(bool enabled) {
    _sustainEnabled = enabled;
    
    // If sustain is disabled, stop all sustained notes
    if (!_sustainEnabled) {
      for (final midiNote in _sustainedNotes.toList()) {
        _stopNote(midiNote);
      }
      _sustainedNotes.clear();
    }
  }
  
  void playNote(int midiNote) {
    // In a real app, we would play the corresponding piano sample
    // For the prototype, we'll simulate this
    
    if (_players.containsKey(midiNote)) {
      // Stop the note if it's already playing
      _players[midiNote]!.stop();
    } else {
      // Create a new player for this note
      _players[midiNote] = AudioPlayer();
      _audioCaches[midiNote] = AudioCache();
    }
    
    // Simulate playing the note (in a real app, we would load the specific piano sample)
    print('Playing note: $midiNote');
    
    // Set the volume
    _players[midiNote]!.setVolume(_volume);
  }
  
  void stopNote(int midiNote) {
    if (_sustainEnabled) {
      // If sustain is on, mark as sustained but don't stop yet
      _sustainedNotes.add(midiNote);
    } else {
      _stopNote(midiNote);
    }
  }
  
  void _stopNote(int midiNote) {
    if (_players.containsKey(midiNote)) {
      _players[midiNote]!.stop();
      _players[midiNote]!.dispose();
      _players.remove(midiNote);
      _audioCaches.remove(midiNote);
      print('Stopped note: $midiNote');
    }
  }
  
  void dispose() {
    // Stop and dispose all players
    for (final player in _players.values) {
      player.stop();
      player.dispose();
    }
    _players.clear();
    _audioCaches.clear();
    _sustainedNotes.clear();
    
    print('Audio engine disposed');
  }
}