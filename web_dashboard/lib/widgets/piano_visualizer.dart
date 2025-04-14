import 'package:flutter/material.dart';

class PianoVisualizer extends StatelessWidget {
  final Set<int> activeNotes;
  
  // Define piano range
  final int startOctave = 3;
  final int numOctaves = 3;
  
  const PianoVisualizer({
    Key? key,
    required this.activeNotes,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate key dimensions
        final totalWhiteKeys = numOctaves * 7 + 1; // C to C for each octave + 1
        final double whiteKeyWidth = constraints.maxWidth / totalWhiteKeys;
        final double blackKeyWidth = whiteKeyWidth * 0.6;
        final double whiteKeyHeight = constraints.maxHeight;
        final double blackKeyHeight = whiteKeyHeight * 0.6;
        
        return Stack(
          children: [
            // Draw white keys
            Row(
              children: List.generate(totalWhiteKeys, (index) {
                // Calculate MIDI note number for white key
                final int octave = startOctave + (index ~/ 7);
                final int noteInOctave = index % 7;
                
                // Convert to MIDI note (C, D, E, F, G, A, B)
                final int midiNote = octave * 12 + [0, 2, 4, 5, 7, 9, 11][noteInOctave];
                final bool isActive = activeNotes.contains(midiNote);
                
                return Container(
                  width: whiteKeyWidth,
                  height: whiteKeyHeight,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue.withOpacity(0.3) : Colors.white,
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
                );
              }),
            ),
            
            // Draw black keys
            Row(
              children: List.generate(totalWhiteKeys - 1, (index) {
                // Calculate MIDI note number for potential black key
                final int octave = startOctave + (index ~/ 7);
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
                
                final bool isActive = activeNotes.contains(midiNote);
                
                return Container(
                  width: whiteKeyWidth,
                  height: blackKeyHeight,
                  padding: EdgeInsets.only(left: whiteKeyWidth - (blackKeyWidth / 2)),
                  child: Container(
                    width: blackKeyWidth,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.blue[800] : Colors.black87,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ),
            
            // Notes being played visualization
            if (activeNotes.isNotEmpty)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Notes: ${_getActiveNoteNames()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  // Helper to get note names from MIDI numbers
  String _getActiveNoteNames() {
    final List<String> noteNames = [];
    
    for (final midiNote in activeNotes) {
      noteNames.add(_getNoteNameFromMidi(midiNote));
    }
    
    return noteNames.join(', ');
  }
  
  String _getNoteNameFromMidi(int midiNote) {
    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = (midiNote ~/ 12) - 1;
    final noteIndex = midiNote % 12;
    return '${noteNames[noteIndex]}$octave';
  }
}
