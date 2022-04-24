
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app_flutter/data/provider/user_provider.dart';

import '../../data/db/entity/app_user.dart';
import '../../data/db/entity/swipe.dart';
import '../../data/db/remote/firebase_database_source.dart';
import '../../util/constants.dart';

class ConvoScreen extends StatefulWidget {
  const ConvoScreen({Key? key}) : super(key: key);

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

  List<Container> buildUserList(AsyncSnapshot<List<AppUser>?> users){
    List<Container> cards = [];

    users.data?.forEach((element) {
      print("hello" + element.name);
      Container card = Container(
        height: 130,
          child:Card(
            color: Colors.black12,
            elevation: 10,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36.0),
          side: BorderSide(color: kAccentColor, width: 1),

        ),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            debugPrint('Card tapped.');
          },
          child: Column(
            children: <Widget>[
              Text(element.name, style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              ),
              ),

              Expanded(
                child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 67,


                    ),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    itemCount: 4,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext ctx, index) {

                      return Center(
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(element.interests[index]),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(
                                  color: Colors.amber,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(15))

                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ));
      cards.add(card);
    });
    return cards;
  }

  Future<List<AppUser>?> loadPeople(String? myUserId) async {
    Function sorting = const DeepCollectionEquality.unordered().equals;
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
                  return ListView(
                    // physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: buildUserList(users),
                  );

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
