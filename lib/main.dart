import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Chat Demo',
        theme: new ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: new MyHomePage(title: 'CHAT DEMO'),
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser firebaseUser = await _firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return firebaseUser;
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
      body: new Center(
        child: new FlatButton(
            onPressed: () => _handleSignIn().then((value) => print(value)),
            child: new Text(
              'SIGN IN WITH GOOGLE',
              style: new TextStyle(fontSize: 16.0),
            ),
            color: new Color(0xffdd4b39),
            highlightColor: new Color(0xffff7f7f),
            textColor: Colors.white,
            padding: new EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
      ),
    );
  }
}
