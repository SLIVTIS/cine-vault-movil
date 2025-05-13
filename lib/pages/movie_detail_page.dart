import 'package:flutter/material.dart';

class MovieDetailPage extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final imageUrl = movie['imageUrl'];
    final title = movie['title'] ?? 'Sin título';
    final year = movie['year']?.toString() ?? '';
    final director = movie['director'] ?? '';
    final genre = movie['genre'] ?? '';
    final synopsis = movie['synopsis'] ?? '';
    final rating = movie['rating']?.toString() ?? '0.0';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen destacada
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey.shade900,
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Icon(Icons.movie, color: Colors.white54, size: 60),
                    )
                  : null,
            ),
            const SizedBox(height: 24),

            // Tarjeta de información
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    '$title (${year})',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Fila de metadatos
                  Row(
                    children: [
                      _iconWithText(Icons.person, 'Director: $director'),
                      const SizedBox(width: 16),
                      _iconWithText(Icons.category, genre),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _iconWithText(Icons.star, 'Calificación: $rating / 10',
                      iconColor: Colors.amber),

                  const Divider(color: Colors.white24, height: 32),

                  // Sinopsis
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    synopsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconWithText(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.white54),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
