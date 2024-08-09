import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enterkomputer/controller/profile_controller.dart';
import 'package:enterkomputer/model/movie_model.dart';

class ProfilePage extends GetView<ProfileController> {
  ProfilePage({Key? key}) : super(key: key);

  @override
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.sessionId.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () => controller.initiateLogin(),
              child: const Text('Login'),
            ),
          );
        } else {
          return _buildContent();
        }
      }),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildWatchlistSection(),
        _buildFavoritesSection(),
      ],
    );
  }

  Widget _buildWatchlistSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Watchlist',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: Obx(() {
              if (controller.watchlistMovies.isEmpty) {
                return const Center(
                  child: Text(
                    'Add something to your watchlist',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.watchlistMovies.length,
                itemBuilder: (context, index) =>
                    _buildMovieCard(controller.watchlistMovies[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Favorites',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: Obx(() {
              if (controller.favoriteMovies.isEmpty) {
                return const Center(
                  child: Text(
                    'Add something to your favorites',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.favoriteMovies.length,
                itemBuilder: (context, index) =>
                    _buildMovieCard(controller.favoriteMovies[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: CachedNetworkImage(
              imageUrl: 'https://image.tmdb.org/t/p/w200${movie.posterPath}',
              width: 160,
              height: 240,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[800]),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
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
    );
  }
}
