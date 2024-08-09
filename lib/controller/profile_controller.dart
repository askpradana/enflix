import 'package:get/get.dart';
import 'package:enterkomputer/core/api.dart';
import 'package:enterkomputer/model/movie_model.dart';
import 'package:logger/logger.dart';
import 'package:enterkomputer/webview.dart';

/// Controller for managing user profile data and authentication.
class ProfileController extends GetxController {
  /// List of movies in the user's watchlist.
  final RxList<MovieModel> watchlistMovies = <MovieModel>[].obs;

  /// List of movies marked as favorites by the user.
  final RxList<MovieModel> favoriteMovies = <MovieModel>[].obs;

  /// Indicates whether the controller is currently loading data.
  final RxBool isLoading = true.obs;

  /// The current session ID for the authenticated user.
  final RxString sessionId = ''.obs;

  /// The request token used for authentication.
  final RxString requestToken = ''.obs;

  final BaseApiService _api = BaseApiService();
  final Logger _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  /// Checks if a valid session exists and fetches profile data if it does.
  void checkSession() {
    sessionId.value = _api.sessionId ?? '';
    if (sessionId.isNotEmpty) {
      fetchProfileData();
    } else {
      isLoading.value = false;
    }
  }

  /// Initiates the login process by requesting a new token.
  Future<void> initiateLogin() async {
    try {
      isLoading.value = true;
      var response = await _api.get('/authentication/token/new');
      if (response != null && response['request_token'] != null) {
        requestToken.value = response['request_token'];
        await _openWebView();
      } else {
        _logger.e('Failed to get initial request token');
      }
    } catch (e) {
      _logger.e('Error during login initiation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens a WebView for user authentication.
  Future<void> _openWebView() async {
    await Get.to(() => WebViewAuth(requestToken: requestToken.value));
    await Future.delayed(const Duration(seconds: 1));
    await _createSession();
  }

  /// Creates a new session after successful authentication.
  Future<void> _createSession() async {
    try {
      var response = await _api.post(
          '/authentication/session/new', {'request_token': requestToken.value});

      if (response['success'] == true) {
        sessionId.value = response['session_id'];
        _api.setSessionId = sessionId.value;
        await fetchProfileData();
      } else {
        _logger.e('Failed to create session. Response: $response');
      }
    } catch (e) {
      _logger.e('Error creating session: $e');
    }
  }

  /// Fetches all profile-related data (watchlist and favorites).
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchWatchlist(),
        fetchFavorites(),
      ]);
    } catch (e) {
      _logger.e('Error fetching profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches the user's movie watchlist.
  Future<void> fetchWatchlist() async {
    try {
      final response =
          await _api.get('/account/${_api.defaultAccountID}/watchlist/movies');
      if (response is Map<String, dynamic> && response.containsKey('results')) {
        watchlistMovies.value = (response['results'] as List)
            .map((json) => MovieModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      _logger.e('Error fetching watchlist: $e');
    }
  }

  /// Fetches the user's favorite movies.
  Future<void> fetchFavorites() async {
    try {
      final response =
          await _api.get('/account/${_api.defaultAccountID}/favorite/movies');
      if (response is Map<String, dynamic> && response.containsKey('results')) {
        favoriteMovies.value = (response['results'] as List)
            .map((json) => MovieModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      _logger.e('Error fetching favorites: $e');
    }
  }
}
