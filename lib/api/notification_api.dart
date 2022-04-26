import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationApi {
    static final _notification = FlutterLocalNotificationsPlugin();
    static final onNotifications = BehaviorSubject<String?>();

    static Future _notificationDetails() async {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
        ),
        iOS: IOSNotificationDetails(),
      );
    }

    static Future init({bool initScheduled = false}) async {
      final android = AndroidInitializationSettings('!mipmap/ic_launcher');
      final iOS = IOSInitializationSettings();
      final settings = InitializationSettings(android: android, iOS:  iOS);

      await _notification.initialize(
        settings,
        onSelectNotification: (payload) async {
          onNotifications.add(payload);
        },
      );
    }

    static Future showNotification({
      int id = 0,
      String? title = "User", // change this to display matched user that is online
      String? body = "Hey, user is online. Send a message to start a chat.",
    }) async =>
    _notification.show(id, title, body, await _notificationDetails(),);
  }
