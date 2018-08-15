import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return FlatButton(
        child: new Container(
          child: Row(
            children: <Widget>[
              Container(
                width: 50.0,
                height: 50.0,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: NetworkImage(
                      document['photoUrl'],
                    ),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                ),
              ),
              Container(
                child: Text(document['displayName']),
                margin: EdgeInsets.only(left: 20.0),
              ),
            ],
          ),
        ),
        onPressed: () {},
        color: Colors.grey.withOpacity(0.3),
        padding: new EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0));
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: new Container(
          child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("Lodading...");
              return ListView.builder(
                padding: new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
              );
            },
          ),
        ),
        onWillPop: onWillPopScope);
  }
}
