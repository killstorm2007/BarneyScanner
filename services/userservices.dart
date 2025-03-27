import 'package:cloud_firestore/cloud_firestore.dart';

class UserServices {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('productos');

  Future<bool> addProduct(
    String barcode,
    String name,
    String description,
    String category,
    String price, {
    String? imageBase64, // ← Nuevo parámetro opcional
  }) async {
    try {
      await _productsCollection.add({
        'barcode': barcode,
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'imageBase64': imageBase64 ?? '', // ← Guardar la imagen si existe
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error al agregar producto: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> getProductStream() {
    return _productsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error al obtenero productos: $error');
        });
  }

  Future<void> deleteProduct(String documentId) async {
    try {
      await _productsCollection.doc(documentId).delete();
    } catch (e) {
      print('Error al eliminar el producto: $e');
    }
  }
}
