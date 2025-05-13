import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMoviePage extends StatefulWidget {
  final String? movieId;
  final Map<String, dynamic>? initialData;

  const AddMoviePage({super.key, this.movieId, this.initialData});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController synopsisController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();

  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      titleController.text = data['title'] ?? '';
      synopsisController.text = data['synopsis'] ?? '';
      yearController.text = data['year']?.toString() ?? '';
      directorController.text = data['director'] ?? '';
      genreController.text = data['genre'] ?? '';
      ratingController.text = data['rating']?.toString() ?? '';
      _imageUrl = data['imageUrl'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _imageUrl;

      if (_imageFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef =
            FirebaseStorage.instance.ref().child('movies/$fileName.jpg');
        final uploadTask = await storageRef.putFile(_imageFile!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      final data = {
        'title': titleController.text.trim(),
        'synopsis': synopsisController.text.trim(),
        'year': int.parse(yearController.text.trim()),
        'director': directorController.text.trim(),
        'genre': genreController.text.trim(),
        'rating': double.parse(ratingController.text.trim()),
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.movieId != null) {
        await FirebaseFirestore.instance
            .collection('movies')
            .doc(widget.movieId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Película actualizada correctamente')),
        );
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('movies').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Película subida exitosamente')),
        );
      }

      if (widget.movieId == null) {
        _formKey.currentState!.reset();
        titleController.clear();
        synopsisController.clear();
        yearController.clear();
        directorController.clear();
        genreController.clear();
        ratingController.clear();
        setState(() {
          _imageFile = null;
          _imageUrl = null;
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePreview() {
    Widget content;

    if (_imageFile != null) {
      content = Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_imageUrl != null) {
      content = Image.network(_imageUrl!, fit: BoxFit.cover);
    } else {
      content = const Center(
        child: Text(
          'Toca para seleccionar una imagen',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movieId != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          isEditing ? 'Editar Película' : 'Subir Película',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Nombre', titleController),
              _buildTextField('Sinopsis', synopsisController, maxLines: 3),
              _buildTextField('Año', yearController,
                  keyboardType: TextInputType.number),
              _buildTextField('Director', directorController),
              _buildTextField('Género', genreController),
              _buildTextField('Calificación (0.0 - 10.0)', ratingController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildImagePreview(),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: _uploadMovie,
                      child: Text(isEditing ? 'Guardar cambios' : 'Guardar película'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
