import 'package:cloud_firestore/cloud_firestore.dart';

class MatchMessage{
  final String? id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  MatchMessage({
    this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory MatchMessage.fromDoc(DocumentSnapshot doc){
    return MatchMessage(
      id: doc.id,
      senderId: doc['senderId'],
      text: doc['text'],
      timestamp: doc['timestamp'],
    );
  }
}