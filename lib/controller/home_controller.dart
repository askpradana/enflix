import 'package:enterkomputer/controller/profile_controller.dart';
import 'package:enterkomputer/core/api.dart';
import 'package:enterkomputer/model/movie_model.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Controller responsible for managing movie-related data and operations.
class HomeController extends GetxController {
  /// List of now playing movies.
  final RxList<NowPlayingMovie> nowPlayingMovies = <NowPlayingMovie>[].obs;

  /// List of popular movies.
  final RxList<PopularMovie> popularMovies = <PopularMovie>[].obs;

  /// Loading state of the controller.
  final RxBool isLoading = true.obs;

  /// API service for making http requests.
  final BaseApiService _api = BaseApiService();

  /// Default account ID for the current user.
  final String _accountId = '21424578';

  /// Logger instance for debugging and error reporting.
  final Logger _logger = Logger();

  /// Maximum number of now playing movies to display.
  static const int _maxNowPlayingMovies = 6;

  /// Maximum number of popular movies to display.
  static const int _maxPopularMovies = 20;

  /// Implement navigation bar functionality.
  final RxInt currentIndex = 0.obs;

  RxString titleAppbar = 'Enflix'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMovies();
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
    if (index == 0) {
      titleAppbar.value = 'Enflix';
    } else {
      titleAppbar.value = 'Profile';
      ProfileController controller = Get.find();
      controller.checkSession();
    }
  }

  /// Fetch movies data.
  Future<void> fetchMovies() async {
    try {
      final nowPlayingResponse = await _api.get('/movie/now_playing');
      final popularResponse = await _api.get('/movie/popular');

      _processNowPlayingMovies(nowPlayingResponse);
      _processPopularMovies(popularResponse);

      await Future.wait([
        fetchFavoriteStatus(),
        fetchWatchlistStatus(),
      ]);
    } catch (e) {
      _logger.e('Error fetching movies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Processes the now playing movies response.
  void _processNowPlayingMovies(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('results')) {
      nowPlayingMovies.value = (response['results'] as List)
          .take(_maxNowPlayingMovies)
          .map((json) => NowPlayingMovie.fromJson(json))
          .toList();
    }
  }

  /// Processes the popular movies response.
  void _processPopularMovies(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('results')) {
      popularMovies.value = (response['results'] as List)
          .take(_maxPopularMovies)
          .map((json) => PopularMovie.fromJson(json))
          .toList();
    }
  }

  /// Fetches favorite status for movies.
  Future<void> fetchFavoriteStatus() async {
    try {
      final response = await _api.get('/account/$_accountId/favorite/movies');
      if (response is Map<String, dynamic> && response.containsKey('results')) {
        final favoriteIds =
            (response['results'] as List).map((m) => m['id'] as int).toSet();
        _updateFavoriteStatus(favoriteIds);
      }
    } catch (e) {
      _logger.e('Error fetching favorite status: $e');
    }
  }

  /// Updates favorite status for movies.
  void _updateFavoriteStatus(Set<int> favoriteIds) {
    for (var movie in [...nowPlayingMovies, ...popularMovies]) {
      movie.isFavorite = favoriteIds.contains(movie.id);
    }
    nowPlayingMovies.refresh();
    popularMovies.refresh();
  }

  /// Fetches watchlist status for movies.
  Future<void> fetchWatchlistStatus() async {
    try {
      final response = await _api.get('/account/$_accountId/watchlist/movies');
      if (response is Map<String, dynamic> && response.containsKey('results')) {
        final watchlistIds =
            (response['results'] as List).map((m) => m['id'] as int).toSet();
        _updateWatchlistStatus(watchlistIds);
      }
    } catch (e) {
      _logger.e('Error fetching watchlist status: $e');
    }
  }

  /// Updates watchlist status for movies.
  void _updateWatchlistStatus(Set<int> watchlistIds) {
    for (var movie in [...nowPlayingMovies, ...popularMovies]) {
      movie.isWatchlisted = watchlistIds.contains(movie.id);
    }
    nowPlayingMovies.refresh();
    popularMovies.refresh();
  }

  /// Toggles the favorite status of a movie.
  Future<void> toggleFavorite(MovieModel movie) async {
    try {
      final newFavoriteStatus = !movie.isFavorite;
      _logger
          .i('Toggling favorite for movie ${movie.id} to $newFavoriteStatus');

      final response = await _api.post('/account/$_accountId/favorite', {
        'media_type': 'movie',
        'media_id': movie.id,
        'favorite': newFavoriteStatus,
      });

      if (response['success'] == true) {
        movie.isFavorite = newFavoriteStatus;
        _refreshMovieLists();
        _logger.i(
            'Successfully updated favorite status for movie ${movie.id} to $newFavoriteStatus');
      } else {
        _logger.w(
            'Failed to update favorite status: ${response['status_message']}');
      }
    } catch (e) {
      _logger.e('Error toggling favorite: $e');
    }
  }

  /// Toggles the watchlist status of a movie.
  Future<void> toggleWatchlist(MovieModel movie) async {
    try {
      final newWatchlistStatus = !movie.isWatchlisted;
      _logger
          .i('Toggling watchlist for movie ${movie.id} to $newWatchlistStatus');

      final response = await _api.post('/account/$_accountId/watchlist', {
        'media_type': 'movie',
        'media_id': movie.id,
        'watchlist': newWatchlistStatus,
      });

      if (response['success'] == true) {
        movie.isWatchlisted = newWatchlistStatus;
        _refreshMovieLists();
        _logger.i(
            'Successfully updated watchlist status for movie ${movie.id} to $newWatchlistStatus');
      } else {
        _logger.w(
            'Failed to update watchlist status: ${response['status_message']}');
      }
    } catch (e) {
      _logger.e('Error toggling watchlist: $e');
    }
  }

  /// Refreshes the movie lists to reflect changes.
  void _refreshMovieLists() {
    nowPlayingMovies.refresh();
    popularMovies.refresh();
  }
}
