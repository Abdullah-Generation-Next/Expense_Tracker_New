import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:etmm/services/shared_pref.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPref.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
      // webRecaptchaSiteKey: 'YOUR_RECAPTCHA_SITE_KEY', // Only needed for web
      );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? referrer = '';

  @override
  void initState() {
    super.initState();
    initReferrerDetails();
  }

  Future<void> initReferrerDetails() async {
    String referrerDetailsString;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      ReferrerDetails referrerDetails = await AndroidPlayInstallReferrer.installReferrer;

      referrerDetailsString = referrerDetails.toString();
    } catch (e) {
      referrerDetailsString = 'Failed to get referrer details: $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      referrer = referrerDetailsString;
    });
    print('>>>>>>>>>' + referrer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: "Quicksand",
            fontWeight: FontWeight.w300,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.black,
        ),
      ),
      home: SplashScreen(),
      // Container(child: Text(referrer.toString()),),
      // SharedPref.get(prefKey: PrefKey.adminEmail) != null
      //     ? SplashScreen()
      //     : SharedPref.get(prefKey: PrefKey.empEmail) != null
      //         ? SplashScreen()
      //         : RootApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}
