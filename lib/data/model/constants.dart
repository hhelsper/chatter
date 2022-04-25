
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

final matchChatsRef = _db.collection('matchChats');

final DateFormat timeFormat = DateFormat('E, h:mm a');