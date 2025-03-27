import 'package:BarneyScanner/views/form_addproduct.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart';
import '../main.dart'; // 👈 Importa donde definiste el routeObserver

class BarcodeScannerScreen extends StatefulWidget {
  final bool returnOnlyCode;
  const BarcodeScannerScreen({Key? key, this.returnOnlyCode = false})
    : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with RouteAware {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isProcessing = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // 🔄 Reanudamos el escáner al volver a esta pantalla
    _controller.start();
    _isProcessing = false;
  }

  void _handleBarcode(String code) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _controller.stop(); // Detiene escaneo mientras procesa

    try {
      // Guardar en historial
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('scanHistory').add({
          'barcode': code,
          'timestamp': Timestamp.now(),
          'uid': currentUser.uid,
        });
      }

      // Verificar si producto existe
      final snapshot =
          await FirebaseFirestore.instance
              .collection('productos')
              .where('barcode', isEqualTo: code)
              .limit(1)
              .get();

      if (!mounted) return;

      if (!mounted) return;

      if (widget.returnOnlyCode) {
        Navigator.pop(context, code); // ← Devuelve solo el código al formulario
        return;
      }

      if (snapshot.docs.isNotEmpty && snapshot.docs.first.exists) {
        final productData = snapshot.docs.first.data();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(productData: productData),
          ),
        );
      } else {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Producto no Encontrado'),
              content: Text(
                'El producto no fue encontrado en la base de datos, ¿quieres agregarlo?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormAddProduct(barcode: code),
                      ),
                    );
                  },
                  child: Text('Agregar Producto'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error procesando el escaneo: $e")),
      );
      _controller.start(); // Reintenta si hubo error
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: _controller,
        onDetect: (barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          if (barcodes.isEmpty) return;
          final String? code = barcodes.first.rawValue;
          if (code == null) return;
          _handleBarcode(code);
        },
      ),
    );
  }
}
