// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:runex/screens/screens.dart';
import 'package:runex/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late WebViewController _webViewController;
  late bool _calledWorkoutPage = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebView(
          initialUrl: Constants.runexUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController controller) {
            _webViewController = controller;
          },
          onPageFinished: (url) {
            if (url.contains(Constants.workOutUrlKeyword) &&
                !_calledWorkoutPage) {
              _calledWorkoutPage = true;
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => WorkOut()))
                  .then((_) => setState(() {
                        _calledWorkoutPage = false;
                      }));
              _webViewController.reload();
            }
          },
        ),
      ),
    );
  }
}

void _signIn() async {
  try {
    final result = await LineSDK.instance.login();
    // user id -> result.userProfile?.userId
    // user name -> result.userProfile?.displayName
    // user avatar -> result.userProfile?.pictureUrl
  } on PlatformException catch (e) {
    
  }
}
