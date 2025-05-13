import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_movie_page.dart';

class MovieManagerPage extends StatelessWidget {
  const MovieManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Administrar Películas'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddMoviePage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('movies')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data?.docs ?? [];

          if (movies.isEmpty) {
            return const Center(
              child: Text(
                'No hay películas registradas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final data = movie.data() as Map<String, dynamic>;

              return ListTile(
                leading: data['imageUrl'] != null
                    ? Image.network(data['imageUrl'],
                        width: 50, height: 70, fit: BoxFit.cover)
                    : const Icon(Icons.movie, color: Colors.white54, size: 40),
                title: Text(
                  data['title'] ?? 'Sin título',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Director: ${data['director'] ?? '-'}',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddMoviePage(
                              movieId: movie.id,
                              initialData: data,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('¿Eliminar película?'),
                            content:
                                const Text('Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Eliminar',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection('movies')
                              .doc(movie.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Película eliminada')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
