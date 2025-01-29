import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/employee_section/home/employee_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../employee_section/expense/expense_list_employee.dart';
import '../../employee_section/profile/employee_profile_screen.dart';

class AdminEmployeeScreen extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userDoc;
  final int initialIndex;
  final Function(int)? setActiveTab;
  const AdminEmployeeScreen({
    Key? key,
    required this.initialIndex,
    this.setActiveTab,
    required this.userId,
    required this.userDoc,
  }) : super(key: key);

  @override
  State<AdminEmployeeScreen> createState() => _AdminEmployeeScreenState();
}

class _AdminEmployeeScreenState extends State<AdminEmployeeScreen> {
  // int activeTab = 0;
  late int activeTab;
  int backPressCounter = 0;

  @override
  void initState() {
    super.initState();
    activeTab = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kgrey,
      appBar: AppBar(
        backgroundColor: themecolor,
        title: Text(
          "${widget.userDoc['username'] ?? "UnknownEmployeeName"} Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite
              // backgroundColor: Color(0xff0393f4),
              ),
        ),
        iconTheme: IconThemeData(color: kwhite),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themecolor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        activeTab = 0;
                      });
                    },
                    child: Tooltip(
                      message: "Home",
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      textStyle: TextStyle(color: Colors.black),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: activeTab == 0 ? Colors.black : Colors.white),
                          color: activeTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Text(
                          'Home',
                          style: TextStyle(
                            color: activeTab == 0 ? themecolor : Colors.white,
                            fontWeight: activeTab == 0 ? FontWeight.bold : FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(width: 10),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        activeTab = 1;
                      });
                    },
                    child: Tooltip(
                      message: "Expenses",
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      textStyle: TextStyle(color: Colors.black),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: activeTab == 1 ? Colors.black : Colors.white),
                          color: activeTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Text(
                          'Expenses',
                          style: TextStyle(
                            color: activeTab == 1 ? themecolor : Colors.white,
                            fontWeight: activeTab == 1 ? FontWeight.bold : FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(width: 10),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        activeTab = 2;
                      });
                    },
                    child: Tooltip(
                      message: "Profile",
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      textStyle: TextStyle(color: Colors.black),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: activeTab == 2 ? Colors.black : Colors.white),
                          color: activeTab == 2 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: activeTab == 2 ? themecolor : Colors.white,
                            fontWeight: activeTab == 2 ? FontWeight.bold : FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: activeTab == 0
                ? EmployeeHomeScreen(
                    userId: widget.userId,
                    userDoc: widget.userDoc,
                    fromAdmin: true,
                  )
                : activeTab == 1
                    ? ExpenseListEmployee(
                        userDoc: widget.userDoc,
                        fromAdmin: true,
                      )
                    : activeTab == 2
                        ? EmployeeProfileScreen(
                            userId: widget.userId,
                            userDoc: widget.userDoc,
                            fromAdmin: true,
                          )
                        : Container(),
          ),
        ],
      ),
    );
  }
}
