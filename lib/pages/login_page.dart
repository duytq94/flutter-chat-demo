import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/constants/app_constants.dart';
import 'package:flutter_chat_demo/constants/color_constants.dart';
import 'package:flutter_chat_demo/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/widgets.dart';
import 'pages.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences? prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  User? currentUser;

  void onPressSignIn() {
    this.setState(() {
      isLoading = true;
    });
    context.read<AuthProvider>().handleSignIn().then((firebaseUser) {
      Fluttertoast.showToast(msg: "Sign in success");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(currentUserId: firebaseUser.uid),
        ),
      );
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
      this.setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppConstants.loginTitle,
            style: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: TextButton(
                onPressed: onPressSignIn,
                child: Text(
                  'SIGN IN WITH GOOGLE',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xffdd4b39)),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                  ),
                ),
              ),
            ),
            // Loading
            Positioned(
              child: isLoading ? LoadingView() : SizedBox.shrink(),
            ),
          ],
        ));
  }
}
