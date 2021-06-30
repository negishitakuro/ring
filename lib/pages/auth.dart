import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthPage extends StatelessWidget {
  static final googleLogin = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);

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
            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final userCredential = await signInWithGoogle();
                      Navigator.of(context)
                          .push(MaterialPageRoute<AuthPage>(builder: (context) {
                        return AuthPage();
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
            // ButtonTheme(
            //   minWidth: 350.0,
            //   // height: 100.0,
            //   child: RaisedButton(
            //       child: Text(
            //         'Google認証ログアウト',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //       textColor: Colors.white,
            //       color: Colors.grey,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       onPressed: () {
            //         _auth.signOut();
            //         _google_signin.signOut();
            //         print('サインアウトしました。');
            //       }),
            // ),
            // Text('別のGoogleアカウントでログインしたい場合、一回ログアウトする必要がある。'),
          ],
        ),
      ),
    );
  }
}
