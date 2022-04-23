import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinder_app_flutter/data/db/remote/firebase_database_source.dart';
import 'message.dart';

class Chat {
  late String id;
  late Message? lastMessage;


  Chat(this.id,this.lastMessage);

  Chat.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot['id'];
    lastMessage = (snapshot['last_message'] != null
        ? Message.fromMap(snapshot['last_message'])
        : null)!;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'last_message': lastMessage != null ? lastMessage?.toMap() : null,
    };
  }
}
