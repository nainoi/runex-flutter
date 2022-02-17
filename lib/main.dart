import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:runex/screens/screens.dart';
// import 'package:runex/screens/signin/loginfacebook.dart';
// import 'package:runex/screens/signin/logingoogle.dart';
// import 'package:runex/screens/signin/loginline.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LineSDK.instance.setup('1656887265').then((_) {
    print("LineSDK Prepared");
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUNEX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
      // home: MyHomePage(title: 'LineLoginAPI Tutorial | Login'),
      //home: FacebookPage(title: 'Facebook Login'));
    );
  }
}
