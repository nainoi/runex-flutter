import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:provider/provider.dart';
import 'package:runex/screens/login.dart';
import 'package:runex/screens/screens.dart';
// import 'package:runex/screens/signin/loginfacebook.dart';
// import 'package:runex/screens/signin/logingoogle.dart';
// import 'package:runex/screens/signin/loginline.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:runex/screens/widgets/connectivity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LineSDK.instance.setup('1656887265').then((_) {
    print("LineSDK Prepared");
  });
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(),
        )
      ],
      child: MaterialApp(
        title: 'RUNEX',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const Login(),
        // home: MyHomePage(title: 'LineLoginAPI Tutorial | Login'),
        //home: FacebookPage(title: 'Facebook Login'));
      ),
    );
  }
}
