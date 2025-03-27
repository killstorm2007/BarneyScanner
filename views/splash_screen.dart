import 'package:BarneyScanner/views/auth/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var d = const Duration(seconds: 4);
    Future.delayed(d, () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/icon.png')),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                title: Text('BarneyScanner', textAlign: TextAlign.center),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(50),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator(color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }
}
