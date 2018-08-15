import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'MAIN',
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State createState() => new MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool isLoading = false;

  Future<bool> onWillPopScope() {
    openDialog();
    return new Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            contentPadding: new EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 10.0),
            children: <Widget>[
              new Container(
                color: new Color(0xfff5a623),
                margin: new EdgeInsets.all(0.0),
                padding: new EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: new EdgeInsets.only(bottom: 10.0),
                    ),
                    new Text(
                      'Exit app',
                      style: new TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    new Text(
                      'Are you sure to exit app?',
                      style: new TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: new Row(
                  children: <Widget>[
                    new Container(
                      child: new Icon(
                        Icons.cancel,
                        color: new Color(0xff203152),
                      ),
                      margin: new EdgeInsets.only(right: 20.0),
                    ),
                    new Text(
                      'CANCEL',
                      style: new TextStyle(color: new Color(0xff203152), fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: new Row(
                  children: <Widget>[
                    new Container(
                      child: new Icon(
                        Icons.check_circle,
                        color: new Color(0xff203152),
                      ),
                      margin: new EdgeInsets.only(right: 20.0),
                    ),
                    new Text(
                      'YES',
                      style: new TextStyle(color: new Color(0xff203152), fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(child: new Center(), onWillPop: onWillPopScope);
  }
}
