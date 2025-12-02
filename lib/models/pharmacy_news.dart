class PharmacyNews {
  final String id;
  final String title;
  final String preview;
  final String imageUrl;
  final String type;
  final String content;
  final DateTime publishDate;

  PharmacyNews({
    required this.id,
    required this.title,
    required this.preview,
    required this.imageUrl,
    required this.type,
    required this.content,
    required this.publishDate,
  });

  factory PharmacyNews.fromJson(Map<String, dynamic> json) {
    return PharmacyNews(
      id: json['id'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      type: json['type'] as String? ?? 'news',
      content: json['content'] as String? ?? '',
      publishDate: DateTime.parse(json['publishDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'imageUrl': imageUrl,
      'type': type,
      'content': content,
      'publishDate': publishDate.toIso8601String(),
    };
  }

  String get emoji {
    switch (type.toLowerCase()) {
      case 'tip':
        return '💡';
      case 'alert':
        return '⚠️';
      case 'update':
        return '🔄';
      default:
        return '📰';
    }
  }
}
