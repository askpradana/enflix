import 'package:enterkomputer/controller/detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enterkomputer/model/movie_model.dart';
import 'package:logger/logger.dart';

class MovieDetailPage extends GetView<MovieDetailController> {
  MovieDetailPage({Key? key}) : super(key: key);

  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    final MovieModel movie = Get.arguments as MovieModel;
    _logger.i('Building MovieDetailPage for: ${movie.title}');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text('Movie Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetX<MovieDetailController>(
        init: MovieDetailController(movie),
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoviePoster(controller),
                _buildMovieInfo(controller),
                _buildActionButtons(controller),
                _buildMovieOverview(controller),
                _buildSimilarMovies(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoviePoster(MovieDetailController controller) {
    return Stack(
      children: [
        Hero(
          tag: 'movie_poster_${controller.movieDetail.value.id}',
          child: CachedNetworkImage(
            imageUrl:
                'https://image.tmdb.org/t/p/w500${controller.movieDetail.value.posterPath}',
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            controller.movieDetail.value.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieInfo(MovieDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Release Date: ${controller.movieDetail.value.releaseDate}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow, size: 20),
              const SizedBox(width: 4),
              Text(
                '${controller.movieDetail.value.voteAverage.toStringAsFixed(1)}/10',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Text(
                '${controller.movieDetail.value.voteCount} votes',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Runtime: ${controller.movieDetail.value.runtime} minutes',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.movieDetail.value.genres
                .map((genre) => Chip(
                      label: Text(genre),
                      backgroundColor: Colors.grey[800],
                      labelStyle: const TextStyle(color: Colors.white),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MovieDetailController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.favorite,
            label: 'Favorite',
            isActive: controller.movieDetail.value.isFavorite,
            onPressed: controller.toggleFavorite,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.bookmark,
            label: 'Watchlist',
            isActive: controller.movieDetail.value.isWatchlisted,
            onPressed: controller.toggleWatchlist,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, color: isActive ? Colors.red : Colors.white),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? Colors.red.withOpacity(0.2) : Colors.grey[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildMovieOverview(MovieDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.movieDetail.value.overview,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMovies(MovieDetailController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Similar Movies',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.similarMovies.length,
            itemBuilder: (context, index) {
              final movie = controller.similarMovies[index];
              return Container(
                width: 120,
                margin: EdgeInsets.only(
                    left: 16,
                    right:
                        index == controller.similarMovies.length - 1 ? 16 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                        height: 160,
                        width: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[800]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
