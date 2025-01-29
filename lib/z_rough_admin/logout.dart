import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/screens/root_app.dart';
import 'package:etmm/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LogoutPage extends StatelessWidget {
  final DocumentSnapshot userDoc;

  const LogoutPage({Key? key, required this.userDoc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Logout',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          // ignore: deprecated_member_use
          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blue)),
          onPressed: () {
            // Show a confirmation dialog before logging out
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
          child: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
