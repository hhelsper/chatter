import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:tinder_app_flutter/data/db/entity/match_message.dart';
import 'package:tinder_app_flutter/data/provider/user_provider.dart';

import '../../data/model/constants.dart';
import '../../util/constants.dart';


class MatchMessageBubble extends StatelessWidget {


  final MatchMessage message;

  const MatchMessageBubble(this.message);

  _buildText(bool isMe){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: isMe ? Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 15.0))
          : Text(message.text, style: const TextStyle(color: Colors.black, fontSize: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.senderId == Provider.of<UserProvider>(context, listen: false).currentUserId;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
                padding: isMe
                    ? const EdgeInsets.only(right: 12.0)
                    : const EdgeInsets.only(left: 12.0),
                child: Text(isMe
                    ? timeFormat.format(message.timestamp.toDate())
                    : timeFormat.format(message.timestamp.toDate()),
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontSize: 11, fontWeight: FontWeight.normal),


                ),

              ),
          SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Material(
              borderRadius: BorderRadius.circular(8.0),
              elevation: 5.0,
              color: isMe ? kAccentColor : kSecondaryColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: isMe ? kSecondaryColor : Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ],
      ),










      // Row(
      //   mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: <Widget>[
      //     Column(
      //       crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      //       children: <Widget> [
      //         Padding(
      //           padding: isMe
      //               ? const EdgeInsets.only(right: 12.0)
      //               : const EdgeInsets.only(left: 12.0),
      //           child: Text(isMe
      //               ? timeFormat.format(message.timestamp.toDate())
      //               : timeFormat.format(message.timestamp.toDate()),
      //             style: const TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
      //
      //
      //           ),
      //
      //         ),
      //         const SizedBox(height: 6.0,),
      //         Container(
      //           constraints: BoxConstraints(
      //             maxWidth: MediaQuery.of(context).size.width * 0.65,
      //           ),
      //           decoration: BoxDecoration(
      //             color: isMe ? Colors.black : Colors.blueGrey.shade50,
      //             borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      //
      //
      //           ),
      //           child: _buildText(isMe),
      //         )
      //       ],
      //     )
      //   ],
      // ),
    );
  }
}
