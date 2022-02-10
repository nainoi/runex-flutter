// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:runex/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebView(
          initialUrl: Constants.runexUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
