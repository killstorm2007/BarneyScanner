import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:BarneyScanner/components/reusable_primary_button.dart';
import 'package:BarneyScanner/components/reusable_textfield.dart';
import 'package:BarneyScanner/controllers/auth_controllers.dart';
import 'package:BarneyScanner/views/auth/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthController authController = AuthController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        elevation: 15,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        actions: [Image.asset('assets/icon.png')],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              ReusableTextField(
                labelText: 'Nombre de Usuario (Nombre y Apellido)',
                controller: authController.nameController,
              ),
              SizedBox(height: 20),
              ReusableTextField(
                labelText: 'Correo Electronico',
                controller: authController.emailController,
              ),
              SizedBox(height: 20),
              ReusableTextField(
                labelText: 'Contraseña (Minimo 6 caracteres)',
                controller: authController.passwordController,
              ),
              SizedBox(height: 20),
              ReusablePrimaryButton(
                onTap: () {
                  authController.createAccount();
                },
                buttonText: 'Registrarse',
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ya tienes una cuenta?'),
                  TextButton(
                    onPressed: () {
                      Get.to(LoginScreen());
                    },
                    child: Text('Inicia Sesion'),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text('El correo electronico sera tu nombre de usuario'),
            ],
          ),
        ),
      ),
    );
  }
}
