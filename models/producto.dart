class Producto {
  final String id;
  final String? name;
  final String? description;
  final String? category;
  final String? price;
  final String? barcode;
  final String? imageBase64; // Nueva propiedad

  Producto({
    required this.id,
    this.name,
    this.description,
    this.category,
    this.price,
    this.barcode,
    this.imageBase64,
  });

  factory Producto.fromFirestore(Map<String, dynamic> data, String id) {
    return Producto(
      id: id,
      name: data['name'],
      description: data['description'],
      category: data['category'],
      price: data['price'],
      barcode: data['barcode'],
      imageBase64: data['imageBase64'], // Nuevo campo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'barcode': barcode,
      'imageBase64': imageBase64,
    };
  }
}
