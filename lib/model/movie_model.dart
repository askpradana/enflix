/// Base model for common movie properties
abstract class MovieModel {
  int get id;
  String get title;
  String get posterPath;
  bool get isFavorite;
  set isFavorite(bool value);
  bool get isWatchlisted;
  set isWatchlisted(bool value);
}

/// Model for now playing section
class NowPlayingMovie implements MovieModel {
  @override
  final int id;
  @override
  final String title;
  @override
  final String posterPath;
  @override
  bool isFavorite;
  @override
  bool isWatchlisted;

  NowPlayingMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    this.isFavorite = false,
    this.isWatchlisted = false,
  });

  factory NowPlayingMovie.fromJson(Map<String, dynamic> json) {
    return NowPlayingMovie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
    );
  }
}

/// Model for popular movies
class PopularMovie implements MovieModel {
  @override
  final int id;
  @override
  final String title;
  @override
  final String posterPath;
  final double voteAverage;
  @override
  bool isFavorite;
  @override
  bool isWatchlisted;

  PopularMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    this.isFavorite = false,
    this.isWatchlisted = false,
  });

  factory PopularMovie.fromJson(Map<String, dynamic> json) {
    return PopularMovie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
    );
  }
}
