import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ring/model/akashi_user.dart';
import 'package:ring/pages/auth.dart';
import 'package:ring/pages/index.dart';
import 'package:ring/utils/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            akshiUser = AkashiUser(
                FirebaseAuth.instance.currentUser!.displayName!,
                FirebaseAuth.instance.currentUser!.photoURL!);
            return IndexPage();
          }
          return AuthPage();
        },
      ),
    );
  }
}
