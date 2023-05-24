import 'dart:async';

import 'package:flutter/material.dart';
import 'package:runex/screens/login.dart';
import 'package:runex/screens/screens.dart';
import 'package:runex/utils/assets_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _init() async {
    final SharedPreferences prefs = await _prefs;
  }

  @override
  void initState() {
    super.initState();
    _init();
    final Future<String> loggedIn = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? '';
    });
    // final String loggedIn = _prefs.getString("token") ?? '';
    // if (loggedIn != '') {
    //   Home();
    // } else {
      Login();
    // }

    Timer(const Duration(seconds: 1), () {
      //_intit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(child: Image.asset(Assets.eventaLogoDesktop)),
    );
  }
}
