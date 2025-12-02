class AdBanner {
  final String id;
  final String imageUrl;
  final String clickUrl;
  final double aspectRatio;
  final int minHeight;
  final int maxHeight;
  final String position;

  AdBanner({
    required this.id,
    required this.imageUrl,
    required this.clickUrl,
    this.aspectRatio = 3.0,
    this.minHeight = 120,
    this.maxHeight = 200,
    this.position = 'top',
  });

  factory AdBanner.fromJson(Map<String, dynamic> json) {
    return AdBanner(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      clickUrl: json['clickUrl'] as String,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 3.0,
      minHeight: json['minHeight'] as int? ?? 120,
      maxHeight: json['maxHeight'] as int? ?? 200,
      position: json['position'] as String? ?? 'top',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'clickUrl': clickUrl,
      'aspectRatio': aspectRatio,
      'minHeight': minHeight,
      'maxHeight': maxHeight,
      'position': position,
    };
  }
}
