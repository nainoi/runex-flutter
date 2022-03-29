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
  _intit() async {
    final prefs = await SharedPreferences.getInstance();
    final String loggedIn = prefs.getString("token") ?? '';
    if (loggedIn != '') {
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => Home()), (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => Login()), (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      _intit();
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
