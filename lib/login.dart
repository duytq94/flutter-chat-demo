import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_demo/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Chat Demo',
      theme: new ThemeData(
        primaryColor: new Color(0xfff5a623),
      ),
      home: new LoginScreen(title: 'CHAT DEMO'),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/main': (_) => new Main(), // Home Page
      },
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

  bool isLoading = false;

  Future<Null> handleSignIn() async {
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
      // Update data to server
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({'displayName': firebaseUser.displayName, 'photoUrl': firebaseUser.photoUrl});

      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });

      // Navigate and reset route
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            widget.title,
            style: new TextStyle(color: new Color(0xff203152), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: new Color(0xfff5a623),
        ),
        body: new Stack(
          children: <Widget>[
            new Center(
              child: new FlatButton(
                  onPressed: handleSignIn,
                  child: new Text(
                    'SIGN IN WITH GOOGLE',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                  color: new Color(0xffdd4b39),
                  highlightColor: new Color(0xffff7f7f),
                  textColor: Colors.white,
                  padding: new EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
            ),
            new Positioned(
                child: isLoading
                    ? Container(
                        child: new Center(
                          child: new CircularProgressIndicator(),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                    : new Container())
          ],
        ));
  }
}
