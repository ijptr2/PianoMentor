import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PracticeHistory extends StatefulWidget {
  const PracticeHistory({Key? key}) : super(key: key);

  @override
  State<PracticeHistory> createState() => _PracticeHistoryState();
}

class _PracticeHistoryState extends State<PracticeHistory> {
  final DatabaseReference _sessionsRef = FirebaseDatabase.instance.ref('sessions');
  List<PracticeSession> _sessions = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }
  
  Future<void> _loadSessions() async {
    try {
      final snapshot = await _sessionsRef.orderByChild('startTime').limitToLast(10).get();
      
      if (snapshot.exists) {
        final List<PracticeSession> sessions = [];
        final data = snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          sessions.add(PracticeSession.fromJson(key, value));
        });
        
        // Sort sessions by start time (newest first)
        sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading sessions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice History',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          // Practice statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice Statistics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Simple practice statistics graph
                  SizedBox(
                    height: 200,
                    child: _buildPracticeChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recent practice sessions
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Practice Sessions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_sessions.isEmpty)
                      const Center(
                        child: Text('No practice sessions yet. Start playing on your mobile device!'),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            return _buildSessionCard(session);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPracticeChart() {
    if (_sessions.isEmpty) {
      return const Center(
        child: Text('No practice data available yet'),
      );
    }
    
    // Calculate practice minutes per day
    final Map<String, int> practiceMinutesByDay = {};
    
    for (final session in _sessions) {
      final date = DateFormat('MM/dd').format(session.startTime);
      final durationMinutes = session.durationMinutes;
      
      if (practiceMinutesByDay.containsKey(date)) {
        practiceMinutesByDay[date] = practiceMinutesByDay[date]! + durationMinutes;
      } else {
        practiceMinutesByDay[date] = durationMinutes;
      }
    }
    
    // Convert to chart data
    final List<FlSpot> spots = [];
    final List<String> days = practiceMinutesByDay.keys.toList()..sort();
    
    for (int i = 0; i < days.length; i++) {
      spots.add(FlSpot(i.toDouble(), practiceMinutesByDay[days[i]]!.toDouble()));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt()]),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('${value.toInt()} min'),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue[800],
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionCard(PracticeSession session) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.music_note,
          color: Colors.blue[800],
          size: 32,
        ),
        title: Text(
          DateFormat('MMMM d, yyyy - h:mm a').format(session.startTime),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Duration: ${session.durationMinutes} minutes'),
            Text('Notes played: ${session.notesCount}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            // View session details (could be implemented in the future)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session playback not implemented yet'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PracticeSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String deviceInfo;
  final String mode;
  final int notesCount;
  
  PracticeSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.deviceInfo,
    required this.mode,
    required this.notesCount,
  });
  
  // Create from Firebase JSON data
  factory PracticeSession.fromJson(String id, Map<dynamic, dynamic> json) {
    // Parse notes count if available
    int noteCount = 0;
    if (json.containsKey('notes')) {
      final notes = json['notes'] as Map<dynamic, dynamic>;
      noteCount = notes.length;
    }
    
    return PracticeSession(
      id: id,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] ?? 0),
      endTime: json['endTime'] != null ? DateTime.fromMillisecondsSinceEpoch(json['endTime']) : null,
      deviceInfo: json['deviceInfo'] ?? 'Unknown device',
      mode: json['mode'] ?? 'practice',
      notesCount: noteCount,
    );
  }
  
  // Calculate session duration in minutes
  int get durationMinutes {
    if (endTime == null) {
      return 0;
    }
    
    final difference = endTime!.difference(startTime);
    return (difference.inSeconds / 60).round();
  }
}
