import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:odoo_hackathon/screens/auth/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odoo_hackathon/shared/constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundhandler);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundhandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isUserLoggedIn = false;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = auth.currentUser;

    if (user == null) {
      setState(() {
        isUserLoggedIn = false;
      });
    } else {
      isUserLoggedIn = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'odoo hackathon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      // home: RentItemScreen()
      home: SplashScreen(loggedInStatus: isUserLoggedIn,),
    );
  }
}
