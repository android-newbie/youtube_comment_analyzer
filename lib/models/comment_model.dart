class Comment {
  final String text;
  final String sentiment;

  Comment({required this.text, required this.sentiment});

  // Factory constructor to create a Comment from a map
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      text: map['comment'] ?? '',
      sentiment: map['sentiment'] ?? '',
    );
  }

  // Convert Comment to map
  Map<String, dynamic> toMap() {
    return {
      'comment': text,
      'sentiment': sentiment,
    };
  }
}
