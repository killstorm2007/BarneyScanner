import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductPage({
    required this.productId,
    required this.productData,
    Key? key,
  }) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;

  String? _imageBase64;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productData['name']);
    _descriptionController = TextEditingController(
      text: widget.productData['description'],
    );
    _categoryController = TextEditingController(
      text: widget.productData['category'],
    );
    _priceController = TextEditingController(text: widget.productData['price']);

    _imageBase64 = widget.productData['image'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final imageBytes = await picked.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(imageBytes);
        _imageFile = File(picked.path);
      });
    }
  }

  void _updateProduct() async {
    await FirebaseFirestore.instance
        .collection('productos')
        .doc(widget.productId)
        .update({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category': _categoryController.text,
          'price': _priceController.text,
          'image': _imageBase64 ?? '', // guarda nueva imagen si fue cambiada
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Producto actualizado')));
    Navigator.pop(context);
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, height: 150);
    } else if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      try {
        return Image.memory(base64Decode(_imageBase64!), height: 150);
      } catch (_) {
        return Text("No se puede mostrar la imagen.");
      }
    } else {
      return Text("No hay imagen seleccionada.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Producto'),
        centerTitle: true,
        shadowColor: Colors.grey,
        backgroundColor: Colors.blueGrey,
        elevation: 15,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImagePreview(),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('Cambiar Imagen'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
