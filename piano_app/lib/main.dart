import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'piano_keyboard.dart';
import 'firebase_service.dart';  // We'll keep the file name but it contains LocalStorageService now

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to landscape for better keyboard display
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // No Firebase initialization needed for the prototype
  
  runApp(const PianoLearningApp());
}

class PianoLearningApp extends StatelessWidget {
  const PianoLearningApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Piano Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const PianoScreen(),
    );
  }
}

class PianoScreen extends StatefulWidget {
  const PianoScreen({Key? key}) : super(key: key);

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  bool _isFreestyleMode = false;
  double _volume = 0.8;
  bool _sustainEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _storageService.initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Piano Learning'),
        actions: [
          // Toggle for practice/freestyle mode
          Row(
            children: [
              const Text('Practice'),
              Switch(
                value: _isFreestyleMode,
                activeColor: Colors.blue[800],
                onChanged: (value) {
                  setState(() {
                    _isFreestyleMode = value;
                  });
                },
              ),
              const Text('Freestyle'),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Control panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                // Volume control
                Row(
                  children: [
                    const Icon(Icons.volume_down),
                    Slider(
                      value: _volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                        });
                      },
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
                const SizedBox(width: 16),
                // Sustain toggle
                Row(
                  children: [
                    const Text('Sustain'),
                    Switch(
                      value: _sustainEnabled,
                      activeColor: Colors.blue[800],
                      onChanged: (value) {
                        setState(() {
                          _sustainEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Piano keyboard takes up most of the screen
          Expanded(
            child: PianoKeyboard(
              storageService: _storageService, 
              isFreestyleMode: _isFreestyleMode,
              volume: _volume,
              sustainEnabled: _sustainEnabled,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _storageService.dispose();
    super.dispose();
  }
}
