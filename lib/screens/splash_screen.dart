import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/employee_section/home/employee_root_screen_navigation.dart';
import 'package:etmm/screens/root_app.dart';
import 'package:etmm/screens/employee_section/setup_pin/confirm_pin.dart';
import 'package:etmm/screens/admin_section/home/admin_root_screen_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../getx_controller/load_excel_controller.dart';
import '../services/shared_pref.dart';
import 'admin_section/setup_pin/confirm_pin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void checkLogin() async {
    String? adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);

    if (adminEmail != null) {
      await loginAdmin();
    } else {
      String? empEmail = SharedPref.get(prefKey: PrefKey.empEmail);
      if (empEmail != null) {
        await loginEmployee();
      } else {
        // Navigate to HomePage if neither admin nor emp is logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RootApp(),
          ),
        );
      }
    }
  }

  Future<void> loginAdmin() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .where('email', isEqualTo: SharedPref.get(prefKey: PrefKey.adminEmail))
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = querySnapshot.docs.first;

      await constants.loadAdminFromFirestore(userDoc.id).then((value) {
        print("SiteLable: ${loadController.siteLable.value}");

        if (userDoc['email'] == SharedPref.get(prefKey: PrefKey.adminEmail)) {
          if (userDoc['pin'] == null || userDoc['pin'] == "") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminRootScreen(
                  userId: userDoc.id,
                  userDoc: userDoc,
                  adminId: userDoc.id,
                  initialIndex: 0,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminConfirmPin(
                  isFromSetPin: true,
                  userDoc: userDoc,
                  // fireStorePin: true,
                ),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RootApp(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your Password has been changed')),
          );
        }
      });




    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RootApp(),
          ));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('You entered a wrong email or password')),
      // );
    }
  }

  Future<void> loginEmployee() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: SharedPref.get(prefKey: PrefKey.empEmail))
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = querySnapshot.docs.first;


      await constants.loadAdminFromFirestore(userDoc['adminId']).then((value) {
        print("SiteLable: ${loadController.siteLable.value}");

        if (userDoc['email'] == SharedPref.get(prefKey: PrefKey.empEmail)) {
          if (userDoc['pin'] == null || userDoc['pin'] == "") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeRootScreen(
                  userId: userDoc.id,
                  userDoc: userDoc,
                  initialIndex: 0,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeConfirmPin(
                  isFromSetPin: true,
                  userDoc: userDoc,
                ),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RootApp(),
            ),
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('You entered a wrong email or password')),
          // );
        }
      });



    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RootApp(),
        ),
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('You entered a wrong email or password')),
      // );
    }
  }

  @override
  void initState() {
    navigateAfterDelay();
    // String? adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
    // if (adminEmail != null) {
    //   constants.loadAdminValues(adminEmail);
    // } else {
    //   print("Admin email is not available.");
    // }
    super.initState();
  }

  final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  void navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 0)).then((value) {
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/app-logo-bg.png', width: 250, height: 250),
              // SizedBox(height: 20),
              Text(
                'Personal Expense Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themecolor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Track your Finances effortlessly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
