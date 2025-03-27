import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/userservices.dart';
import 'package:BarneyScanner/views/scannerpage.dart';

class FormAddProduct extends StatefulWidget {
  final String? barcode;
  const FormAddProduct({super.key, this.barcode});

  @override
  State<FormAddProduct> createState() => _FormAddProductState();
}

class _FormAddProductState extends State<FormAddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _imageBase64;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) {
      _barcodeController.text = widget.barcode!;
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _scanBarcodeAndSetText() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(returnOnlyCode: true),
      ),
    );
    if (scannedCode != null && scannedCode is String) {
      setState(() {
        _barcodeController.text = scannedCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Producto"),
        centerTitle: true,
        shadowColor: Colors.grey,
        backgroundColor: Colors.blueGrey,
        elevation: 15,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Código de barras con botón para escanear
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Código de Barras',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Escanear código',
                      onPressed: _scanBarcodeAndSetText,
                    ),
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
              ),
              _buildTextField(_nameController, 'Nombre del Producto'),
              _buildTextField(
                _descriptionController,
                'Descripción',
                maxLines: 3,
              ),
              _buildTextField(_categoryController, 'Categoría'),
              _buildTextField(_priceController, 'Precio'),
              const SizedBox(height: 10),

              // Imagen seleccionada
              _imageBytes != null
                  ? Image.memory(_imageBytes!, height: 150)
                  : const Text("No hay imagen seleccionada"),

              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar Imagen'),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool ok = await UserServices().addProduct(
                        _barcodeController.text,
                        _nameController.text,
                        _descriptionController.text,
                        _categoryController.text,
                        _priceController.text,
                        imageBase64: _imageBase64,
                      );
                      if (ok) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Producto agregado')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al guardar')),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}
