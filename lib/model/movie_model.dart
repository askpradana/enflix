/// Base model for common movie properties
abstract class MovieModel {
  int get id;
  String get title;
  String get posterPath;
  bool get isFavorite;
  set isFavorite(bool value);
  bool get isWatchlisted;
  set isWatchlisted(bool value);

  static MovieModel fromJson(Map<String, dynamic> json) {
    // Determine which concrete class to instantiate based on the available data
    if (json.containsKey('runtime')) {
      return MovieDetailModel.fromJson(json);
    } else if (json.containsKey('vote_average')) {
      return PopularMovie.fromJson(json);
    } else {
      return NowPlayingMovie.fromJson(json);
    }
  }
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

/// Model for movie detail
class MovieDetailModel implements MovieModel {
  @override
  final int id;
  @override
  final String title;
  @override
  final String posterPath;
  final String? backdropPath;
  final String overview;
  final String releaseDate;
  final List<String> genres;
  final int runtime;
  final double voteAverage;
  final int voteCount;
  @override
  bool isFavorite;
  @override
  bool isWatchlisted;

  MovieDetailModel({
    required this.id,
    required this.title,
    required this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.voteAverage,
    required this.voteCount,
    this.isFavorite = false,
    this.isWatchlisted = false,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailModel(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => genre['name'] as String)
              .toList() ??
          [],
      runtime: json['runtime'] ?? 0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
    );
  }

  factory MovieDetailModel.fromMovieModel(MovieModel movie) {
    return MovieDetailModel(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      overview: '',
      releaseDate: '',
      genres: [],
      runtime: 0,
      voteAverage: 0,
      voteCount: 0,
      isFavorite: movie.isFavorite,
      isWatchlisted: movie.isWatchlisted,
    );
  }
}
