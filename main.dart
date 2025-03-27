import 'package:BarneyScanner/views/auth/login_screen.dart';
import 'package:BarneyScanner/views/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:BarneyScanner/firebase_options.dart';
import 'package:BarneyScanner/views/splash_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(useMaterial3: false),
      navigatorObservers: [routeObserver], // 👈 Aquí se incluye
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        "login": (context) => LoginScreen(),
        "home": (context) => HomePage(),
      },
    );
  }
}
