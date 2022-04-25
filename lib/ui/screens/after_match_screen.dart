import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app_flutter/data/db/entity/app_user.dart';
import 'package:tinder_app_flutter/data/db/entity/chat.dart';
import 'package:tinder_app_flutter/data/db/entity/match.dart';
import 'package:tinder_app_flutter/data/db/entity/swipe.dart';
import 'package:tinder_app_flutter/data/db/remote/firebase_database_source.dart';
import 'package:tinder_app_flutter/data/provider/user_provider.dart';
import 'package:tinder_app_flutter/ui/screens/convo_screen.dart';
import 'package:tinder_app_flutter/ui/screens/matched_screen.dart';
import 'package:tinder_app_flutter/ui/widgets/custom_modal_progress_hud.dart';
import 'package:tinder_app_flutter/ui/widgets/rounded_icon_button.dart';
import 'package:tinder_app_flutter/ui/widgets/swipe_card.dart';
import 'package:tinder_app_flutter/util/constants.dart';
import 'package:tinder_app_flutter/util/utils.dart';

class AfterMatchScreen extends StatefulWidget {


  static const String id = 'after_match_screen';

  AfterMatchScreen({
    required this.myUserId,
    required this.theirUserId,
    Key? key})
      : super(key: key);

  final String myUserId;
  final String theirUserId;

  @override
  _AfterMatchScreenState createState() => _AfterMatchScreenState();
}

class _AfterMatchScreenState extends State<AfterMatchScreen> {
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<String> _ignoreSwipeIds = <String>[];


  Future<AppUser?> loadPerson(String? id) async {

    DocumentSnapshot use = await _databaseSource.getUser(widget.theirUserId);
    if(use.data() != null) {
      return AppUser.fromSnapshot(use);
    } else{
      return null;
    }

  }

  void personSwiped(AppUser? myUser, AppUser? otherUser, bool isLiked) async {
    print("bool" + isLiked.toString());

    _databaseSource.addSwipedUser(myUser!.id, Swipe(otherUser!.id, isLiked));
    _ignoreSwipeIds.add(otherUser.id);


    if (isLiked == true) {
      print('is liked');
      if (await isMatch(myUser, otherUser) == true) {
        print('is Match');
        //List<dynamic> memberIds = [myUser.id, otherUser.id];
        _databaseSource.addMatch(myUser.id, Match(otherUser.id));
        _databaseSource.addMatch(otherUser.id, Match(myUser.id));
        String chatId = compareAndCombineIds(myUser.id, otherUser.id);
        _databaseSource.addChat(Chat(chatId, null));

        Navigator.pushNamed(context, MatchedScreen.id, arguments: {
          "my_user_id": myUser.id,
          "my_profile_photo_path": myUser.profilePhotoPath,
          "other_user_profile_photo_path": otherUser.profilePhotoPath,
          "other_user_id": otherUser.id
        });
      }
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
    }
    setState(() {});
  }

  Future<bool> isMatch(AppUser myUser, AppUser otherUser) async {
    print('made it here');
    QuerySnapshot swipeSnapshot =
    await _databaseSource.getSwipes(myUser.id);
    var doc;
    swipeSnapshot.docs.forEach((element) {
      if(element.id == otherUser.id){
       doc = element;
       print('yo yo yo yor');
      }
    });
    print("swipe snap" + swipeSnapshot.toString());
    if (doc != null) {
      print('is match');
      Swipe swipe = Swipe.fromSnapshot(doc);

      if (swipe.liked == true) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return FutureBuilder<AppUser>(
                  future: userProvider.user,
                  builder: (context, userSnapshot) {
                    return CustomModalProgressHUD(
                      inAsyncCall:
                      userProvider.isLoading,
                      child: (userSnapshot.hasData)
                          ? FutureBuilder<AppUser?>(
                          future: loadPerson(userSnapshot.data?.id),
                          builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return CustomModalProgressHUD(
                            inAsyncCall: true,
                            child: Container(),
                            );
                          }
                            if (snapshot.connectionState ==
                                ConnectionState.done &&
                                !snapshot.hasData) {
                              return Center(
                                child: Container(
                                    child: Text('Error', textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4)),
                              );
                            }
                            return Container(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      SwipeCard(person: snapshot.data!),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 45),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                RoundedIconButton(
                                                  onPressed: () {
                                                    personSwiped(
                                                        userSnapshot.data,
                                                        snapshot.data,
                                                        false);
                                                  },
                                                  iconData: Icons.clear,
                                                  buttonColor:
                                                  kColorPrimaryVariant,
                                                  iconSize: 30,
                                                ),
                                                RoundedIconButton(
                                                  onPressed: () {
                                                    personSwiped(
                                                        userSnapshot.data,
                                                        snapshot.data,
                                                        true);
                                                  },
                                                  iconData: Icons.favorite,
                                                  iconSize: 30, buttonColor: kAccentColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                          : Container(),
                    );
                  },
                );
              },
            )));
  }
}
