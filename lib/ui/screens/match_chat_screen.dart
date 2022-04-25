import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tinder_app_flutter/data/db/entity/match_message.dart';
import '../../data/db/entity/app_user.dart';
import '../../data/db/remote/firebase_database_source.dart';
import '../../util/constants.dart';
import '../widgets/match_chat_top_bar.dart';
import '../widgets/match_message_bubble.dart';

import 'package:quiver/async.dart';
import 'dart:async';

class MatchChatScreen extends StatelessWidget {
  MatchChatScreen(
      {required this.matchChatId,
      required this.myUserId,
      required this.theirUserId,
      Key? key})
      : super(key: key);

  static const String id = 'match_chat_screen';

  final String matchChatId;
  final String myUserId;
  final String theirUserId;
  final int _start = 15;
  final int _current = 15;
  


  final ScrollController _scrollController = new ScrollController();
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  final messageTextController = TextEditingController();

  bool shouldShowTime(MatchMessage? currMessage, MatchMessage? messageBefore) {
    int halfHourInMilli = 1800000;

    if (messageBefore != null) {
      if ((messageBefore.timestamp.millisecondsSinceEpoch -
                  currMessage!.timestamp.millisecondsSinceEpoch)
              .abs() >
          halfHourInMilli) {
        return true;
      }
    }
    return false;
  }

  

  void sendMessage(String myUserId, String otherUserId, String matchChatId) {
    if (messageTextController.text.isEmpty) return;

    MatchMessage message = MatchMessage(
        senderId: myUserId,
        text: messageTextController.text,
        timestamp: Timestamp.now());
    _databaseSource.sendMatchMessage(matchChatId, message);

    messageTextController.clear();
  }

  Widget getBottomContainer(BuildContext context, String myUserId,
      String otherUserId, String matchChatId) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1.0,
            color: kSecondaryColor.withOpacity(0.5),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: messageTextController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: kSecondaryColor),
                decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle:
                        TextStyle(color: kSecondaryColor.withOpacity(0.5)),
                    contentPadding: EdgeInsets.all(0)),
              ),
            ),
            RaisedButton(
              padding: EdgeInsets.all(10),
              highlightElevation: 0,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              child: Text(
                "SEND",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onPressed: () {
                sendMessage(myUserId, otherUserId, matchChatId);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          appBar: AppBar(
              title: StreamBuilder<DocumentSnapshot>(
                  stream: _databaseSource.observeUser(theirUserId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return MatchChatTopBar(
                        user: AppUser.fromSnapshot(snapshot.data!), timer: 0,);
                  })),
          body: Column(children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _databaseSource.observeMatchMessages(matchChatId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      List<MatchMessage> messages = [];
                      snapshot.data?.docs.forEach((element) {
                        messages.add(MatchMessage.fromDoc(element));
                        //print("messages length  ${messages.length}");
                      });

                      if (_scrollController.hasClients)
                        _scrollController.jumpTo(0.0);

                      List<bool?> showTimeList = <bool?>[];
                      showTimeList.length = messages.length;

                      for (int i = messages.length - 1; i >= 0; i--) {
                        //print("value of i $i");
                        bool? shouldShow = i == (messages.length - 1)
                            ? true
                            : shouldShowTime(messages[i], messages[i + 1]);
                        //print(shouldShow.toString());
                        showTimeList[i] = shouldShow;
                        //print(showTimeList.toString());
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final item = messages[index];
                          return MatchMessageBubble(messages[index]);
                        },
                      );
                    })),
            getBottomContainer(context, myUserId, theirUserId, matchChatId)
          ])),
    );
  }
}
