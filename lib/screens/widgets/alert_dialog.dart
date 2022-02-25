// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';

class ShowAlertDialog {
  final BuildContext context;
  final String title;
  final String content;
  final VoidCallback onPress;
  final String actionText;

  ShowAlertDialog(
      {required this.context,
      required this.title,
      required this.content,
      required this.onPress,
      required this.actionText});

  late bool tryConnect = false;

  setTryConnect(bool _tryConnect) {
    tryConnect = _tryConnect;
  }

  internetAlert() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            content: tryConnect
                ? Center(
                    child: Column(children: [
                      CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                      Text("กำลังเชื่อมต่อ...")
                    ]),
                  )
                : Text(content),
            actions: [TextButton(onPressed: onPress, child: Text(actionText))],
          );
        });
  }

  tryConnectInternet() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              width: 100,
              height: 120,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                  SizedBox(height: 20),
                  new Text(
                    "$title\n$content ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          );
        });
  }

  successDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: ()=> Future.value(false),
          child: AlertDialog(
                title: Text(title),
                actions: [
                  TextButton(onPressed: onPress, child: Text(actionText))
                ],
              ),
        ));
  }

  progressAlert() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Dialog(
              child: Container(
                width: 100,
                height: 120,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                    SizedBox(height: 20),
                    new Text(
                      "$content $title",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void hideDialog() {
    Navigator.pop(context);
  }
}
