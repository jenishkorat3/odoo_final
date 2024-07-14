import 'dart:async';
import 'package:flutter/material.dart';
import 'package:odoo_hackathon/screens/auth/bottombar_screen.dart';
import 'package:odoo_hackathon/screens/auth/login_screen.dart';
import 'package:odoo_hackathon/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  bool loggedInStatus;
  SplashScreen({Key? key, required this.loggedInStatus}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.loggedInStatus) {
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BottomBarScreen()), (route) => false);
      });
    } else {
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/images/splash.jpg",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              "Rent Today, Enjoy Tomorrow",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
