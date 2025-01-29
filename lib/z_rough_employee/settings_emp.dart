import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/z_rough_employee/edit_signup_emp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'expense_list_emp_old.dart';
import '../screens/root_app.dart';
import '../services/shared_pref.dart';

class EmpSettingsPage extends StatelessWidget {
  final DocumentSnapshot userDoc;

  EmpSettingsPage({required this.userDoc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Centered icon
          // Center(
          //   child: Icon(
          //     Icons.check_circle_outline,
          //     size: 250,
          //     color: Colors.redAccent,
          //   ),
          // ),
          // SizedBox(height: 20), // Spacer

          // List of options
          ListTile(
            leading: Icon(Icons.mail_lock_outlined),
            title: Text(
              'Change Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmpEditProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.money),
            title: Text(
              'View Expenses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExpenseListEmpOld(
                          userDoc: userDoc,
                        )),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_sharp),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              print("hjvnkhj");
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout Confirmation'),
                    content: const Text('Do you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        // ignore: deprecated_member_use
                        style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                        onPressed: () async {
                          try {
                            // Sign out the user
                            SharedPref.deleteAll();
                            await FirebaseAuth.instance.signOut();
                            // Navigate to the login page
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => RootApp()),
                            );
                          } catch (e) {
                            if (kDebugMode) {
                              print('Error signing out: $e');
                            }
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Add more ListTile widgets for additional options
        ],
      ),
    );
  }
}
