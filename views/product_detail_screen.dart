import 'dart:convert';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({Key? key, required this.productData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Producto'),
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 15,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productData['image'] != null && productData['image'].isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(productData['image']),
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Center(child: Icon(Icons.image, size: 150, color: Colors.grey)),
            const SizedBox(height: 20),
            Text(
              'Nombre:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(productData['name'] ?? 'Sin nombre'),
            const SizedBox(height: 10),
            Text(
              'Categoría:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(productData['category'] ?? 'Sin categoría'),
            const SizedBox(height: 10),
            Text(
              'Descripción:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(productData['description'] ?? 'Sin descripción'),
            const SizedBox(height: 10),
            Text(
              'Precio:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(productData['price'] ?? 'Sin precio'),
          ],
        ),
      ),
    );
  }
}
