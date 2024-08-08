import 'package:enterkomputer/detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enterkomputer/controller/home_controller.dart';
import 'package:enterkomputer/model/movie_model.dart';
import 'package:logger/logger.dart';

/// HomePage widget that displays a list of now playing and popular movies.
class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  @override
  final HomeController controller = Get.put(HomeController());
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Movie App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _buildContent()),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Builds the main content of the page.
  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildNowPlayingSection(),
        _buildPopularMoviesHeader(),
        _buildPopularMoviesGrid(),
      ],
    );
  }

  /// "Now Playing" section.
  Widget _buildNowPlayingSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Now Playing',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.nowPlayingMovies.length,
                  itemBuilder: (context, index) =>
                      _buildMovieCard(controller.nowPlayingMovies[index]),
                )),
          ),
        ],
      ),
    );
  }

  /// Card widgets for a movie in the "Now Playing" section.
  Widget _buildMovieCard(MovieModel movie) {
    return GestureDetector(
        onTap: () => _navigateToMovieDetail(movie),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                      width: 160,
                      height: 240,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[800]),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        _buildAnimatedIconButton(
                          icon: Icons.favorite,
                          activeColor: Colors.red,
                          inactiveColor: Colors.white,
                          onPressed: () => controller.toggleFavorite(movie),
                          isActive: movie.isFavorite,
                        ),
                        const SizedBox(height: 8),
                        _buildAnimatedIconButton(
                          icon: Icons.bookmark,
                          activeColor: Colors.yellow,
                          inactiveColor: Colors.white,
                          onPressed: () => controller.toggleWatchlist(movie),
                          isActive: movie.isWatchlisted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 160,
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ));
  }

  /// Header for the "Popular Movies" section.
  Widget _buildPopularMoviesHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Movies',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the grid of popular movies.
  Widget _buildPopularMoviesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: Obx(() => SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildPopularMovieItem(controller.popularMovies[index]),
              childCount: controller.popularMovies.length,
            ),
          )),
    );
  }

  /// Builds an item for a popular movie.
  Widget _buildPopularMovieItem(PopularMovie movie) {
    return GestureDetector(
      onTap: () => _navigateToMovieDetail(movie),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[800]),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      _buildAnimatedIconButton(
                        icon: Icons.favorite,
                        activeColor: Colors.red,
                        inactiveColor: Colors.white,
                        onPressed: () => controller.toggleFavorite(movie),
                        isActive: movie.isFavorite,
                      ),
                      const SizedBox(height: 8),
                      _buildAnimatedIconButton(
                        icon: Icons.bookmark,
                        activeColor: Colors.yellow,
                        inactiveColor: Colors.white,
                        onPressed: () => controller.toggleWatchlist(movie),
                        isActive: movie.isWatchlisted,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an animated icon button for favorites and watchlist.
  Widget _buildAnimatedIconButton({
    required IconData icon,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: TweenAnimationBuilder(
        tween: ColorTween(
            begin: isActive ? activeColor : inactiveColor,
            end: isActive ? activeColor : inactiveColor),
        duration: const Duration(milliseconds: 300),
        builder: (context, Color? tweenColor, child) {
          return TweenAnimationBuilder(
            tween: Tween<double>(
                begin: isActive ? 1.2 : 1, end: isActive ? 1.2 : 1),
            duration: const Duration(milliseconds: 200),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: tweenColor,
                    size: 24,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Builds the bottom navigation bar.
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation
      },
    );
  }

  void _navigateToMovieDetail(MovieModel movie) {
    _logger.i('Navigating to movie detail for: ${movie.title}');
    Get.to(() => MovieDetailPage(), arguments: movie);
  }
}
