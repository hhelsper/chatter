import 'package:cloud_firestore/cloud_firestore.dart';

import 'match_message.dart';

class MatchChat{
  final String id;
  final String myUserId;
  final String theirUserId;




  MatchChat({
    required this.id,
    required this.myUserId,
    required this.theirUserId,
  });

  factory MatchChat.fromDoc(DocumentSnapshot doc){
    return MatchChat(
      id: doc.id,
      myUserId: doc['myUserId'],
      theirUserId: doc['theirUserId']
    );
  }


}

