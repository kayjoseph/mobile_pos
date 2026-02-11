import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_pos/LoginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();

    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Loginpage()
          ),
      );
    }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
                image: AssetImage('lib/Images/Reoprime Logo.png'),
              width: 180,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              'Sell.Manage.Grow',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            ),
          ],
        ),
      ),
    );
  }
}
