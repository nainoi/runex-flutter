// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';

class ProgressDialog {
  final BuildContext context;
  final String title;
  final String content;

  ProgressDialog({
    required this.context,
    required this.title,
    required this.content,
  });

  customProgressDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: WillPopScope(
              onWillPop: () => Future.value(false),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                    SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(content,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )));
  }

  void hideDialog() {
    Navigator.pop(context);
  }
}
