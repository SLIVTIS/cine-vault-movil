import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'movie_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Stream<QuerySnapshot> getMovieStream() {
    if (_searchTerm.isEmpty) {
      return FirebaseFirestore.instance
          .collection('movies')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('movies')
          .where('title_lowercase', isGreaterThanOrEqualTo: _searchTerm)
          .where('title_lowercase', isLessThanOrEqualTo: '$_searchTerm\uf8ff')
          .orderBy('title_lowercase')
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Catálogo', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white),
                  hintText: 'Buscar por título',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Películas disponibles',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Resultados
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getMovieStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final movies = snapshot.data?.docs ?? [];

                  if (movies.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron películas.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: movies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final movie =
                          movies[index].data() as Map<String, dynamic>;
                      final imageUrl = movie['imageUrl'] as String?;
                      final title = movie['title'] ?? 'Sin título';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(movie: movie),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.grey.shade800,
                                  ),
                                  child: imageUrl == null
                                      ? const Center(
                                          child: Icon(Icons.movie,
                                              color: Colors.white54),
                                        )
                                      : null,
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black54,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(Icons.play_arrow,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
