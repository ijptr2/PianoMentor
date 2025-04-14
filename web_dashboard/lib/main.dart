import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'live_feedback_view.dart';
import 'practice_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
      appId: const String.fromEnvironment('FIREBASE_APP_ID'),
      messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
      projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    ),
  );
  
  runApp(const PianoLearningDashboard());
}

class PianoLearningDashboard extends StatelessWidget {
  const PianoLearningDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Piano Learning Dashboard',
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
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const LiveFeedbackView(),
    const PracticeHistory(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Piano Learning Dashboard'),
        centerTitle: false,
        actions: [
          // Connection status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 10),
                SizedBox(width: 6),
                Text('Connected', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Side navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.piano),
                selectedIcon: Icon(Icons.piano, color: Colors.blue),
                label: Text('Live Practice'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                selectedIcon: Icon(Icons.history, color: Colors.blue),
                label: Text('Practice History'),
              ),
            ],
          ),
          
          // Main content area
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
