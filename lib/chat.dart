import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_demo/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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

  File imageFile;
  bool isLoading;
  String imageUrl;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  @override
  void initState() {
    super.initState();

    groupChatId = '';
    isTyping = false;

    isLoading = false;
    imageUrl = '';

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
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    final ByteData bytes = await rootBundle.load(imageFile.path);
    final Directory tempDir = Directory.systemTemp;
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final File file = File('${tempDir.path}/$fileName');
    file.writeAsBytes(bytes.buffer.asInt8List(), mode: FileMode.write);

    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask task = ref.putFile(file);
    final Uri downloadUrl = (await task.future).downloadUrl;
    imageUrl = downloadUrl.toString();

    setState(() {
      isLoading = false;
    });

    onSendMessage(imageUrl, 1);
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image
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
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(bottom: 15.0, right: 10.0),
                )
              : Container(
                  child: Material(
                    child: Image.network(
                      document['content'],
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 15.0, right: 10.0),
                ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
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
            document['type'] == 0
                ? Container(
                    child: Text(
                      document['content'],
                      style: TextStyle(color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(left: 10.0),
                  )
                : Container(
                    child: Material(
                      child: Image.network(
                        document['content'],
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
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
    return Stack(
      children: <Widget>[
        Column(
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
                          .orderBy('timestamp', descending: true)
                          .limit(20)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                            itemCount: snapshot.data.documents.length,
                            reverse: true,
                            controller: listScrollController,
                          );
                        }
                      },
                    ),
            ),

            // Input content
            Container(
              child: Row(
                children: <Widget>[
                  // Button send image
                  Material(
                    child: new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 8.0),
                      child: new IconButton(
                        icon: new Icon(Icons.image),
                        onPressed: getImage,
                        color: primaryColor,
                      ),
                    ),
                    color: Colors.white,
                  ),

                  // Edit text
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
                    ),
                  ),

                  // Button send message
                  Material(
                    child: new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 8.0),
                      child: new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: () => onSendMessage(textEditingController.text, 0),
                        color: primaryColor,
                      ),
                    ),
                    color: Colors.white,
                  ),
                ],
              ),
              width: double.infinity,
              height: 50.0,
              decoration: new BoxDecoration(
                  border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
            )
          ],
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
    );
  }
}
