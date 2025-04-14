import 'package:flutter/material.dart';

class AISuggestionPanel extends StatelessWidget {
  final List<String> suggestions;
  
  const AISuggestionPanel({
    Key? key,
    required this.suggestions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Practice Suggestions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: suggestions.isEmpty
                  ? const Center(
                      child: Text('Play some notes to get AI suggestions'),
                    )
                  : ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return _buildSuggestionItem(
                          context,
                          suggestions[index],
                          index,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionItem(BuildContext context, String suggestion, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getSuggestionColor(index).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: _getSuggestionColor(index),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (index == 0) 
                  Text(
                    'High priority',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            color: Colors.blue[800],
            onPressed: () {
              // Would implement demonstration of this suggestion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Demo for: $suggestion'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Color _getSuggestionColor(int index) {
    switch (index) {
      case 0:
        return Colors.red[700]!;
      case 1:
        return Colors.orange[700]!;
      case 2:
        return Colors.green[700]!;
      default:
        return Colors.blue[700]!;
    }
  }
}
