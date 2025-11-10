import 'media_item.dart';

class Anime extends MediaItem {
  const Anime({
    required int malId,
    required String title,
    required String imageUrl,
    double? score,
    int? year,
    String? synopsis,
    List<String>? genres,
  }) : super(
          id: malId,
          title: title,
          imageUrl: imageUrl,
          score: score,
          year: year,
          synopsis: synopsis,
          genres: genres,
        );

  // Keep existing external API: malId maps to base id
  int get malId => id;

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
      genres: (json['genres'] as List<dynamic>?)?.map((g) {
        if (g is Map<String, dynamic>) {
          final name = g['name'];
          return name?.toString() ?? '';
        }
        return g.toString();
      }).toList(),
    );
  }

  @override
  String get type => 'Anime';

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
