class Anime {
  final int malId;
  final String title;
  final String imageUrl;
  final double? score;
  final int? year;
  final String? synopsis;

  Anime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
    this.year,
    this.synopsis,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      imageUrl: json['images']['jpg']['image_url'] ?? '',
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      year: json['year'],
      synopsis: json['synopsis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'images': {
        'jpg': {'image_url': imageUrl},
      },
      'score': score,
      'year': year,
      'synopsis': synopsis,
    };
  }
}
