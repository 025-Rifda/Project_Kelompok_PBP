class Anime {
  final int malId;
  final String title;
  final String imageUrl;
  final double? score;
  final int? year;
  final String? synopsis;
  final List<String>? genres;

  Anime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.score,
    this.year,
    this.synopsis,
    this.genres,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] is int
          ? json['mal_id']
          : int.tryParse(json['mal_id'].toString()) ?? 0,
      title: json['title'] ?? 'No Title',
      imageUrl: json['images']?['jpg']?['image_url'] ?? json['imageUrl'] ?? '',
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? ''),
      synopsis: json['synopsis'],
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => g['name'] as String)
          .toList(),
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
      'genres': genres,
    };
  }
}
