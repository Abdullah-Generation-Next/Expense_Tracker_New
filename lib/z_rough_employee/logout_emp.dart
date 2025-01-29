import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmpLogoutPage extends StatelessWidget {
  final DocumentSnapshot userDoc;

  const EmpLogoutPage({Key? key, required this.userDoc}) : super(key: key);

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
