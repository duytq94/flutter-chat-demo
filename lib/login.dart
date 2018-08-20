import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_demo/const.dart';
import 'package:flutter_chat_demo/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: new ThemeData(
        primaryColor: themeColor,
      ),
      home: LoginScreen(title: 'CHAT DEMO'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  FirebaseUser currentUser;

  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getString('id') != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      this.setState(() {
        isLoading = true;
      });

      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      if (firebaseUser != null) {
        // Update data to local
        currentUser = firebaseUser;
        saveLocal();

        // Update data to server
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({'nickname': firebaseUser.displayName, 'photoUrl': firebaseUser.photoUrl});

        Fluttertoast.showToast(msg: "Sign in success");
        this.setState(() {
          isLoading = false;
        });

        Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        Fluttertoast.showToast(msg: "Sign in fail");
        this.setState(() {
          isLoading = false;
        });
      }
    }
  }

  void saveLocal() async {
    await prefs.setString('id', currentUser.uid);
    await prefs.setString('nickname', currentUser.displayName);
    await prefs.setString('photoUrl', currentUser.photoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: FlatButton(
                  onPressed: handleSignIn,
                  child: Text(
                    'SIGN IN WITH GOOGLE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Color(0xffdd4b39),
                  highlightColor: Color(0xffff7f7f),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        ));
  }
}
