import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_demo/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;

  Chat({Key key, @required this.peerId, @required this.peerAvatar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;

  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar}) : super(key: key);

  @override
  State createState() => new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String id;

  bool isTyping;
  String groupChatId;
  SharedPreferences prefs;

  final TextEditingController textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    groupChatId = '';
    isTyping = false;

    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    setState(() {});

//    Firestore.instance.collection('messages').document(groupChatId).collection(groupChatId).document('${DateTime
//        .now()
//        .millisecondsSinceEpoch}').setData({
//      'idFrom': id,
//      'idTo': peerId,
//      'timestamp': '${DateTime
//          .now()
//          .millisecondsSinceEpoch}',
//      'content': 'How are you',
//    });
  }

  void onSendMessage(String content) {
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
          },
        );
      });
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      // Right
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              document['content'],
              style: TextStyle(color: primaryColor),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: 15.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left
      return Container(
        child: Row(
          children: <Widget>[
            Material(
              child: Image.network(
                peerAvatar,
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(18.0),
              ),
            ),
            Container(
              child: Text(
                document['content'],
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(left: 10.0),
            ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 15.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // List of messages
      children: <Widget>[
        Flexible(
          child: groupChatId == ''
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder(
                  stream: Firestore.instance
                      .collection('messages')
                      .document(groupChatId)
                      .collection(groupChatId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                      );
                    }
                  },
                ),
        ),

        // Input content
        Container(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: TextField(
                    style: TextStyle(color: primaryColor, fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: greyColor),
                    ),
                  ),
                  margin: EdgeInsets.only(left: 15.0, right: 10.0),
                ),
              ),
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 8.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: () => onSendMessage(textEditingController.text),
                    color: primaryColor,
                  ),
                ),
                color: greyColor2,
              ),
            ],
          ),
          color: greyColor2,
          width: double.infinity,
          height: 50.0,
        )
      ],
    );
  }
}
