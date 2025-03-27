import 'package:BarneyScanner/models/producto.dart';
import 'package:BarneyScanner/services/userservices.dart';
import 'package:BarneyScanner/views/editproductscreen.dart';
import 'package:BarneyScanner/views/form_addproduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AddProductPage extends StatelessWidget {
  final String? barcode;
  const AddProductPage({Key? key, this.barcode}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormAddProduct()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: UserServices().getProductStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos aún.'));
          }
          snapshot.data!.docs.map((doc) {
            return Producto.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
          return ListView(
            children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['name'] ?? ''),
                    subtitle: Text(data['description'] ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('¿Eliminar producto?'),
                              content: Text(
                                '¿Estás seguro de que deseas eliminar este producto?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Cierra el diálogo
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Cierra el diálogo
                                    await UserServices().deleteProduct(
                                      document.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Producto eliminado'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    leading: IconButton(
                      onPressed: () {
                        // Aquí es donde corregimos el error de pasar los datos al EditProductPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProductPage(
                                  productId: document.id,
                                  productData:
                                      data, // Pasamos los datos directamente
                                ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
