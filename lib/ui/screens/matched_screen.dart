import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app_flutter/data/db/entity/app_user.dart';
import 'package:tinder_app_flutter/data/db/entity/chat.dart';
import 'package:tinder_app_flutter/data/db/entity/message.dart';
import 'package:tinder_app_flutter/data/db/remote/firebase_database_source.dart';
import 'package:tinder_app_flutter/data/provider/user_provider.dart';
import 'package:tinder_app_flutter/ui/screens/chat_screen.dart';
import 'package:tinder_app_flutter/ui/widgets/portrait.dart';
import 'package:tinder_app_flutter/ui/widgets/rounded_button.dart';
import 'package:tinder_app_flutter/ui/widgets/rounded_outlined_button.dart';
import 'package:tinder_app_flutter/util/utils.dart';
import 'package:tinder_app_flutter/data/db/remote/firebase_database_source.dart';

class MatchedScreen extends StatelessWidget {
  final FirebaseFirestore instance = FirebaseFirestore.instance;
  static const String id = 'matched_screen';
  FirebaseDatabaseSource insta = FirebaseDatabaseSource();

  final String myProfilePhotoPath;
  final String myUserId;
  final String otherUserProfilePhotoPath;
  final String otherUserId;

  MatchedScreen(
      {required this.myProfilePhotoPath,
      required this.myUserId,
      required this.otherUserProfilePhotoPath,
      required this.otherUserId});

  void sendMessagePressed(BuildContext context) async {
    AppUser user = await Provider.of<UserProvider>(context, listen: false).user;

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushNamed(context, ChatScreen.id, arguments: {
      "chat_id": compareAndCombineIds(myUserId, otherUserId),
      "user_id": user.id,
      "other_user_id": otherUserId
    });
  }

  Future<void> keepSwipingPressed(BuildContext context) async {
    AppUser user = await Provider.of<UserProvider>(context, listen: false).user;
    //List<dynamic> memberIds = [myUserId, otherUserId];
    insta.addChat(Chat(compareAndCombineIds(myUserId, otherUserId),
        Message(DateTime.now().millisecondsSinceEpoch, false, user.id, "chat created"),
        ));

    // Navigator.pushNamed(context, ChatScreen.id, arguments: {
    //   "chat_id": compareAndCombineIds(myUserId, otherUserId),
    //   "user_id": user.id,
    //   "other_user_id": otherUserId
    // });

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);

    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 42.0,
            horizontal: 18.0,
          ),
          margin: EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('images/tinder_icon.png', width: 40),

              Text(
                'It\'s a Match!',
                style: Theme.of(context).textTheme.headline2,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Portrait(imageUrl: myProfilePhotoPath),
                    Portrait(imageUrl: otherUserProfilePhotoPath)
                  ],
                ),
              ),
              Column(
                children: [
                  RoundedButton(
                      text: 'SEND MESSAGE',
                      onPressed: () {
                        sendMessagePressed(context);
                      }),
                  SizedBox(height: 20),
                  RoundedOutlinedButton(
                      text: 'KEEP SWIPING',
                      onPressed: () {
                        keepSwipingPressed(context);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
