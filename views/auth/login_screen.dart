import 'package:BarneyScanner/views/auth/recovery_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:BarneyScanner/components/reusable_primary_button.dart';
import 'package:BarneyScanner/components/reusable_textfield.dart';
import 'package:BarneyScanner/controllers/auth_controllers.dart';
import 'package:BarneyScanner/views/auth/sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthController authController = AuthController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
              Container(
                child: Text(
                  'Bienvenido!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                padding: EdgeInsets.only(top: 20),
              ),
              SizedBox(height: 20),
              ReusableTextField(
                labelText: 'Correo Electronico',
                controller: authController.loginEmailController,
              ),
              SizedBox(height: 20),
              ReusableTextField(
                labelText: 'Contraseña',
                controller: authController.loginPasswordController,
              ),
              SizedBox(height: 20),
              ReusablePrimaryButton(
                onTap: () {
                  authController.loginUser();
                },
                buttonText: 'Iniciar Sesion',
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No tienes cuenta?'),
                  TextButton(
                    onPressed: () {
                      Get.to(SignUpScreen());
                    },
                    child: Text('Registrate'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Olvidaste tu contraseña?'),
                  TextButton(
                    onPressed: () {
                      Get.to(PasswordResetPage());
                    },
                    child: Text('Recuperar Contraseña'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
