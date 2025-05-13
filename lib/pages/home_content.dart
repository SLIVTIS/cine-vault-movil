import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'movie_detail_page.dart';

class HomeContent extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const HomeContent({super.key, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('movies')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final movies = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top + 12,
            bottom: 50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Cine Vault + search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cine Vault',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      onPressed: onSearchTap,
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Featured Movie
              if (movies.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailPage(
                          movie: movies.first.data() as Map<String, dynamic>,
                        ),
                      ),
                    );
                  },
                  child: _buildFeaturedMovie(movies.first),
                ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Popular',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final data = movies[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailPage(movie: data),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade800,
                          image: data['imageUrl'] != null
                              ? DecorationImage(
                                  image: NetworkImage(data['imageUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: data['imageUrl'] == null
                            ? const Icon(Icons.movie, color: Colors.white70)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedMovie(QueryDocumentSnapshot movie) {
    final data = movie.data() as Map<String, dynamic>;

    return Center(
      child: Column(
        children: [
          Container(
            height: 340,
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: data['imageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(data['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey.shade800,
            ),
            child: data['imageUrl'] == null
                ? const Center(child: Icon(Icons.movie, color: Colors.white54))
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            data['title'] ?? 'Película',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data['director'] ?? 'Director desconocido',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text("Play"),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text("My Playlist"),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
