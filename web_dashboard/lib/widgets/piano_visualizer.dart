import 'package:flutter/material.dart';

class PianoVisualizer extends StatelessWidget {
  final Set<int> activeNotes;
  
  const PianoVisualizer({
    Key? key,
    required this.activeNotes,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Decide how many octaves to show
          final octaves = 5;
          final keysPerOctave = 12;
          final totalWhiteKeys = octaves * 7; // 7 white keys per octave
          final whiteKeyWidth = constraints.maxWidth / totalWhiteKeys;
          final blackKeyWidth = whiteKeyWidth * 0.6;
          final whiteKeyHeight = constraints.maxHeight;
          final blackKeyHeight = whiteKeyHeight * 0.6;
          
          // Calculate offsets for each white key
          final whiteKeyPositions = <int, double>{};
          int whiteKeyIndex = 0;
          
          for (int octave = 0; octave < octaves; octave++) {
            for (int note = 0; note < keysPerOctave; note++) {
              // White keys are C, D, E, F, G, A, B (notes 0, 2, 4, 5, 7, 9, 11)
              if ([0, 2, 4, 5, 7, 9, 11].contains(note)) {
                final midiNote = octave * 12 + note + 36; // Start from C2 (36)
                whiteKeyPositions[midiNote] = whiteKeyIndex * whiteKeyWidth;
                whiteKeyIndex++;
              }
            }
          }
          
          return Stack(
            children: [
              // White keys
              ...whiteKeyPositions.entries.map((entry) {
                final midiNote = entry.key;
                final xPosition = entry.value;
                final isActive = activeNotes.contains(midiNote);
                
                return Positioned(
                  left: xPosition,
                  width: whiteKeyWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive ? Colors.blue[100] : Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _getMidiNoteName(midiNote),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              // Black keys
              ...whiteKeyPositions.entries.map((entry) {
                final midiNote = entry.key;
                final xPosition = entry.value;
                
                // Check if there should be a black key to the right of this white key
                final noteValue = midiNote % 12;
                
                // Black keys are after C, D, F, G, A (notes 0, 2, 5, 7, 9)
                if ([0, 2, 5, 7, 9].contains(noteValue)) {
                  final blackKeyNote = midiNote + 1;
                  final isActive = activeNotes.contains(blackKeyNote);
                  
                  return Positioned(
                    left: xPosition + whiteKeyWidth - (blackKeyWidth / 2),
                    width: blackKeyWidth,
                    top: 0,
                    height: blackKeyHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive ? Colors.blue[700] : Colors.black87,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              
              // Note indicators for active notes
              if (activeNotes.isNotEmpty)
                ...activeNotes.map((midiNote) {
                  // Find position of the note
                  double? noteX;
                  bool isBlackKey = false;
                  
                  // Check if it's a white key
                  if (whiteKeyPositions.containsKey(midiNote)) {
                    noteX = whiteKeyPositions[midiNote]! + whiteKeyWidth / 2;
                  } else {
                    // It's a black key, find the white key before it
                    final whiteKeyBefore = midiNote - 1;
                    if (whiteKeyPositions.containsKey(whiteKeyBefore)) {
                      noteX = whiteKeyPositions[whiteKeyBefore]! + whiteKeyWidth;
                      isBlackKey = true;
                    }
                  }
                  
                  if (noteX != null) {
                    return Positioned(
                      left: noteX - 15,
                      top: isBlackKey ? blackKeyHeight - 30 : whiteKeyHeight - 80,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getMidiNoteName(midiNote),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            ],
          );
        },
      ),
    );
  }
  
  String _getMidiNoteName(int midiNote) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = (midiNote / 12).floor() - 1; // MIDI note 12 = C0
    final noteInOctave = midiNote % 12;
    
    return noteNames[noteInOctave] + octave.toString();
  }
}