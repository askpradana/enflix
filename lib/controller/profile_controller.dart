import 'package:get/get.dart';
import 'package:enterkomputer/core/api.dart';
import 'package:enterkomputer/model/movie_model.dart';
import 'package:logger/logger.dart';
import 'package:enterkomputer/webview.dart';

class ProfileController extends GetxController {
  final RxList<MovieModel> watchlistMovies = <MovieModel>[].obs;
  final RxList<MovieModel> favoriteMovies = <MovieModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString sessionId = ''.obs;
  final RxString requestToken = ''.obs;

  final BaseApiService _api = BaseApiService();
  final Logger _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  void checkSession() {
    sessionId.value = _api.sessionId ?? '';
    if (sessionId.isNotEmpty) {
      fetchProfileData();
    } else {
      isLoading.value = false;
    }
  }

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

  Future<void> _openWebView() async {
    await Get.to(() => WebViewAuth(requestToken: requestToken.value));
    await Future.delayed(const Duration(seconds: 1));
    await _createSession();
  }

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
