import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_demo/const.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'SETTINGS',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool isLoading = false;
  File avatarImageFile;

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? Icon(
                              Icons.account_circle,
                              size: 90.0,
                              color: greyColor,
                            )
                          : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(45.0)),
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: primaryColor,
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: greyColor,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      'Nickname',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Sweetie',
                          border: UnderlineInputBorder(),
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor)),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // About me
                  Container(
                    child: Text(
                      'About me',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Fun, like travel and play PES...',
                          border: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor)),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              )
            ],
          ),
          padding: EdgeInsets.only(bottom: 20.0),
        )
      ],
    );
  }
}
