import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tinder_app_flutter/data/db/entity/match_message.dart';
import 'package:tinder_app_flutter/ui/screens/after_match_screen.dart';
import '../../data/db/entity/app_user.dart';
import '../../data/db/remote/firebase_database_source.dart';
import '../../util/constants.dart';
import '../widgets/match_chat_top_bar.dart';
import '../widgets/match_message_bubble.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';
import 'package:quiver/async.dart';

class ChatScreenMatch extends StatefulWidget {
   ChatScreenMatch({
    required this.matchChatId,
    required this.myUserId,
    required this.theirUserId,
    Key? key})
      : super(key: key);

  static const String id = 'chat_screen_match';

  final String matchChatId;
  final String myUserId;
  final String theirUserId;

  final ScrollController _scrollController = new ScrollController();
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  final messageTextController = TextEditingController();



  @override
  _ChatScreenMatchState createState() => _ChatScreenMatchState();
}

class _ChatScreenMatchState extends State<ChatScreenMatch> {


  @override
  Widget build(BuildContext context) {



    final String matchChatId = widget.matchChatId;
    final String myUserId = widget.myUserId;
    final String theirUserId = widget.theirUserId;



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
                  stream: widget._databaseSource.observeUser(theirUserId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return Align(
                      alignment: Alignment(-0.2, 0.0),
                      child: SlideCountdownClock(
                        duration: Duration(seconds: 10),
                        slideDirection: SlideDirection.Down,
                        separator: ":",
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),

                        onDone: () {
                          Navigator.pushNamed(context, AfterMatchScreen.id, arguments: {
                            'myUserId': widget.myUserId,
                            'theirUserId': widget.theirUserId,
                          });

                        },
                      ),
                    );
                  })),
          body: Column(children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: widget._databaseSource.observeMatchMessages(matchChatId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      List<MatchMessage> messages = [];
                      snapshot.data?.docs.forEach((element) {
                        messages.add(MatchMessage.fromDoc(element));
                        //print("messages length  ${messages.length}");
                      });

                      if (widget._scrollController.hasClients)
                        widget._scrollController.jumpTo(0.0);

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
                        controller: widget._scrollController,
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
                controller: widget.messageTextController,
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

  void sendMessage(String myUserId, String otherUserId, String matchChatId) {
    if (widget.messageTextController.text.isEmpty) return;

    MatchMessage message = MatchMessage(
        senderId: myUserId,
        text: widget.messageTextController.text,
        timestamp: Timestamp.now());
    widget._databaseSource.sendMatchMessage(matchChatId, message);

    widget.messageTextController.clear();
  }

}
