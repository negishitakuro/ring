import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ring/pages/index.dart';

class AuthPage extends StatelessWidget {
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(scopes: [
      'email',
    ]).signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Ring',
              style: TextStyle(fontSize: 60),
            ),
            const Text(
              'Voice Chat App',
              style: TextStyle(fontSize: 40),
            ),
            Container(
              margin: const EdgeInsets.all(20),
            ),
            ButtonTheme(
              minWidth: 350,
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final userCredential = await signInWithGoogle();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Google認証成功'),
                        duration: Duration(seconds: 1),
                      ));
                      await Navigator.of(context)
                          .pushReplacement(MaterialPageRoute<AuthPage>(
                              settings: const RouteSettings(name: "/index"),
                              builder: (context) {
                                return IndexPage();
                              }));
                    } on FirebaseAuthException catch (e) {
                      print('FirebaseAuthException');
                      print('${e.code}');
                    } on Exception catch (e) {
                      print('Other Exception');
                      print('${e.toString()}');
                    }
                  },
                  child: const Text(
                    'Google認証',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
