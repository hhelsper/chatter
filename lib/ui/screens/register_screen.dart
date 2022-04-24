import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tinder_app_flutter/data/db/remote/response.dart';
import 'package:tinder_app_flutter/data/model/user_registration.dart';
import 'package:tinder_app_flutter/data/provider/user_provider.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/add_photo_screen.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/age_screen.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/email_and_password_screen.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/gender.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/location.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/interests_screen.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/name_screen.dart';
import 'package:tinder_app_flutter/ui/screens/register_sub_screens/preference.dart';
import 'package:tinder_app_flutter/ui/screens/top_navigation_screen.dart';
import 'package:tinder_app_flutter/ui/widgets/custom_modal_progress_hud.dart';
import 'package:tinder_app_flutter/ui/widgets/rounded_button.dart';
import 'package:tinder_app_flutter/util/constants.dart';
import 'package:tinder_app_flutter/util/utils.dart';
import 'package:tinder_app_flutter/ui/screens/start_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  static const String id = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final UserRegistration _userRegistration = UserRegistration();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _endScreenIndex = 7;//TODO: will change to 4 to account for interests screen
  int _currentScreenIndex = 0;
  bool _isLoading = false;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  void registerUser() async {
    setState(() {
      _isLoading = true;
    });

    await _userProvider
        .registerUser(_userRegistration, _scaffoldKey)
        .then((response) {
      if (response is Success) {

        // _userProvider.currentUserId = response.value.
        Navigator.pop(context);
        Navigator.pushNamed(context, TopNavigationScreen.id);
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  void goBackPressed() {
    if (_currentScreenIndex == 0) {
      Navigator.pop(context);
      Navigator.pushNamed(context, StartScreen.id);
    } else {
      setState(() {
        _currentScreenIndex--;
      });
    }
  }

  Widget getSubScreen() {
    switch (_currentScreenIndex) {
      case 0:
        return NameScreen(
            onChanged: (value) => {_userRegistration.name = value});
      case 1:
        return AgeScreen(onChanged: (value) => {_userRegistration.age = value as int});
      case 2:
        return AddPhotoScreen(
            onPhotoChanged: (value) =>
                {_userRegistration.localProfilePhotoPath = value});
      case 3:
        print("get subscreen case 3");
        return InterestsScreen(
          onInterestsChanged: (value) {
            print("list : ${value.toString()}");
            _userRegistration.interests = value;
          }

        );

      case 4:
        return EmailAndPasswordScreen(
            emailOnChanged: (value) => {_userRegistration.email = value},
            passwordOnChanged: (value) => {_userRegistration.password = value});
      case 5:
        return Gender(
            onChanged: (value) => {_userRegistration.gender = value}
      );

      case 6:
        return Preference(onChanged: (value) => {_userRegistration.preference = value});

      case 7:
        return Location(
            onChanged: (value) {
              _userRegistration.city = value['city'];
              _userRegistration.state = value['state'];
              _userRegistration.country = value['country'];
            }
        );
      default:
        return Container();
    }
  }

  bool canContinueToNextSubScreen() {
    switch (_currentScreenIndex) {
      case 0:
        return (_userRegistration.name.length >= 2 && _userRegistration.name.length < 12);
      case 1:
        return (_userRegistration.age >= 18 && _userRegistration.age <= 120);
      case 2:
        return _userRegistration.localProfilePhotoPath.isNotEmpty;

      case 3:
        return (_userRegistration.interests.length > 0);
      case 4:
        return (_userRegistration.password.length > 5);
      case 5:
        return (_userRegistration.gender.length > 1);
      case 6:
        return(_userRegistration.preference.length > 1);
      case 7:
        return (_userRegistration.city.isNotEmpty);
      default:
        return false;
    }
  }

  String getInvalidRegistrationMessage() {
    print("getInvalidMessage: $_currentScreenIndex");
    switch (_currentScreenIndex) {
      case 0:
        return "Name is too short or too long";
      case 1:
        return "You're too young";
      case 2:
        return "Invalid photo";
      case 3:
        return "Must choose interests";
      case 4:
        return "password must be at least 6 characters";
      case 5:
        return "must choose a gender";
      case 6:
        return 'must choose a preference';
      case 7:
        return 'must choose a location';
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Register')),
        body: CustomModalProgressHUD(
          inAsyncCall: _isLoading,
          offset: Offset(0, 0),
          child: Container(
            margin: EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                Container(
                  child: LinearPercentIndicator(
                      lineHeight: 5,
                      percent: (_currentScreenIndex / _endScreenIndex),
                      progressColor: kAccentColor,
                      padding: EdgeInsets.zero),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      padding: kDefaultPadding.copyWith(
                          left: kDefaultPadding.left / 2.0,
                          right: 0.0,
                          bottom: 4.0,
                          top: 4.0),
                      child: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          _currentScreenIndex == 0
                              ? Icons.clear
                              : Icons.arrow_back,
                          color: kSecondaryColor,
                          size: 42.0,
                        ),
                        onPressed: () {
                          goBackPressed();
                        },
                      )),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                      width: double.infinity,
                      child: getSubScreen(),
                      padding: kDefaultPadding.copyWith(top: 0, bottom: 0)),
                ),
                Container(
                  padding: kDefaultPadding,
                  child: _currentScreenIndex == (_endScreenIndex)
                      ? RoundedButton(
                          text: 'REGISTER',
                          onPressed: registerUser)
                      : RoundedButton(
                          text: 'CONTINUE',
                          onPressed: () => {
                            if (canContinueToNextSubScreen())
                              setState(() {
                                _currentScreenIndex++;
                              })
                            else
                              showSnackBar(
                                  _scaffoldKey, getInvalidRegistrationMessage())
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
