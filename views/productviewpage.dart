import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart'; // Asegúrate de importar la pantalla de detalles

class ProductViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay productos aún'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];
              var productData = product.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading:
                      productData['image'] != null &&
                              productData['image'].isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(productData['image']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Icon(Icons.image, size: 50),
                  title: Text(productData['name'] ?? 'Sin nombre'),
                  subtitle: Text(productData['category'] ?? 'Sin categoría'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProductDetailPage(productData: productData),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
