import 'package:get/get.dart';
import 'package:enterkomputer/model/movie_model.dart';
import 'package:enterkomputer/core/api.dart';
import 'package:logger/logger.dart';

/// Controller for managing the state and actions of the MovieDetailPage.
class MovieDetailController extends GetxController {
  final BaseApiService _api = BaseApiService();
  final Logger _logger = Logger();

  late Rx<MovieDetailModel> movieDetail;
  final RxBool isLoading = true.obs;

  MovieDetailController(MovieModel movie) {
    movieDetail = MovieDetailModel.fromMovieModel(movie).obs;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMovieDetails();
  }

  /// Fetches detailed movie information from the API.
  Future<void> fetchMovieDetails() async {
    try {
      isLoading.value = true;
      _logger.i('Fetching details for movie ${movieDetail.value.id}');

      final response = await _api.get('/movie/${movieDetail.value.id}');
      final detailedMovie = MovieDetailModel.fromJson(response);

      // Preserve favorite and watchlist status
      detailedMovie.isFavorite = movieDetail.value.isFavorite;
      detailedMovie.isWatchlisted = movieDetail.value.isWatchlisted;

      movieDetail.value = detailedMovie;
      _logger
          .i('Successfully fetched details for movie ${movieDetail.value.id}');
    } catch (e) {
      _logger.e('Error fetching movie details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggles the favorite status of the movie.
  Future<void> toggleFavorite() async {
    try {
      final newFavoriteStatus = !movieDetail.value.isFavorite;
      _logger.i(
          'Toggling favorite for movie ${movieDetail.value.id} to $newFavoriteStatus');

      final response =
          await _api.post('/account/${_api.defaultAccountID}/favorite', {
        'media_type': 'movie',
        'media_id': movieDetail.value.id,
        'favorite': newFavoriteStatus,
      });

      if (response['success'] == true) {
        movieDetail.update((val) {
          val?.isFavorite = newFavoriteStatus;
        });
        _logger.i(
            'Successfully updated favorite status for movie ${movieDetail.value.id}');
      } else {
        _logger.w(
            'Failed to update favorite status: ${response['status_message']}');
      }
    } catch (e) {
      _logger.e('Error toggling favorite: $e');
    }
  }

  /// Toggles the watchlist status of the movie.
  Future<void> toggleWatchlist() async {
    try {
      final newWatchlistStatus = !movieDetail.value.isWatchlisted;
      _logger.i(
          'Toggling watchlist for movie ${movieDetail.value.id} to $newWatchlistStatus');

      final response =
          await _api.post('/account/${_api.defaultAccountID}/watchlist', {
        'media_type': 'movie',
        'media_id': movieDetail.value.id,
        'watchlist': newWatchlistStatus,
      });

      if (response['success'] == true) {
        movieDetail.update((val) {
          val?.isWatchlisted = newWatchlistStatus;
        });
        _logger.i(
            'Successfully updated watchlist status for movie ${movieDetail.value.id}');
      } else {
        _logger.w(
            'Failed to update watchlist status: ${response['status_message']}');
      }
    } catch (e) {
      _logger.e('Error toggling watchlist: $e');
    }
  }
}
