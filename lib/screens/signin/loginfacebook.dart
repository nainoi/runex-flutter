import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:runex/screens/signin/profile.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FacebookPage extends StatefulWidget {
  FacebookPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _FacebookPageState createState() => _FacebookPageState();
}

class _FacebookPageState extends State<FacebookPage> {
  Map<String, dynamic>? _userData;
  void startLineLogin() async {
    try {
      final result = await FacebookAuth.instance
          .login(); // by default we request the email and the public profile
// or FacebookAuth.i.login()
      print(result.status);
      if (result.status == LoginStatus.success) {
        // you are logged
        final userData = await FacebookAuth.instance.getUserData();
        _userData = userData;
        print(userData);
        final accessToken = result.accessToken!;
      } else {
        print(result.status);
        print(result.message);
      }
    } on PlatformException catch (e) {
      print(e);
      switch (e.code.toString()) {
        case "CANCEL":
          showDialogBox("คุณยกเลิกการเข้าสู่ระบบ",
              "เมื่อสักครู่คุณกดยกเลิกการเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่อีกครั้ง");
          print("User Cancel the login");
          break;
        case "AUTHENTICATION_AGENT_ERROR":
          showDialogBox("คุณไม่อนุญาติการเข้าสู่ระบบด้วย LINE",
              "เมื่อสักครู่คุณกดยกเลิกการเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่อีกครั้ง");
          print("User decline the login");
          break;
        default:
          showDialogBox("เกิดข้อผิดพลาด",
              "เกิดข้อผิดพลาดไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง");
          print("Unknown but failed to login");
          break;
      }
    }
  }

  Future getAccessToken() async {
    try {
      final result = await LineSDK.instance.currentAccessToken;
      return result?.value;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Hello")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Image.asset(
                "assets/images/line_logo.png",
                width: 100,
                height: 100,
              ),
            ),
            Text(
              "ยินดีต้อนรับเข้าสู่ App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("กรุณาเข้าสู่ระบบก่อนเข้าใช้งาน",
                style: TextStyle(
                  fontSize: 15,
                )),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 0, bottom: 10, right: 10, left: 10),
                    child: RaisedButton(
                      color: Color.fromRGBO(0, 185, 0, 1),
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(1),
                      child: Column(
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/messagingapitutorial.appspot.com/o/line_logo.png?alt=media&token=80b41ee6-9d77-45da-9744-2033e15f52b2',
                                  width: 50,
                                  height: 50,
                                ),
                                Container(
                                  color: Colors.black12,
                                  width: 2,
                                  height: 40,
                                ),
                                Expanded(
                                  child: Center(
                                      child: Text("เข้าสู่ระบบด้วย LINE",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold))),
                                )
                              ])
                        ],
                      ),
                      onPressed: () {
                        startLineLogin();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void showDialogBox(String title, String body) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(body)],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("ปิด"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
