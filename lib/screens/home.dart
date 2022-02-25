// ignore_for_file: prefer_const_constructors, unnecessary_new, unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:runex/screens/login.dart';
import 'package:runex/screens/screens.dart';
import 'package:runex/screens/widgets/widgets.dart';
import 'package:runex/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late bool _calledWorkoutPage = false;
  late InAppWebViewController _inAppWebViewController;

  var userToken = '';
  Future<String?> checkUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loggedIn = prefs.getString("token");

    if (loggedIn == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
    }
    return loggedIn;
  }

  void asyncMethod() async {
    var token = await checkUserLoggedIn();
    print(token);
    setState(() {
      userToken = token!;
    });
    print('URL' + Constants.runexUrl + userToken);
    print('User' + userToken);
  }

  Future<bool> _requestPop() async {
    final url = await _inAppWebViewController.getUrl();
    if (url.toString() == Constants.runexUrl + Constants.mobileCodeUrl ||
        url.toString() == Constants.runexUrl) {
      return Future.value(true);
    } else {
      _inAppWebViewController.goBack();
      return Future.value(false);
    }
  }

  @override
  void initState() {
    super.initState();
    asyncMethod();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _body() {
    return Consumer<ConnectivityProvider>(
      builder: (context, model, child) {
        return model.isOnline
            ? InAppWebView(
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(supportZoom: false)),
                initialUrlRequest:
                    URLRequest(url: Uri.parse(Constants.runexUrl + userToken)),
                onWebViewCreated: (controller) {
                  _inAppWebViewController = controller;
                },
                onLoadStop: (controller, uri) {
                  if (uri.toString().contains(Constants.workOutUrlKeyword) &&
                      !_calledWorkoutPage) {
                    _calledWorkoutPage = true;
                    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => WorkOut()))
                        .then((_) => setState(() {
                              _calledWorkoutPage = false;
                            }));
                    _inAppWebViewController.reload();
                  }
                },
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  await Permission.photos.request();
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                })
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Icon(
                      Icons.wifi_off_outlined,
                      color: Colors.grey,
                      size: 100,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ขาดการเชื่อมต่ออินเตอร์เน็ต",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: SafeArea(
        child: Scaffold(backgroundColor: Colors.black87, body: _body()),
      ),
    );
  }

  void _signIn() async {
    try {
      final result = await LineSDK.instance.login();
      // user id -> result.userProfile?.userId
      // user name -> result.userProfile?.displayName
      // user avatar -> result.userProfile?.pictureUrl
    } on PlatformException catch (e) {}
  }
}
