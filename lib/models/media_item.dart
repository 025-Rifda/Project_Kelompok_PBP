abstract class MediaItem {
  final int _id;
  final String _title;
  final String _imageUrl;
  final double? _score;
  final int? _year;
  final String? _synopsis;
  final List<String>? _genres;

  const MediaItem({
    required int id,
    required String title,
    required String imageUrl,
    double? score,
    int? year,
    String? synopsis,
    List<String>? genres,
  })  : _id = id,
        _title = title,
        _imageUrl = imageUrl,
        _score = score,
        _year = year,
        _synopsis = synopsis,
        _genres = genres;

  // Encapsulated getters
  int get id => _id;
  String get title => _title;
  String get imageUrl => _imageUrl;
  double? get score => _score;
  int? get year => _year;
  String? get synopsis => _synopsis;
  List<String>? get genres => _genres;

  // Polymorphic surface
  String get type;

  // Default score label; subclasses can override for custom behavior.
  String scoreLabel() => score?.toStringAsFixed(1) ?? 'N/A';
}

