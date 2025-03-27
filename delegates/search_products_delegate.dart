import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:BarneyScanner/models/producto.dart';

class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Agregar un botón para borrar la búsqueda.
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Limpiar el texto de búsqueda
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // El botón de retroceso que cierra la búsqueda
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Aquí puedes construir los resultados que se muestran después de una búsqueda.
    return _buildProductList(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Mostrar sugerencias mientras el usuario escribe.
    return _buildProductList(query);
  }

  // Esta función devuelve la lista de productos filtrados.
  Widget _buildProductList(String query) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('productos')
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThanOrEqualTo: query + '\uf8ff')
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay productos disponibles.'));
        }

        final products =
            snapshot.data!.docs.map((doc) {
              return Producto.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name ?? ''),
              subtitle: Text(product.description ?? ''),
              leading: Icon(Icons.shopping_bag),
              onTap: () {
                // Aquí puedes manejar la acción de selección de producto, si es necesario
                close(
                  context,
                  null,
                ); // Cerrar la búsqueda al seleccionar un producto
              },
            );
          },
        );
      },
    );
  }
}
