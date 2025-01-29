import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/screens/admin_section/profile/edit_profile_admin.dart';
import 'package:etmm/z_rough_admin/logout.dart';
import 'package:flutter/material.dart';
import 'view_all.dart';

class AdminSettingsPage extends StatelessWidget {
  final DocumentSnapshot userDoc;

  const AdminSettingsPage({Key? key, required this.userDoc}) : super(key: key);

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
          Center(
            child: Icon(
              Icons.check_circle_outline,
              size: 250,
              color: Colors.redAccent,
            ),
          ),
          SizedBox(height: 20), // Spacer

          // List of options
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Edit Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminEditProfilePage(
                          adminId: userDoc.id,
                        )),
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
                MaterialPageRoute(builder: (context) => ViewAllExpensesPage(userDoc: userDoc)),
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
              print("yjhgmvjyhfkvyuhjmfuky");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogoutPage(userDoc: userDoc)),
              );
            },
          ),
          // Add more ListTile widgets for additional options
        ],
      ),
    );
  }
}
