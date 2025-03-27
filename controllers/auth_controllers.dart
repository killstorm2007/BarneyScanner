import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:BarneyScanner/views/homepage.dart';
import 'package:BarneyScanner/views/auth/login_screen.dart';

class AuthController extends GetxController {
  // Registro
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Login
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTRO
  Future<void> createAccount() async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final firestore = FirebaseFirestore.instance;

      // Guardar datos del usuario en Firestore
      await firestore.collection('users').doc(user.user!.uid).set({
        'name': nameController.text,
        "email": emailController.text,
        "password": passwordController.text, // ⚠ Solo para pruebas
        "role": "user",
      });

      print("Usuario registrado y datos guardados");
      Get.to(LoginScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocurrió un error al crear la cuenta';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'El correo electrónico ya está registrado.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido.';
          break;
        case 'weak-password':
          errorMessage =
              'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
          break;
        default:
          errorMessage = e.message ?? 'Error desconocido';
      }
      Get.snackbar(
        'Registro fallido',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error al registrar: $e');
    } catch (e) {
      Get.snackbar(
        'Registro fallido',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error inesperado al registrar: $e');
    }
  }

  // LOGIN
  Future<void> loginUser() async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      if (user.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userID', user.user!.uid);

        final firestore = FirebaseFirestore.instance;
        final doc =
            await firestore.collection('users').doc(user.user!.uid).get();

        if (doc.exists) {
          final role = doc['role'];
          prefs.setString('userRole', role);
          print('Rol del usuario: $role');
        }

        Get.offAll(HomePage());
      } else {
        Get.snackbar(
          'Error',
          'No se pudo iniciar sesión',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocurrió un error al iniciar sesión';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'El usuario no existe.';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta.';
          break;
        case 'invalid-email':
          errorMessage = 'Correo electrónico inválido.';
          break;
        case 'network-request-failed':
          errorMessage = 'Error de red. Verifica tu conexión.';
          break;
        default:
          errorMessage = e.message ?? 'Error desconocido';
      }
      Get.snackbar(
        'Inicio de sesión fallido',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error al iniciar sesión: $e');
    } catch (e) {
      Get.snackbar(
        'Inicio de sesión fallido',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error inesperado al iniciar sesión: $e');
    }
  }

  // LOGOUT
  Future<void> logoutUser() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAll(LoginScreen());
  }
}
