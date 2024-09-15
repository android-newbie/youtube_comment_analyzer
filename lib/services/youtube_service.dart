import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_comment_analyzer/constants/constants.dart';
import '../models/comment_model.dart';

class YouTubeService {
  final String apiKey = YOUTUBE_API_KEY; // Replace with your API key

  Future<List<Comment>> fetchComments(String videoId) async {
    final response = await http.get(Uri.parse(
      'https://www.googleapis.com/youtube/v3/commentThreads?key=$apiKey&textFormat=plainText&part=snippet&videoId=$videoId',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Comment> comments = [];
      for (var item in data['items']) {
        final commentText = item['snippet']['topLevelComment']['snippet']['textDisplay'];
        comments.add(Comment(text: commentText, sentiment: 'Unknown'));
      }
      return comments;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  String extractVideoId(String url) {
  final regExp = RegExp(
    r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|embed|watch)?\?v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
    multiLine: false,
  );
  
  final match = regExp.firstMatch(url);
  
  if (match != null && match.groupCount > 0) {
    return match.group(1)!;
  } else {
    throw Exception('Invalid YouTube URL');
  }
}


}
