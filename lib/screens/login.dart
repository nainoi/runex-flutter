// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import 'package:runex/constants/constant.dart';
import 'package:runex/screens/home.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleSignInAccount? _currentUser;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> checkUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loggedIn = prefs.getString("token");
    print('loggedin' + loggedIn.toString());
    if (loggedIn != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Home()));
    }
  }

  @override
  void initState() {
    super.initState();
    //checkUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: ListView(
          shrinkWrap: true,
          reverse: false,
          children: <Widget>[
            const SizedBox(
              height: 80.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36.0,
                          ),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/runexlogo.png",
                      height: 100.0,
                      width: 200.0,
                      fit: BoxFit.scaleDown,
                    )
                  ],
                ),
                Center(
                    child: Center(
                  child: Stack(
                    children: <Widget>[
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 60.0, right: 50.0),
                          child: Form(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                //Facebook Sign in

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, top: 45.0, bottom: 10.0),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      startLogin("FACEBOOK");
                                      //facebook Login Logic
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          "assets/images/facebook.png",
                                          height: 24.0,
                                          width: 24.0,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        Image.asset(
                                          "assets/images/substract.png",
                                          height: 24.0,
                                          width: 24.0,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        const Text(
                                          "Login With Facebook",
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                    color: const Color(0xFF3A559F),
                                    textColor: Colors.white,
                                    elevation: 5.0,
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        right: 30.0,
                                        top: 10.0,
                                        bottom: 10.0),
                                  ),
                                ),

                                //Line Sign in

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, top: 15.0, bottom: 10.0),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      startLogin("LINE");
                                      // Line Login Logic
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          "assets/images/line_logo.png",
                                          height: 24.0,
                                          width: 24.0,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        Image.asset(
                                          "assets/images/substract.png",
                                          height: 24.0,
                                          width: 24.0,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        const Text(
                                          "Login With Line",
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                    color: const Color(0xFF00B900),
                                    textColor: Colors.white,
                                    elevation: 5.0,
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        right: 30.0,
                                        top: 10.0,
                                        bottom: 10.0),
                                  ),
                                ),

                                //Google Sign In

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, top: 15.0, bottom: 10.0),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      startLogin("GOOGLE");
                                      // Google Login Logic
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          "assets/images/google.png",
                                          height: 24.0,
                                          width: 24.0,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        Image.asset(
                                          "assets/images/substract.png",
                                          height: 24.0,
                                          width: 24.0,
                                          fit: BoxFit.scaleDown,
                                        ),
                                        const Text(
                                          "Login With Google",
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                    color: Colors.white,
                                    textColor: const Color(0xFF777777),
                                    elevation: 5.0,
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        right: 30.0,
                                        top: 10.0,
                                        bottom: 10.0),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ))
              ],
            )
          ],
        ));
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

  void startLogin(String method) async {
    final SharedPreferences prefs = await _prefs;
    if (method == "LINE") {
      try {
        final result = await LineSDK.instance
            .login(scopes: ["profile", "openid", "email"]);
        var accesstoken = await getAccessToken();
        var displayname = result.userProfile?.displayName;
        var statusmessage = result.userProfile?.statusMessage;
        var imgUrl = result.userProfile?.pictureUrl;
        var userId = result.userProfile?.userId;
        var email = result.accessToken.idToken!['email'];
        final res =
            await getUserToken(userId!, displayname!, imgUrl!, email, "LINE");
        if (res['success']) {
          prefs.setString("token", res['data']['code']);
          prefs.setString("providerID", userId);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Home()));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
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
    } else if (method == "FACEBOOK") {
      try {
        final result = await FacebookAuth.instance
            .login(); // by default we request the email and the public profile
// or FacebookAuth.i.login()
        print(result.status);
        if (result.status == LoginStatus.success) {
          // you are logged
          final userData = await FacebookAuth.instance.getUserData();
          print(userData);
          prefs.setString('provider', "FACEBOOK");
          prefs.setString('userData', userData.toString());
          final accessToken = result.accessToken!;

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Home()));
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
            showDialogBox("คุณไม่อนุญาติการเข้าสู่ระบบด้วย FACEBOOK",
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
    } else if (method == "GOOGLE") {
      try {
        await _googleSignIn.signIn();
        print(_googleSignIn.clientId);
        prefs.setString('userData', _googleSignIn.currentUser.toString());
        prefs.setString('provider', "GOOGLE");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } on PlatformException catch (e) {
        print(e);
        switch (e.code.toString()) {
          case "CANCEL":
            showDialogBox("คุณยกเลิกการเข้าสู่ระบบ",
                "เมื่อสักครู่คุณกดยกเลิกการเข้าสู่ระบบ กรุณาเข้าสู่ระบบใหม่อีกครั้ง");
            print("User Cancel the login");
            break;
          case "AUTHENTICATION_AGENT_ERROR":
            showDialogBox("คุณไม่อนุญาติการเข้าสู่ระบบด้วย GOOGLE",
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
  }

  Future getAccessToken() async {
    try {
      final result = await LineSDK.instance.currentAccessToken;
      return result?.value;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {});
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {});
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
  }
}

Future<dynamic> getUserToken(String userId, String name, String imgUrl,
    String email, String provider) async {
  const String url = "$apidomain/account/create";
  final response = await http.post(Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: convert.json.encode({
        "providerID": userId,
        "providerName": provider,
        "firstName": name,
        "lastName": "",
        "email": email,
        "avatarUrl": imgUrl,
      }));

  dynamic result = convert.jsonDecode(response.body);
  return result;
}
