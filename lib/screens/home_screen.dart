import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import '../services/sentiment_service.dart';
import '../models/comment_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Comment> _comments = [];
  String _selectedSentiment = 'All';
  String _searchQuery = '';

  void _analyzeComments() async {
    setState(() {
      _isLoading = true;
      _comments.clear();
    });

    final youtubeService = YouTubeService();
    final sentimentService = SentimentService();

    try {
      String videoId = youtubeService.extractVideoId(_controller.text);

      final fetchedComments = await youtubeService.fetchComments(videoId);
      for (Comment comment in fetchedComments) {
        final sentiment = await sentimentService.analyzeSentiment(comment.text);
        setState(() {
          _comments.add(Comment(text: comment.text, sentiment: sentiment));
        });
      }

      // Sort comments by sentiment
      _comments.sort((a, b) {
        if (a.sentiment == b.sentiment) return 0;
        if (a.sentiment == 'Positive') return -1;
        if (a.sentiment == 'Neutral' && b.sentiment == 'Negative') return -1;
        return 1;
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error: Invalid YouTube URL or Failed to Fetch Comments')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Comment> filteredComments = _comments
        .where((comment) =>
            (comment.sentiment == _selectedSentiment ||
                _selectedSentiment == 'All') &&
            (comment.text.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red.shade400,
        title: Text(
          'YouTube Comment Analyzer',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.red.shade400)),
                fillColor: Colors.white,
                filled: true,
                // labelText: 'Enter YouTube Video URL',
                hintText: 'e.g., https://www.youtube.com/watch?v=VIDEO_ID',
              ),
            ),
            SizedBox(height: 20),
            MaterialButton(
              padding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.red.shade400,
              onPressed: _analyzeComments,
              child: Text('Analyze Comments'),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DropdownButton<String>(
                elevation: 20,
                isExpanded: false,
                focusColor: Colors.amber,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                value: _selectedSentiment,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSentiment = newValue!;
                  });
                },
                items: <String>['All', 'Positive', 'Neutral', 'Negative']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.red.shade400)),
                labelText: 'Search Comments',
                labelStyle: TextStyle(color: Colors.red.shade300),
                hintText: 'Enter keywords...',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  _searchQuery = text;
                });
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView(
                      children: [
                        if (filteredComments.isNotEmpty)
                          _buildCommentSection(_selectedSentiment + ' Comments',
                              filteredComments),
                        if (filteredComments.isEmpty)
                          Center(
                              child: Text(
                                  'No comments available for this sentiment.')),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(String title, List<Comment> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...comments.map((comment) => ListTile(
              title: Text(comment.text),
              subtitle: Text('Sentiment: ${comment.sentiment}'),
            )),
        Divider(),
      ],
    );
  }
}
