import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectivityProvider with ChangeNotifier {
  // final Connectivity _connectivity = new Connectivity();
  // ConnectivityResult _connectionStatus = ConnectivityResult.none;
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late bool _isOnline = true;
  bool get isOnline => _isOnline;

  startMonitoring() async {
    // initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // _connectivity.onConnectivityChanged.listen((
    //   ConnectivityResult result,
    // ) async {
    //   if (result == ConnectivityResult.none) {
    //     _isOnline = false;
    //     notifyListeners();
    //   } else if(result == ConnectivityResult.mobile || result == ConnectivityResult.wifi){
    //     await _updateConnectionStatus().then((bool isConnected) {
    //       _isOnline = isConnected;
    //       notifyListeners();
    //     });
    //   }
    // });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initConnectivity() async {
    // late ConnectivityResult result;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   result = await _connectivity.checkConnectivity();
    // } on PlatformException catch (e) {
    //   developer.log('Couldn\'t check connectivity status', error: e);
    //   return;
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) {
    //   return Future.value(null);
    // }

  //   return _updateConnectionStatus(result);
  // }

  // Future<void> initConnectivity() async {
  //   try {
  //     var status = await _connectivity.checkConnectivity();
  //
  //     if (status == ConnectivityResult.none) {
  //       _isOnline = false;
  //       notifyListeners();
  //     } else {
  //       _isOnline = true;
  //       notifyListeners();
  //     }
  //   } on PlatformException catch (e) {}
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   _connectionStatus = result;
  // }

  // Future<bool> _updateConnectionStatus() async {
  //   late bool isConnected;
  //   try {
  //     final List<InternetAddress> result =
  //         await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       isConnected = true;
  //     }
  //   } on SocketException catch (_) {
  //     isConnected = false;
  //   }
  //   return isConnected;
  // }
}
