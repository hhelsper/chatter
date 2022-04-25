
import 'dart:collection';

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app_flutter/data/db/entity/match_chat.dart';
import 'package:tinder_app_flutter/data/model/constants.dart';
import 'package:tinder_app_flutter/data/provider/user_provider.dart';
import 'package:tinder_app_flutter/ui/screens/top_navigation_screens/chats_screen.dart';

import '../../data/db/entity/app_user.dart';
import '../../data/db/entity/swipe.dart';
import '../../data/db/remote/firebase_database_source.dart';
import '../../util/constants.dart';
import '../widgets/rounded_button.dart';
import 'chat_screen_match.dart';


class ConvoScreen extends StatefulWidget {
  ConvoScreen({Key? key}) : super(key: key);

  @override
  _ConvoScreenState createState() => _ConvoScreenState();
}

class _ConvoScreenState extends State<ConvoScreen> {

  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<String> _ignoreSwipeIds;
  late String preference;
  late String gender;
  late List<String> interests;
  late AppUser me;



  @override
  void initState() {
    super.initState();
    // String currentId = Provider
    //     .of<UserProvider>(context, listen: false).currentUserId;
      getMe();
  }

  void getMe() async {
    AppUser user = await Provider.of<UserProvider>(context, listen: false).user;
    Provider.of<UserProvider>(context, listen: false).currentUserId = user.id;
    // String currentId = user.id;
    DocumentSnapshot snap = await _databaseSource.getUser(Provider.of<UserProvider>(context, listen: false).currentUserId);
    me = AppUser.fromSnapshot(snap);
  }

  List<SizedBox> buildUserList(AsyncSnapshot<List<AppUser>?> users) {
    List<SizedBox> cards = [];



    users.data?.forEach((element) {

      List<String> similarInterests = [];
      element.interests.forEach((interest) {
        if(me.interests.contains(interest)){
          similarInterests.add(interest);
        }
      });

      print(element.interests);
      print(element.profilePhotoPath);
      Size size = MediaQuery.of(context).size;
      SizedBox card = SizedBox(
          height: size.height,
          width: size.width,
      child: Scaffold(
          body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 42.0,
          horizontal: 18.0,
        ),
        child: Column(children: [
            Stack(
            children: [
            Container(
              height: 200,
            width: 200,
            child: ClipRRect(

              borderRadius: BorderRadius.circular(100.0),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Image.network(element.profilePhotoPath, fit: BoxFit.fill),),
            ),
          ),
            ]
            ),
          SizedBox(height: 20),
          Text(
              '${element.name}, ${element.age}',
              style: Theme.of(context).textTheme.headline4),
          SizedBox(height: 40),
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bio', style: Theme.of(context).textTheme.headline4),
                ],
              ),
              SizedBox(height: 5),
              Text(
                element.bio.length != 0 ? element.bio : "No bio.",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              ],
          ),
              Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text( similarInterests.length != 0 ?
                  'Similar Interests' : 'No Similar Interests',
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  ),
                    itemCount: similarInterests.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext ctx, index) {

                      return Center(
                        child: Container(
                        alignment: Alignment.center,
                        child: Text(similarInterests[index]),
                          decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                            color: Colors.amber,
                          width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15))

                        ),
                      );
                    }
                  ),
                ),
                  RoundedButton(
                      text: 'Start a chat',
                      onPressed: () async {
                        if(!element.isOnline){
                          final snackBar = SnackBar(
                            content: const Text('User is not Online',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: kFontFamily,

                            ),),
                            action: SnackBarAction(
                              label: 'gotcha',
                              onPressed: () {

                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          //TODO: push route with my user id and other user id included
                          matchChatsRef.add({
                            'myUserId': me.id,
                            'theirUserId': element.id,
                          });
                          QuerySnapshot doc = await matchChatsRef.where('myUserId', isEqualTo: me.id).where('theirUserId', isEqualTo: element.id).get();
                          DocumentSnapshot d = doc.docs.first;
                          MatchChat chat = MatchChat.fromDoc(d);
                          Navigator.pushNamed(context, ChatScreenMatch.id, arguments: {
                            'matchChatId': chat.id,
                            'myUserId': chat.myUserId,
                            'theirUserId': chat.theirUserId,
                          });
                          //Navigator.pushNamed(context, routeName)
                        }
                      }
                      ),
                ],
                ),
      ),




        ],
        ),
      )));
      cards.add(card);
    });
    return cards;
  }

  Future<List<AppUser>?> loadPeople(String? myUserId) async {

    print('load people');
    _ignoreSwipeIds = <String>[];
    if (_ignoreSwipeIds.isEmpty) {
      print("Made it!");
      preference = await _databaseSource.getPreference(myUserId!);
      gender = await _databaseSource.getGender(myUserId);
      print(gender);
      interests = await _databaseSource.getInterests(myUserId);
      print(interests.toString());
      var swipes = await _databaseSource.getSwipes(myUserId);
      for (var i = 0; i < swipes.size; i++) {
        Swipe swipe = Swipe.fromSnapshot(swipes.docs[i]);
        _ignoreSwipeIds.add(swipe.id);
      }
      _ignoreSwipeIds.add(myUserId);
    }
    print('hello');
    var res = await _databaseSource.getPeopleToMatchWith(
        _ignoreSwipeIds, gender, preference, interests);
    print(res.toString());
    if (res.docs.length > 0) {

      List<AppUser> users = [];
      Map<AppUser, int> userMap = {};
      DocumentSnapshot me = await _databaseSource.getUser(myUserId!);
      AppUser meUser = AppUser.fromSnapshot(me);
      print(meUser.name);

      res.docs.forEach((user) {
        AppUser use = AppUser.fromSnapshot(user);
        print(use.name);

        int counter = 0;

        use.interests.forEach((interest) {
          if(meUser.interests.contains(interest)){
            counter++;
          }
        }
        );
        userMap[use] = counter;
      });
      Map<AppUser, int> sortedUsers = SplayTreeMap.from(
          userMap, (key1, key2) => userMap[key1]!.compareTo(userMap[key2]!));
      sortedUsers.keys.forEach((element) {
        users.add(element);
      });
      return users.reversed.toList();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
      return FutureBuilder<AppUser>(
          future: userProvider.user,
          builder: (context, userSnapshot){
            return FutureBuilder<List<AppUser>?>(
                future: loadPeople(userSnapshot.data?.id),
                builder: (context, users){

                  if(!users.hasData){
                    return Center(
                      child: Column(
                        children: <Widget> [
                          SizedBox(height: 250,),
                          Text("No more Users",
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ],
                      ),
                      
                    );
                  } else {
                    return ListView(
                      // physics: const AlwaysScrollableScrollPhysics(),
                      physics: const PageScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: buildUserList(users),
                    );
                  }
                }
            );
          }
          );

          }
        ),
      ),
    );

    //future query database where collection('users).where(FieldPath.interests, arrayContainsAny: currentUser.interests
    //this will return all users with any matches then you need to figure out with a loop
    //who has the max matches and order then adding them to a list to then display
  }
}
