import 'package:etmm/const/const.dart';
import 'package:etmm/screens/admin_section/authentication/login_admin.dart';
import 'package:etmm/screens/employee_section/authentication/login_emp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../getx_controller/load_excel_controller.dart';

class RootApp extends StatefulWidget {
  // final DocumentSnapshot userDoc;

  const RootApp({
    Key? key,
  }) : super(key: key);

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  // final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kgrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'Expense',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: kblack,
              ),
            ),
            Text(
              'Tracker',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: kblack,
              ),
            ),
            const SizedBox(height: 200),

            // Admin Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginView(),
                  ),
                );
              },
              child: const SizedBox(
                width: 200, // Set the width
                height: 60, // Set the height
                child: Center(
                  child: Text('Admin Login'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xff0558b4), // Button color
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100), // Button shape
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeeLoginPage()),
                );
              },
              child: SizedBox(
                width: 200, // Set the width
                height: 60, // Set the height
                child: Center(
                  child: Obx(
                    () => Text(
                        '${loadController.siteLable.value != '' ? loadController.siteLable.value : "Employee" /*.split(" ")[0]*/} Login'),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xff0558b4), // Button color
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100), // Button shape
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
