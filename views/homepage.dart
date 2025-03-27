import 'package:BarneyScanner/views/productviewpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:BarneyScanner/controllers/auth_controllers.dart';
import 'package:BarneyScanner/delegates/search_products_delegate.dart';
import 'package:BarneyScanner/views/addproductpage.dart';
import 'package:BarneyScanner/views/scannerpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool isAdmin = false;

  final AuthController authController = AuthController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('userRole') ?? 'user';
    setState(() {
      isAdmin = (role == 'admin');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages {
    List<Widget> pages = [
      _buildHistorialPage(),
      ProductViewPage(),
      _buildBuscarPage(),
      BarcodeScannerScreen(),
    ];
    if (isAdmin) pages.add(AddProductPage());
    return pages;
  }

  Widget _buildHistorialPage() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('scanHistory')
              .where('uid', isEqualTo: uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (uid.isEmpty) return Center(child: Text('Usuario no autenticado'));

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final history = snapshot.data?.docs ?? [];
        if (history.isEmpty) {
          return Center(child: Text("No hay productos escaneados aún"));
        }

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final data = history[index].data() as Map<String, dynamic>;
            final barcode = data['barcode'] ?? 'Código no disponible';
            final timestamp = data['timestamp']?.toDate();
            return ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text("Código: $barcode"),
              subtitle: Text(
                timestamp != null
                    ? "Escaneado el: ${timestamp.toString()}"
                    : "Sin fecha registrada",
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBuscarPage() {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.search),
        label: Text('Buscar productos'),
        onPressed: () {
          showSearch(context: context, delegate: ProductSearchDelegate());
        },
      ),
    );
  }

  Future<void> _eliminarHistorial() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('¿Eliminar historial?'),
            content: Text('Esta acción eliminará el historial. ¿Estás seguro?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final collection = FirebaseFirestore.instance.collection('scanHistory');
      final snapshot = await collection.where('uid', isEqualTo: uid).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Historial eliminado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Historial',
      'Ver Productos',
      'Buscar',
      'Scanner',
      if (isAdmin) 'Agregar',
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false, // <- Quita la flecha de "volver"
        backgroundColor: Colors.grey[350],
        elevation: 15,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        title: Text(titles[_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset('assets/icon.png', height: 30),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Cerrar Sesion'),
                  content: Text('¿Quieres cerrar sesion?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el diálogo
                      },
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        authController.logoutUser();
                      },
                      child: Text('Cerrar Sesion'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton.extended(
                onPressed: _eliminarHistorial,
                icon: Icon(Icons.delete_forever),
                label: Text("Borrar historial"),
                backgroundColor: Colors.red,
              )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Historial'),
          NavigationDestination(
            icon: Icon(Icons.view_list),
            label: 'Productos',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scanner'),
          if (isAdmin)
            NavigationDestination(icon: Icon(Icons.add), label: 'Agregar'),
        ],
      ),
    );
  }
}
