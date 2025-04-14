import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'models/note_model.dart';
import 'firebase_service.dart';  // Contains LocalStorageService now
import 'utils/audio_manager.dart';

class PianoKeyboard extends StatefulWidget {
  final LocalStorageService storageService;
  final bool isFreestyleMode;
  final double volume;
  final bool sustainEnabled;

  const PianoKeyboard({
    Key? key,
    required this.storageService,
    required this.isFreestyleMode, 
    required this.volume,
    required this.sustainEnabled,
  }) : super(key: key);

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> {
  final Set<int> _pressedKeys = {};
  late AudioManager _audioManager;
  
  // Define piano range (starting octave, number of octaves)
  final int _startOctave = 3;
  final int _numOctaves = 3;
  
  @override
  void initState() {
    super.initState();
    _audioManager = AudioManager();
    _initializeAudio();
  }
  
  Future<void> _initializeAudio() async {
    await _audioManager.initialize();
  }
  
  @override
  void didUpdateWidget(PianoKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update audio manager when volume or sustain changes
    if (oldWidget.volume != widget.volume) {
      _audioManager.setVolume(widget.volume);
    }
    
    if (oldWidget.sustainEnabled != widget.sustainEnabled) {
      _audioManager.setSustain(widget.sustainEnabled);
    }
  }
  
  // Handle key press
  void _handleKeyPress(int midiNote) {
    if (!_pressedKeys.contains(midiNote)) {
      // Add to pressed keys
      _pressedKeys.add(midiNote);
      
      // Play the note
      _audioManager.playNote(midiNote);
      
      // Send to storage service
      final NoteModel note = NoteModel(
        midiNote: midiNote,
        velocity: (widget.volume * 127).toInt(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isNoteOn: true,
      );
      
      widget.storageService.sendNoteData(note);
      
      // Trigger haptic feedback for physical feedback
      HapticFeedback.lightImpact();
      
      setState(() {});
    }
  }
  
  // Handle key release
  void _handleKeyRelease(int midiNote) {
    if (_pressedKeys.contains(midiNote)) {
      // Remove from pressed keys
      _pressedKeys.remove(midiNote);
      
      // Stop the note
      if (!widget.sustainEnabled) {
        _audioManager.stopNote(midiNote);
      }
      
      // Send note off to storage service
      final NoteModel note = NoteModel(
        midiNote: midiNote, 
        velocity: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isNoteOn: false,
      );
      
      widget.storageService.sendNoteData(note);
      
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate key dimensions based on available space
        final totalWhiteKeys = _numOctaves * 7 + 1; // C to C for each octave + 1
        final double whiteKeyWidth = constraints.maxWidth / totalWhiteKeys;
        final double blackKeyWidth = whiteKeyWidth * 0.6;
        final double whiteKeyHeight = constraints.maxHeight;
        final double blackKeyHeight = whiteKeyHeight * 0.6;
        
        return Stack(
          children: [
            // White keys
            Row(
              children: List.generate(totalWhiteKeys, (index) {
                // Calculate MIDI note number for white key
                final int octave = _startOctave + (index ~/ 7);
                final int noteInOctave = index % 7;
                
                // Convert to MIDI note (C, D, E, F, G, A, B)
                final int midiNote = octave * 12 + [0, 2, 4, 5, 7, 9, 11][noteInOctave];
                
                return GestureDetector(
                  onTapDown: (_) => _handleKeyPress(midiNote),
                  onTapUp: (_) => _handleKeyRelease(midiNote),
                  onTapCancel: () => _handleKeyRelease(midiNote),
                  onPanEnd: (_) => _handleKeyRelease(midiNote),
                  onPanCancel: () => _handleKeyRelease(midiNote),
                  child: Container(
                    width: whiteKeyWidth,
                    height: whiteKeyHeight,
                    decoration: BoxDecoration(
                      color: _pressedKeys.contains(midiNote) ? Colors.blue.withOpacity(0.3) : Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      ['C', 'D', 'E', 'F', 'G', 'A', 'B'][noteInOctave] + octave.toString(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
            
            // Black keys
            Row(
              children: List.generate(totalWhiteKeys - 1, (index) {
                // Calculate MIDI note number for potential black key
                final int octave = _startOctave + (index ~/ 7);
                final int noteInOctave = index % 7;
                
                // Only draw black keys where they should appear
                final bool hasBlackKey = [0, 1, 3, 4, 5].contains(noteInOctave);
                
                if (!hasBlackKey) {
                  return SizedBox(width: whiteKeyWidth);
                }
                
                // Convert to MIDI note for black keys (C#, D#, F#, G#, A#)
                final int midiNote = octave * 12 + [1, 3, 6, 8, 10][noteInOctave == 0 ? 0 : 
                                                                     noteInOctave == 1 ? 1 :
                                                                     noteInOctave == 3 ? 2 :
                                                                     noteInOctave == 4 ? 3 : 4];
                
                return Container(
                  width: whiteKeyWidth,
                  height: blackKeyHeight,
                  padding: EdgeInsets.only(left: whiteKeyWidth - (blackKeyWidth / 2)),
                  child: GestureDetector(
                    onTapDown: (_) => _handleKeyPress(midiNote),
                    onTapUp: (_) => _handleKeyRelease(midiNote),
                    onTapCancel: () => _handleKeyRelease(midiNote),
                    onPanEnd: (_) => _handleKeyRelease(midiNote),
                    onPanCancel: () => _handleKeyRelease(midiNote),
                    child: Container(
                      width: blackKeyWidth,
                      decoration: BoxDecoration(
                        color: _pressedKeys.contains(midiNote) ? Colors.blue[800] : Colors.black87,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
  
  @override
  void dispose() {
    _audioManager.dispose();
    super.dispose();
  }
}
