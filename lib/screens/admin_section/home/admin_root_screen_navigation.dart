import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/admin_section/admin_create_employee/create_employee_dialog.dart';
import 'package:etmm/screens/admin_section/profile/admin_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../getx_controller/load_excel_controller.dart';
import '../expense/expense_list_admin.dart';
import 'admin_home.dart';

class AdminRootScreen extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userDoc;
  final String adminId;
  final int initialIndex;
  final Function(int)? setActiveTab;
  const AdminRootScreen({
    Key? key,
    required this.initialIndex,
    this.setActiveTab,
    required this.userId,
    required this.userDoc,
    required this.adminId,
  }) : super(key: key);

  @override
  State<AdminRootScreen> createState() => _AdminRootScreenState();
}

class _AdminRootScreenState extends State<AdminRootScreen> {
  // int activeTab = 0;
  late int activeTab;
  int backPressCounter = 0;

  late DocumentSnapshot updatedUserDoc;

  final constants = Const();

  @override
  void initState() {
    super.initState();
    activeTab = widget.initialIndex;
    updatedUserDoc = widget.userDoc;
    constants.loadAdminFromFirestore(widget.adminId);
    _checkAndUpdateCompanyLogo();
  }

  Future<void> _checkAndUpdateCompanyLogo() async {
    final userData = updatedUserDoc.data() as Map<String, dynamic>;

    if (!userData.containsKey('company_logo') || userData['company_logo'] == '') {
      await FirebaseFirestore.instance.collection('Admin').doc(updatedUserDoc.id).update({'company_logo': ''});
    }
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

  // final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

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
            ? AdminHomeScreen(
                userId: widget.userId,
                userDoc: updatedUserDoc,
                adminId: widget.adminId,
              )
            : activeTab == 1
                ? CreateEmployeeDialog(adminId: widget.adminId)
                : activeTab == 2
                    ? AdminExpensePage(
                        adminId: widget.adminId,
                        userDoc: updatedUserDoc,
                      )
                    : activeTab == 3
                        ? AdminProfileScreen(
                            userId: widget.userId,
                            userDoc: updatedUserDoc,
                            adminId: widget.adminId,
                            // setActiveTab: (int tab) {
                            //                 setState(() {
                            //                   activeTab = tab;
                            //                 });
                            //               }
                          )
                        : Container(),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
              // border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.withOpacity(0.25)))
              ),
          child: Obx(
            () => BottomNavigationBar(
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
                  tooltip: '${loadController.siteLable.value}',
                  icon: Icon(Icons.groups),
                  label: '${loadController.siteLable.value}',
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
      ),
    );
  }
}
