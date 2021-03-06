import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinder_app_flutter/data/db/entity/app_user.dart';
import 'package:tinder_app_flutter/data/db/entity/chat.dart';
import 'package:tinder_app_flutter/data/db/entity/match.dart';
import 'package:tinder_app_flutter/data/db/entity/match_chat.dart';
import 'package:tinder_app_flutter/data/db/entity/message.dart';
import 'package:tinder_app_flutter/data/db/entity/swipe.dart';
import 'package:tinder_app_flutter/data/model/constants.dart';

import '../entity/match_message.dart';

class FirebaseDatabaseSource {
  final FirebaseFirestore instance = FirebaseFirestore.instance;

  void addUser(AppUser user) {
    instance.collection('users').doc(user.id).set(user.toMap());
  }

  void addMatch(String userId, Match match) {
    instance
        .collection('users')
        .doc(userId)
        .collection('matches')
        .doc(match.id)
        .set(match.toMap());
  }

  void addChat(Chat chat) {
    instance.collection('chats').doc(chat.id).set(chat.toMap());
  }

  void addMessage(String chatId, Message? message) {
    instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message!.toMap());
  }

  void addSwipedUser(String userId, Swipe swipe) async {
    instance
        .collection('users')
        .doc(userId)
        .collection('swipes')
        .doc(swipe.id)
        .set(swipe.toMap());
  }

  void updateUser(AppUser user) async {
    instance.collection('users').doc(user.id).update(user.toMap());
  }

  void updateChat(Chat chat) {
    instance.collection('chats').doc(chat.id).update(chat.toMap());
  }

  void updateMessage(String chatId, String messageId, Message message) {
    instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update(message.toMap());
  }

  Future<DocumentSnapshot> getUser(String userId) {
    print("get user");
    return instance.collection('users').doc(userId).get();
  }

  Future<DocumentSnapshot> getSwipe(String userId, String swipeId) async {
    print("get swipe");
    DocumentSnapshot doc = await instance
        .collection('users')
        .doc(userId)
        .collection('swipes')
        .doc(swipeId)
        .get();
    return doc;
  }

  Future<QuerySnapshot> getMatches(String userId) {
    return instance.collection('users').doc(userId).collection('matches').get();
  }

  Future<DocumentSnapshot> getChat(String chatId) {
    return instance.collection('chats').doc(chatId).get();
  }

  Future<String> getPreference(String userId) async {
    String gender = '';
    var docSnapshot = await instance.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      // You can then retrieve the value from the Map like this:
      gender = data['preference'].toString();
    }
    return gender;
  }

  Future<String> getGender(String userId) async {
    String gender = '';
    var docSnapshot = await instance.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      // You can then retrieve the value from the Map like this:
      gender = data['gender'].toString();
    }
    return gender;
  }

  Future<List<String>> getInterests(String userId) async {
    print('get interests');
    print(userId);
    List<String> interests = [];
    var docSnapshot = await instance.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      print('shit');
      AppUser user = AppUser.fromSnapshot(docSnapshot);
      Map<String, dynamic> data = docSnapshot.data()!;

      // You can then retrieve the value from the Map like this:
      interests = user.interests;
      print(interests.toString());
    }
    return interests;
  }

  Future<QuerySnapshot> getPersonsToMatchWith(
      List<String> ignoreIds, String gender, String preference) {
    print(gender + preference);
      if(gender == 'male' && preference == 'male'){
        print("male looking for males");
        return instance
            .collection('users')
            .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'male')
            .where('preference', isEqualTo: 'male')
            .get();
      } else if(gender == 'male' && preference == 'female'){
        print('male looking for females');
        return instance
            .collection('users')
            .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'female')
            .where('preference', isEqualTo: 'male')
            .get();
      } else if(gender == 'female' && preference == 'female'){
        print("female looking for females");
        return instance
            .collection('users')
            .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'female')
            .where('preference', isEqualTo: 'female')
            .get();
      } else {
        print('female looking for males');
        return instance
            .collection('users')
            .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'male')
            .where('preference', isEqualTo: 'female')
            .get();
      }

  }

  Future<QuerySnapshot> getPeopleToMatchWith(
      List<String> ignoreIds, String gender, String preference, List<String> interests) {
    print(gender + preference);
    print('made it');
    if(gender == 'male' && preference == 'male'){
      print("male looking for males");

      return instance
          .collection('users')
          .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'male')
          .where('preference', isEqualTo: 'male')
          .get();
    } else if(gender == 'male' && preference == 'female'){
      print('male looking for females');

      return instance
          .collection('users')
          .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'female')
          .where('preference', isEqualTo: 'male')
          .get();
    } else if(gender == 'female' && preference == 'female'){
      print("female looking for females");
      return instance
          .collection('users')
          .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'female')
          .where('preference', isEqualTo: 'female')
          .get();
    } else {
      print('female looking for males');
      return instance
          .collection('users')
          .where('id', whereNotIn: ignoreIds).where('gender', isEqualTo: 'male')
          .where('preference', isEqualTo: 'female')
          .get();
    }

  }

  Future<QuerySnapshot> getSwipes(String userId) {
    return instance.collection('users').doc(userId).collection('swipes').get();
  }

  Stream<DocumentSnapshot> observeUser(String userId) {
    return instance.collection('users').doc(userId).snapshots();
  }

  Stream<QuerySnapshot> observeMessages(String chatId) {
    return instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('epoch_time_ms', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> observeMatchMessages(String chatId) {
    return instance
        .collection('matchChats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> observeChat(String chatId) {
    return instance.collection('chats').doc(chatId).snapshots();
  }

  void addMatchChat(String myUserId, String theirUserId) {
    matchChatsRef.add({
      'myUserId': myUserId,
      'theirUserId': theirUserId,
    }
    );
  }

  void sendMatchMessage(String chatId, MatchMessage message){
    matchChatsRef.doc(chatId).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'timestamp': message.timestamp,
    });
    matchChatsRef.doc(chatId).update({
      'recentMessage': message.text,
      'recentSender': message.senderId,
      'recentTimestamp': Timestamp.now(),
    });
  }

}


