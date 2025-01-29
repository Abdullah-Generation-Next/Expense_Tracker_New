import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/employee_section/home/employee_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../profile/employee_profile_screen.dart';
import '../expense/expense_list_employee.dart';

class EmployeeRootScreen extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userDoc;
  final int initialIndex;
  final Function(int)? setActiveTab;
  const EmployeeRootScreen({
    Key? key,
    required this.initialIndex,
    this.setActiveTab,
    required this.userId,
    required this.userDoc,
  }) : super(key: key);

  @override
  State<EmployeeRootScreen> createState() => _EmployeeRootScreenState();
}

class _EmployeeRootScreenState extends State<EmployeeRootScreen> {
  // int activeTab = 0;
  late int activeTab;
  int backPressCounter = 0;

  final constants = Const();

  @override
  void initState() {
    super.initState();
    activeTab = widget.initialIndex;
    constants.loadUserData(widget.userId);
  }

  void _onItemTapped(int index) {
    setState(() {
      activeTab = index;
      widget.setActiveTab?.call(index);
    });
  }

  Future<bool> _onBackPress(BuildContext context) async {
    if (activeTab != 0) {
      setState(() {
        activeTab = 0;
      });
      return false;
    } else {
      if (backPressCounter == 0) {
        // Show the 'Tap again Back to exit' toast
        Fluttertoast.showToast(
          msg: 'Swipe back again to exit',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );

        // Increment the counter
        backPressCounter++;

        // Wait for 2 seconds to reset the counter
        await Future.delayed(Duration(seconds: 3));

        // Reset the counter
        backPressCounter = 0;
        return false;
      } else {
        exit(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        return _onBackPress(context);
      },
      child: Scaffold(
        backgroundColor: Color(0xffeeeeee),
        resizeToAvoidBottomInset: false,
        body: activeTab == 0
            ? EmployeeHomeScreen(
                userId: widget.userId,
                userDoc: widget.userDoc,
              )
            : activeTab == 1
                ? ExpenseListEmployee(
                    userDoc: widget.userDoc,
                  )
                : activeTab == 2
                    ? EmployeeProfileScreen(
                        userId: widget.userId,
                        userDoc: widget.userDoc,
                      )
                    : Container(),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
              // border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.withOpacity(0.25)))
              ),
          child: BottomNavigationBar(
            iconSize: 25,
            selectedItemColor: themecolor,
            selectedIconTheme: IconThemeData(color: themecolor),
            elevation: 0,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: activeTab,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                tooltip: 'Home',
                icon: Icon(CupertinoIcons.house),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                tooltip: 'Expenses',
                icon: Icon(Icons.currency_rupee),
                label: 'Expenses',
              ),
              BottomNavigationBarItem(
                tooltip: 'Profile',
                icon: Icon(CupertinoIcons.profile_circled),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
