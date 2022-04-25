import 'package:flutter/material.dart';
import 'package:tinder_app_flutter/data/db/entity/app_user.dart';
import 'package:tinder_app_flutter/util/constants.dart';

class MatchChatTopBar extends StatelessWidget {
  final AppUser user;
  final int timer;

  MatchChatTopBar({required this.user, required this.timer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget> [
        Align(
          alignment: Alignment(-0.2, 0.0),
          child: Text(
                      user.name,
                      style: Theme.of(context).textTheme.headline3,
                    ),
        ),

        Text('$timer', style: Theme.of(context).textTheme.headline4,)
      ],
    );
    //   Row(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   children: [
    //     Stack(
    //       children: [
    //         Container(
    //           child: CircleAvatar(
    //               radius: 22,
    //               backgroundImage: NetworkImage(user.profilePhotoPath)),
    //           decoration: BoxDecoration(
    //             shape: BoxShape.circle,
    //             border: Border.all(color: kAccentColor, width: 1.0),
    //           ),
    //         )
    //       ],
    //     ),
    //     SizedBox(width: 10),
    //     Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           user.name,
    //           style: Theme.of(context).textTheme.bodyText1,
    //         ),
    //       ],
    //     ),
    //   ],
    // );
  }
}