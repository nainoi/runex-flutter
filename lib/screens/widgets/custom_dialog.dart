// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CustomDialog {
  static customDialog2Actions(
      BuildContext context,
      String title,
      String content,
      String okTitle,
      Color okTitleColor,
      Color okButtonColor,
      Color okBorderSoidColor,
      VoidCallback okOnTap,
      String cancelTitle,
      Color cancelTitleColor,
      Color cancelButtonColor,
      Color cancelBorderSoidColor,
      VoidCallback cancelOnTap) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DialogButton(
                          title: cancelTitle,
                          titleColor: cancelTitleColor,
                          buttonColor: cancelButtonColor,
                          borderSideColor: cancelBorderSoidColor,
                          onTap: cancelOnTap,
                        ),
                        SizedBox(width: 16),
                        DialogButton(
                          title: okTitle,
                          titleColor: okTitleColor,
                          buttonColor: okButtonColor,
                          borderSideColor: okBorderSoidColor,
                          onTap: okOnTap,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }

  static customDialog1Actions(
      BuildContext context,
      String title,
      String content,
      String okTitle,
      Color okTitleColor,
      Color okButtonColor,
      Color okBorderSoidColor,
      VoidCallback okOnTap) {
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
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DialogButton(
                            title: okTitle,
                            titleColor: okTitleColor,
                            buttonColor: okButtonColor,
                            borderSideColor: okBorderSoidColor,
                            onTap: okOnTap,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )));
  }

  static customProgressDialog(
      BuildContext context,
      String title,
      String content) {
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
}

class DialogButton extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color buttonColor;
  final Color borderSideColor;
  final VoidCallback onTap;
  const DialogButton(
      {Key? key,
      required this.title,
      required this.titleColor,
      required this.buttonColor,
      required this.borderSideColor,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16.0, color: titleColor, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
          fixedSize: Size(100, 25),
          primary: buttonColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              side: BorderSide(color: borderSideColor))),
    );
  }
}
