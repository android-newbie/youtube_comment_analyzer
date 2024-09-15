import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_comment_analyzer/constants/constants.dart';

class SentimentService {
  final String apiKey = GOOGLE_NLP_API_KEY; // Replace with your API key

  Future<String> analyzeSentiment(String text) async {
    final response = await http.post(
      Uri.parse('https://language.googleapis.com/v1/documents:analyzeSentiment?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'document': {
          'type': 'PLAIN_TEXT',
          'content': text,
        },
        'encodingType': 'UTF8',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final score = data['documentSentiment']['score'] as double;
      if (score > 0.25) return 'Positive';
      if (score < -0.25) return 'Negative';
      return 'Neutral';
    } else {
      throw Exception('Failed to analyze sentiment');
    }
  }
}
