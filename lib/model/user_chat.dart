import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;

  UserChat({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe});

  factory UserChat.fromJson(dynamic json) {
    return UserChat(
      id: "",
      photoUrl: json['photoUrl'],
      nickname: json['nickname'],
      aboutMe: json['aboutMe'],
    );
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    try {
      aboutMe = doc.get('aboutMe');
    } catch (e) {}
    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    try {
      nickname = doc.get('nickname');
    } catch (e) {}
    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
    );
  }

  Map<String, String?> toJson() {
    return {'photoUrl': this.photoUrl, 'nickname': this.nickname, 'aboutMe': this.aboutMe};
  }
}
