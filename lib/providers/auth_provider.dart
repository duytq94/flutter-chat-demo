import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_demo/models/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences prefs;

  AuthProvider({required this.firebaseAuth, required this.googleSignIn, required this.prefs});

  String? getUserFirebaseId() {
    return prefs.getString('id');
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs.getString('id') != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<User> handleSignIn() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result =
            await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          // Writing data to server because here is a new user
          FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoURL,
            'id': firebaseUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'chattingWith': null
          });

          // Write data to local storage
          User? currentUser = firebaseUser;
          await prefs.setString('id', currentUser.uid);
          await prefs.setString('nickname', currentUser.displayName ?? "");
          await prefs.setString('photoUrl', currentUser.photoURL ?? "");
        } else {
          // Already sign up, just get data from firestore
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          // Write data to local
          await prefs.setString('id', userChat.id);
          await prefs.setString('nickname', userChat.nickname);
          await prefs.setString('photoUrl', userChat.photoUrl);
          await prefs.setString('aboutMe', userChat.aboutMe);
        }
        return firebaseUser;
      } else {
        throw "Can not get firebase user";
      }
    } else {
      throw "Can not init google sign in";
    }
  }
}
