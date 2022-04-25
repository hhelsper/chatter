import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tinder_app_flutter/data/db/entity/chat.dart';
import 'package:tinder_app_flutter/data/db/remote/firebase_auth_source.dart';
import 'package:tinder_app_flutter/data/db/remote/firebase_database_source.dart';
import 'package:tinder_app_flutter/data/db/remote/firebase_storage_source.dart';
import 'package:tinder_app_flutter/data/db/remote/response.dart';
import 'package:tinder_app_flutter/data/model/chat_with_user.dart';
import 'package:tinder_app_flutter/data/model/user_registration.dart';
import 'package:tinder_app_flutter/util/shared_preferences_utils.dart';
import 'package:tinder_app_flutter/data/db/entity/app_user.dart';
import 'package:tinder_app_flutter/util/utils.dart';
import 'package:tinder_app_flutter/data/db/entity/match.dart';

class UserProvider extends ChangeNotifier {
  FirebaseAuthSource _authSource = FirebaseAuthSource();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorageSource _storageSource = FirebaseStorageSource();
  FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  bool isLoading = false;
  AppUser? _user;
  late String currentUserId;

  Future<AppUser> get user => _getUser();

  Future<Response> loginUser(String email, String password,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.signIn(email, password);
    if (response is Success<UserCredential>) {
      String? id = response.value.user?.uid;
      SharedPreferencesUtil.setUserId(id!);
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
    return response;
  }

  Future<Response> registerUser(UserRegistration userRegistration,
      GlobalKey<ScaffoldState> errorScaffoldKey) async {
    Response<dynamic> response = await _authSource.register(
        userRegistration.email, userRegistration.password);
    if (response is Success<UserCredential>) {
      String? id = (response as Success<UserCredential>).value.user?.uid;
      print("user document id: $id");
      response = await _storageSource.uploadUserProfilePhoto(
          userRegistration.localProfilePhotoPath, id!);

      if (response is Success<String>) {
        String profilePhotoUrl = response.value;
        AppUser user = AppUser(
            id: id,
            name: userRegistration.name,
            age: userRegistration.age,
            profilePhotoPath: profilePhotoUrl,
            interests: userRegistration.interests,
            country: userRegistration.country,
            state: userRegistration.state,
            city: userRegistration.city,
            gender: userRegistration.gender,
            preference: userRegistration.preference,
            isOnline: true,

        );
        _databaseSource.addUser(user);
        SharedPreferencesUtil.setUserId(id);
        currentUserId = id;
        _user = user;
        return Response.success(user);
      }
    }
    if (response is Error) showSnackBar(errorScaffoldKey, response.message);
    return response;
  }

  Future<AppUser> _getUser() async {
    if (_user != null) {
      print("user was not null: ${_user.toString()}");
      return _user!;
    }
    String? id;

    try {
      id = await SharedPreferencesUtil.getUserId();
    } catch (ex) {
      print(ex.toString());
    }
    try {
      _user = AppUser.fromSnapshot(await _databaseSource.getUser(id!));
    } catch (ex) {
      print(ex.toString());
    }
    print("had to look this up from DB: ${_user.toString()}");
    return _user!;
  }

  void updateUserProfilePhoto(
      String localFilePath, GlobalKey<ScaffoldState> errorScaffoldKey) async {
    isLoading = true;
    notifyListeners();
    Response<dynamic> response =
        await _storageSource.uploadUserProfilePhoto(localFilePath, _user!.id);
    isLoading = false;
    if (response is Success<String>) {
      _user!.profilePhotoPath = response.value;
      _databaseSource.updateUser(_user!);
    } else if (response is Error) {
      showSnackBar(errorScaffoldKey, response.message);
    }
    notifyListeners();
  }

  void updateUserBio(String newBio) {
    _user!.bio = newBio;
    _databaseSource.updateUser(_user!);
    notifyListeners();
  }

  Future<void> logoutUser() async {
    _user = null;

    await SharedPreferencesUtil.removeUserId();
  }

  Future<List<ChatWithUser>> getChatsWithUser(String userId) async {

    var matches = await _databaseSource.getMatches(userId);

    List<ChatWithUser> chatWithUserList = [];

    for (var i = 0; i < matches.docs.length; i++) {

      print("length length " + matches.docs.length.toString());
      // print("in for loop ");
      Match match = Match.fromSnapshot(matches.docs[i]);
      AppUser matchedUser =
          AppUser.fromSnapshot(await _databaseSource.getUser(match.id));

      // print(match.id.toString());
      // print(userId.toString());
      String chatId = compareAndCombineIds(match.id, userId);
      // print("Chat ID:" + chatId.toString());
      try {
        Chat chat = Chat.fromSnapshot(await _databaseSource.getChat(chatId));
        ChatWithUser chatWithUser = ChatWithUser(chat, matchedUser);
        chatWithUserList.add(chatWithUser);
      } catch(ex){
        print(ex.toString());
      }

      // print("chat with users list:" + chatWithUserList.toString());
    }
    //TODO: write method to reverse
    List<ChatWithUser> orderedChatWithUserList = orderChats(chatWithUserList);
    // print("this is user list");
    return chatWithUserList;
  }

  List<ChatWithUser> orderChats(List<ChatWithUser> chatsList) {
    chatsList.sort((a, b) => a.chat.lastMessage!.epochTimeMs.compareTo(b.chat.lastMessage!.epochTimeMs));
    return chatsList.reversed.toList();
  }
}
