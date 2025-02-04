import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import '../../../const/const.dart';
import '../../../getx_controller/load_excel_controller.dart';
import '../../../services/shared_pref.dart';
import '../category_section/category_list.dart';

class AppSettingsScreen extends StatefulWidget {
  final String adminId;
  const AppSettingsScreen({super.key, required this.adminId});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool isDateSelected = false;

  final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  @override
  void initState() {
    super.initState();
    // loadController.adminLat.value = "";
    // loadController.adminLng.value = "";
    constants.loadAdminFromFirestore(widget.adminId);
    loadController.lableController.text = loadController.siteLable.value;
    loadController.adminLocationLoading.value = false;
  }

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // String? siteLabel;

  Future<void> _showSiteLableDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // _lableController.text = siteLabel ?? "";

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Employee Lable'),
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    CupertinoIcons.clear,
                    color: Colors.black,
                  )),
            ],
          ),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: loadController.lableController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: 'Enter employee lable'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lable name cannot be empty';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });
                // String newLabel = loadController.lableController.text;
                // if (newLabel.isNotEmpty) {
                //   await loadController.updateSiteLabel(newLabel);
                //   setState(() {
                //     isLoading = false;
                //   });
                // }
                String newLabel = loadController.lableController.text.trim();
                if (newLabel.isEmpty) {
                  newLabel = "Employee";
                }

                await loadController.updateSiteLabel(newLabel);

                setState(() {
                  isLoading = false;
                });
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Update'),
              style: ButtonStyle(
                // ignore: deprecated_member_use
                backgroundColor: MaterialStatePropertyAll(themecolor),
                // ignore: deprecated_member_use
                foregroundColor: MaterialStatePropertyAll(kwhite),
              ),
            ),
          ],
        );
      },
    );
  }

  void showUpdateLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Location"),
          content: Text("Are you sure you want to update your location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                loadController.requestLocationPermission(isAdmin: true, adminId: widget.adminId);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> showRemoveLocationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Disable Location Tracking?"),
              content: Text(
                "Are you sure you want to disable location tracking? This will remove your saved location, and expenses will no longer be tracked by location.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // Cancel
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), // Confirm
                  child: Text("Yes, Disable"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> showConfirmLocationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Add Current Location"),
            content: Text("Do you want to enable location tracking and add your current location?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Add"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget categoryCountText(String adminId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Admin').doc(adminId).collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Customize Categories (...)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: Colors.black,
            ),
          );
        }
        if (snapshot.hasError) {
          return const Text(
            'Customize Categories (Error)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: Colors.black,
            ),
          );
        }
        final totalCategories = snapshot.data?.docs.length ?? 0;
        return Text(
          totalCategories == 0 ? 'Customize Categories' : 'Customize Categories ($totalCategories)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // constants.ensureDefaultFields(widget.adminId);
    // constants.loadFromFirestore(widget.adminId);
    return Scaffold(
      backgroundColor: kgrey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: themecolor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "App Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: Colors.white,
                                leading: Icon(
                                  Icons.category_outlined,
                                  // ignore: deprecated_member_use
                                  color: themecolor.withOpacity(0.65),
                                ),
                                title:
                                    // Text('Customize Categories (6)',
                                    //     style: TextStyle(
                                    //       color: Colors.black,
                                    //       fontSize: 16,
                                    //       fontFamily: 'Inter',
                                    //       fontWeight: FontWeight.bold,
                                    //     )),
                                    categoryCountText(widget.adminId),
                                /* StreamBuilder<QuerySnapshot>(
                                    stream:
                                    FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('categories').snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text(
                                          'Customize Categories (...)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                          ),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Text(
                                          'Customize Categories (Error)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                          ),
                                        );
                                      }
                                      final totalCategories = snapshot.data?.docs.length ?? 0;
                                      if (totalCategories == 0) {
                                        return Text(
                                          'Customize Categories',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                          ),
                                        );
                                      }
                                      return Text(
                                        'Customize Categories ($totalCategories)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),*/
                                subtitle: Text("Manage expense categories."),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.grey.shade500,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryScreen(adminId: widget.adminId),
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: Colors.white,
                                leading: Icon(
                                  CupertinoIcons.building_2_fill,
                                  // ignore: deprecated_member_use
                                  color: themecolor.withOpacity(0.65),
                                ),
                                title: const Text('Customize Employee Lable',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    )),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Change employee lable as per need, i.e. Student, Site, Customer..."),
                                    Obx(
                                      () => loadController.siteLable.value != "Employee"
                                          ? Text(
                                              "${loadController.siteLable.value}",
                                              style: TextStyle(color: Colors.green),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.grey.shade500,
                                ),
                                onTap: () {
                                  _showSiteLableDialog(context);
                                },
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Theme(
                                      data: ThemeData(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                      ),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tileColor: Colors.white,
                                        leading: Icon(
                                          Icons.approval_outlined,
                                          // ignore: deprecated_member_use
                                          color: themecolor.withOpacity(0.65),
                                        ),
                                        subtitle: Text("All expenses will be auto-approved by default while adding."),
                                        title: Text(
                                          'Auto Approve Expense',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () async {
                                          bool currentValue = loadController.isAutoApprove.value == "Yes";
                                          bool newValue = !currentValue; // Toggle the value

                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update({'is_auto_approve': newValue ? "Yes" : "No"});

                                                print(
                                                    "Firestore updated: is_auto_approve set to ${newValue ? "Yes" : "No"}");

                                                loadController.isAutoApprove.value = newValue ? "Yes" : "No";
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                        // onTap: () {
                                        //   showCustomDialog(
                                        //     title: "Auto Approve",
                                        //     switchTitle: "Auto",
                                        //     context: context,
                                        //     initialSwitchValue: loadController.isAutoApprove.value == "Yes" ? true : false,
                                        //     onSwitchChanged: (value) async {
                                        //       try {
                                        //         final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                        //         if (adminEmail != null) {
                                        //           QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                        //               .collection('Admin')
                                        //               .where('email', isEqualTo: adminEmail)
                                        //               .get();
                                        //
                                        //           if (querySnapshot.docs.isNotEmpty) {
                                        //             String adminId = querySnapshot.docs.first.id;
                                        //
                                        //             await FirebaseFirestore.instance
                                        //                 .collection('Admin')
                                        //                 .doc(adminId)
                                        //                 .update({'is_auto_approve': value ? "Yes" : "No"});
                                        //
                                        //             print("Firestore updated: is_auto_approve set to ${value ? "Yes" : "No"}");
                                        //
                                        //             setState(() {
                                        //               loadController.isAutoApprove.value = value ? "Yes" : "No";
                                        //             });
                                        //           } else {
                                        //             print("Admin document not found for email: $adminEmail");
                                        //           }
                                        //         } else {
                                        //           print("Admin email not available.");
                                        //         }
                                        //       } catch (e) {
                                        //         print("Error updating Firestore: $e");
                                        //       }
                                        //     },
                                        //     switchActiveText: "Yes",
                                        //     switchInactiveText: "No",
                                        //   );
                                        // },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Obx(
                                      () => customSwitch(
                                        initialSwitchValue: loadController.isAutoApprove.value == "Yes" ? true : false,
                                        onSwitchChanged: (value) async {
                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update({'is_auto_approve': value ? "Yes" : "No"});

                                                print(
                                                    "Firestore updated: is_auto_approve set to ${value ? "Yes" : "No"}");

                                                loadController.isAutoApprove.value = value ? "Yes" : "No";
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                        switchActiveText: "Yes",
                                        switchInactiveText: "No",
                                      ),
                                    ),
                                    /*FlutterSwitch(
                                      value: loadController.isAutoApprove.value == "Yes" ? true : false,
                                      onToggle: (value) async {
                                        loadController.isAutoApprove.value == "Yes" ? true : false;
                                        try {
                                          final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                          if (adminEmail != null) {
                                            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                .collection('Admin')
                                                .where('email', isEqualTo: adminEmail)
                                                .get();

                                            if (querySnapshot.docs.isNotEmpty) {
                                              String adminId = querySnapshot.docs.first.id;

                                              await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .doc(adminId)
                                                  .update({'is_auto_approve': value ? "Yes" : "No"});

                                              print("Firestore updated: is_auto_approve set to ${value ? "Yes" : "No"}");

                                              loadController.isAutoApprove.value = value ? "Yes" : "No";
                                              setState(() {

                                              });
                                            } else {
                                              print("Admin document not found for email: $adminEmail");
                                            }
                                          } else {
                                            print("Admin email not available.");
                                          }
                                        } catch (e) {
                                          print("Error updating Firestore: $e");
                                        }
                                      },
                                      activeText: "Yes",
                                      inactiveText: "No",
                                      activeColor: Colors.indigo,
                                      inactiveColor: Colors.grey,
                                      activeTextColor: Colors.white,
                                      inactiveTextColor: Colors.white,
                                      valueFontSize: 14,
                                      width: 60,
                                      height: 28,
                                      borderRadius: 50.0,
                                      showOnOff: true,
                                    ),*/
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Theme(
                                      data: ThemeData(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                      ),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tileColor: Colors.white,
                                        leading: Icon(
                                          Icons.date_range_rounded,
                                          // ignore: deprecated_member_use
                                          color: themecolor.withOpacity(0.65),
                                        ),
                                        title: const Text('Allow to change Expense Date',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                            )),
                                        subtitle: Text("If set, the expense date can be changed with the date picker."),
                                        onTap: () async {
                                          bool currentValue = loadController.allowDateToChange.value == "Yes";
                                          bool newValue = !currentValue; // Toggle the value

                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update({'allow_date_to_change': newValue ? "Yes" : "No"});

                                                print(
                                                    "Firestore updated: allow_date_to_change set to ${newValue ? "Yes" : "No"}");

                                                loadController.allowDateToChange.value = newValue ? "Yes" : "No";
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Obx(
                                      () => customSwitch(
                                        initialSwitchValue:
                                            loadController.allowDateToChange.value == "Yes" ? true : false,
                                        onSwitchChanged: (value) async {
                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update({'allow_date_to_change': value ? "Yes" : "No"});

                                                print(
                                                    "Firestore updated: allow_date_to_change set to ${value ? "Yes" : "No"}");

                                                loadController.allowDateToChange.value = value ? "Yes" : "No";
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                        switchActiveText: "Yes",
                                        switchInactiveText: "No",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Theme(
                                      data: ThemeData(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                      ),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tileColor: Colors.white,
                                        leading: Icon(
                                          Icons.smart_button_rounded,
                                          // ignore: deprecated_member_use
                                          color: themecolor.withOpacity(0.65),
                                        ),
                                        title: const Text('Allow Expense Deletion',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                            )),
                                        subtitle: Text("If set, the expense can be deleted by the Employee."),
                                        onTap: () async {
                                          bool currentValue = loadController.showDeleteButton.value == "Yes";
                                          bool newValue = !currentValue; // Toggle the value

                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update({'show_delete_button': newValue ? "Yes" : "No"});

                                                print(
                                                    "Firestore updated: show_delete_button set to ${newValue ? "Yes" : "No"}");

                                                loadController.showDeleteButton.value = newValue ? "Yes" : "No";
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Obx(
                                      () => customSwitch(
                                        initialSwitchValue:
                                            loadController.showDeleteButton.value == "Yes" ? true : false,
                                        onSwitchChanged: (value) async {
                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update({'show_delete_button': value ? "Yes" : "No"});

                                                print(
                                                    "Firestore updated: show_delete_button set to ${value ? "Yes" : "No"}");

                                                loadController.showDeleteButton.value = value ? "Yes" : "No";
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        },
                                        switchActiveText: "Yes",
                                        switchInactiveText: "No",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Theme(
                                      data: ThemeData(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                      ),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tileColor: Colors.white,
                                        leading: Icon(
                                          CupertinoIcons.location_solid,
                                          // ignore: deprecated_member_use
                                          color: themecolor.withOpacity(0.65),
                                        ),
                                        title: const Text('Allow Location Tracking',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                            )),
                                        subtitle: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("All expenses will be tracked by location while adding."),
                                            Obx(
                                              () => loadController.fullAdminAddress.value != ""
                                                  ? Text(
                                                      "${loadController.fullAdminAddress.value}",
                                                      style: TextStyle(color: Colors.green),
                                                    )
                                                  : SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          if (loadController.fullAdminAddress.value == "") {
                                            bool shouldAddLocation = await showConfirmLocationDialog(context);
                                            if (shouldAddLocation) {
                                              loadController.requestLocationPermission(
                                                  isAdmin: true, adminId: widget.adminId);
                                            }
                                          } else {
                                            showUpdateLocationDialog(context);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Obx(
                                      () => customSwitch(
                                        initialSwitchValue: loadController.fullAdminAddress.value != "" ? true : false,
                                        /*onSwitchChanged: (value) async {
                                          if (value) {
                                            if (loadController.fullAdminAddress.value == "") {
                                              bool shouldAddLocation = await showConfirmLocationDialog(context);
                                              if (shouldAddLocation) {
                                                loadController.requestLocationPermission(
                                                    isAdmin: true, adminId: widget.adminId);
                                              }
                                            }
                                          } else {
                                            loadController.fullAdminAddress.value = "";
                                          }
                                        },*/
                                        /*onSwitchChanged: (value) async {
                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });

                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                // Define updates
                                                Map<String, dynamic> updates = {
                                                  'show_delete_button': value ? "Yes" : "No",
                                                };

                                                // If switch is turned off, set 'place' to an empty string
                                                if (!value) {
                                                  updates['place'] = "";
                                                  loadController.fullAdminAddress.value = "";
                                                }

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update(updates);

                                                print("Firestore updated: ${value ? "Yes" : "No"}, place set to ${!value ? 'empty string' : 'unchanged'}");

                                                loadController.showDeleteButton.value = value ? "Yes" : "No";
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }

                                          if (value) {
                                            if (loadController.fullAdminAddress.value == "") {
                                              bool shouldAddLocation = await showConfirmLocationDialog(context);
                                              if (shouldAddLocation) {
                                                loadController.requestLocationPermission(isAdmin: true, adminId: widget.adminId);
                                              }
                                            }
                                          }
                                        },*/
                                        onSwitchChanged: (value) async {
                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });

                                            final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                            if (adminEmail != null) {
                                              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                  .collection('Admin')
                                                  .where('email', isEqualTo: adminEmail)
                                                  .get();

                                              if (querySnapshot.docs.isNotEmpty) {
                                                String adminId = querySnapshot.docs.first.id;

                                                // If switch is turned off, ask for confirmation before updating Firestore
                                                if (!value) {
                                                  bool shouldRemoveLocation = await showRemoveLocationDialog(context);
                                                  if (!shouldRemoveLocation) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    return; // Don't proceed with updating Firestore
                                                  }
                                                }

                                                // Define updates
                                                Map<String, dynamic> updates = {};

                                                // If switch is turned off, set 'place' to an empty string
                                                if (!value) {
                                                  updates['place'] = "";
                                                  loadController.fullAdminAddress.value = "";
                                                }

                                                await FirebaseFirestore.instance
                                                    .collection('Admin')
                                                    .doc(adminId)
                                                    .update(updates);

                                                print(
                                                    "Firestore updated: ${value ? "Yes" : "No"}, place set to ${!value ? 'empty string' : 'unchanged'}");
                                              } else {
                                                print("Admin document not found for email: $adminEmail");
                                              }
                                            } else {
                                              print("Admin email not available.");
                                            }
                                          } catch (e) {
                                            print("Error updating Firestore: $e");
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }

                                          if (value) {
                                            if (loadController.fullAdminAddress.value == "") {
                                              bool shouldAddLocation = await showConfirmLocationDialog(context);
                                              if (shouldAddLocation) {
                                                loadController.requestLocationPermission(
                                                    isAdmin: true, adminId: widget.adminId);
                                              }
                                            }
                                          }
                                        },
                                        switchActiveText: "Yes",
                                        switchInactiveText: "No",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /*
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: Colors.white,
                                leading: Icon(
                                  Icons.date_range_rounded,
                                  // ignore: deprecated_member_use
                                  color: themecolor.withOpacity(0.65),
                                ),
                                title: const Text('Allow to change Expense Date',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    )),
                                subtitle: Text("If set, the expense date can be changed with the date picker."),
                                onTap: () {
                                  showCustomDialog(
                                    title: "Allow Change Date",
                                    switchTitle: "Allow",
                                    context: context,
                                    initialSwitchValue: loadController.allowDateToChange.value == "Yes" ? true : false,
                                    onSwitchChanged: (value) async {
                                      try {
                                        final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                        if (adminEmail != null) {
                                          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                              .collection('Admin')
                                              .where('email', isEqualTo: adminEmail)
                                              .get();

                                          if (querySnapshot.docs.isNotEmpty) {
                                            String adminId = querySnapshot.docs.first.id;

                                            await FirebaseFirestore.instance
                                                .collection('Admin')
                                                .doc(adminId)
                                                .update({'allow_date_to_change': value ? "Yes" : "No"});

                                            print(
                                                "Firestore updated: allow_date_to_change set to ${value ? "Yes" : "No"}");

                                            setState(() {
                                              loadController.allowDateToChange.value = value ? "Yes" : "No";
                                            });
                                          } else {
                                            print("Admin document not found for email: $adminEmail");
                                          }
                                        } else {
                                          print("Admin email not available.");
                                        }
                                      } catch (e) {
                                        print("Error updating Firestore: $e");
                                      }
                                    },
                                    switchActiveText: "Yes",
                                    switchInactiveText: "No",
                                  );
                                },
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: Colors.white,
                                leading: Icon(
                                  Icons.smart_button_rounded,
                                  // ignore: deprecated_member_use
                                  color: themecolor.withOpacity(0.65),
                                ),
                                title: const Text('Allow Expense Deletion',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    )),
                                subtitle: Text("If set, the expense can be deleted by the Employee."),
                                onTap: () {
                                  showCustomDialog(
                                    title: "Show Delete Button",
                                    switchTitle: "Show",
                                    context: context,
                                    initialSwitchValue: loadController.showDeleteButton.value == "Yes" ? true : false,
                                    onSwitchChanged: (value) async {
                                      try {
                                        final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
                                        if (adminEmail != null) {
                                          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                              .collection('Admin')
                                              .where('email', isEqualTo: adminEmail)
                                              .get();

                                          if (querySnapshot.docs.isNotEmpty) {
                                            String adminId = querySnapshot.docs.first.id;

                                            await FirebaseFirestore.instance
                                                .collection('Admin')
                                                .doc(adminId)
                                                .update({'show_delete_button': value ? "Yes" : "No"});

                                            print(
                                                "Firestore updated: show_delete_button set to ${value ? "Yes" : "No"}");

                                            setState(() {
                                              loadController.showDeleteButton.value = value ? "Yes" : "No";
                                            });
                                          } else {
                                            print("Admin document not found for email: $adminEmail");
                                          }
                                        } else {
                                          print("Admin email not available.");
                                        }
                                      } catch (e) {
                                        print("Error updating Firestore: $e");
                                      }
                                    },
                                    switchActiveText: "Yes",
                                    switchInactiveText: "No",
                                  );
                                },
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: Colors.white,
                                leading: Icon(
                                  CupertinoIcons.location_solid,
                                  // ignore: deprecated_member_use
                                  color: themecolor.withOpacity(0.65),
                                ),
                                title: const Text('Allow Location Tracking',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    )),
                                subtitle: Text("All expenses will be tracked by location while adding."),
                                onTap: () {
                                  if (loadController.adminLat.value == "" && loadController.adminLng.value == "") {
                                    loadController.requestLocationPermission(isAdmin: true, adminId: widget.adminId);
                                  } else {
                                    showUpdateLocationDialog(context);
                                  }
                                },
                              ),
                            ),
                            */
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Obx(
                      () => loadController.adminLocationLoading.isTrue
                          ? Container(
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 4,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Fetching Location",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Please Wait...",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    alignment: Alignment.center,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String switchTitle,
    required bool initialSwitchValue,
    required ValueChanged<bool> onSwitchChanged,
    String switchActiveText = "Yes",
    String switchInactiveText = "No",
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          // bool switchValue = initialSwitchValue;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Close Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          // ignore: deprecated_member_use
                          textScaleFactor: 1.25,
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            CupertinoIcons.clear,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  const SizedBox(height: 20),
                  // Switch Row
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        initialSwitchValue = !initialSwitchValue;
                      });
                      onSwitchChanged(initialSwitchValue);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              switchTitle,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 15),
                          FlutterSwitch(
                            value: initialSwitchValue,
                            onToggle: (value) {
                              setState(() {
                                initialSwitchValue = value;
                              });
                              onSwitchChanged(value);
                            },
                            activeText: switchActiveText,
                            inactiveText: switchInactiveText,
                            activeColor: Colors.indigo,
                            inactiveColor: Colors.grey,
                            activeTextColor: Colors.white,
                            inactiveTextColor: Colors.white,
                            valueFontSize: 14,
                            width: 60,
                            height: 28,
                            borderRadius: 50.0,
                            showOnOff: true,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget customSwitch({
    required bool initialSwitchValue,
    required ValueChanged<bool> onSwitchChanged,
    String switchActiveText = "Yes",
    String switchInactiveText = "No",
  }) {
    return FlutterSwitch(
      value: initialSwitchValue,
      onToggle: (value) {
        onSwitchChanged(value);
      },
      activeText: switchActiveText,
      inactiveText: switchInactiveText,
      activeColor: Colors.indigo,
      inactiveColor: Colors.grey,
      activeTextColor: Colors.white,
      inactiveTextColor: Colors.white,
      valueFontSize: 14,
      width: 60,
      height: 28,
      borderRadius: 50.0,
      showOnOff: true,
    );
  }
}

//ignore: must_be_immutable
class AutoApproveSwitch extends StatefulWidget {
  final bool initialSwitchValue;
  const AutoApproveSwitch({
    Key? key,
    required this.initialSwitchValue,
  }) : super(key: key);

  @override
  _AutoApproveSwitchState createState() => _AutoApproveSwitchState();
}

class _AutoApproveSwitchState extends State<AutoApproveSwitch> {
  RxBool isLoading = false.obs;
  bool? switchValue;

  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  @override
  void initState() {
    super.initState();
    switchValue = widget.initialSwitchValue;
  }

  Future<void> updateAutoApprove(bool value) async {
    setState(() {
      isLoading.value = true;
    });

    try {
      final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
      if (adminEmail != null) {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('Admin').where('email', isEqualTo: adminEmail).get();

        if (querySnapshot.docs.isNotEmpty) {
          String adminId = querySnapshot.docs.first.id;

          await FirebaseFirestore.instance
              .collection('Admin')
              .doc(adminId)
              .update({'is_auto_approve': value ? "Yes" : "No"});

          print("Firestore updated: is_auto_approve set to ${value ? "Yes" : "No"}");

          loadController.isAutoApprove.value = value ? "Yes" : "No";

          setState(() {
            switchValue = value;
          });
        } else {
          print("Admin document not found for email: $adminEmail");
        }
      } else {
        print("Admin email not available.");
      }
    } catch (e) {
      print("Error updating Firestore: $e");
    }

    setState(() {
      isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 7.5),
      child: FlutterSwitch(
        value: switchValue ?? false,
        onToggle: (value) {
          setState(() {
            switchValue = value;
          });
          updateAutoApprove(value);
        },
        activeText: "Yes",
        inactiveText: "No",
        activeColor: Colors.indigo,
        inactiveColor: Colors.grey,
        activeTextColor: Colors.white,
        inactiveTextColor: Colors.white,
        valueFontSize: 14,
        width: 60,
        height: 28,
        borderRadius: 50.0,
        showOnOff: true,
      ),
    );
  }
}

/*
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Show Delete Button",
                                                // ignore: deprecated_member_use
                                                textScaleFactor: 1.5,
                                                style: TextStyle(
                                                  color: themecolor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.clear,
                                                    color: Colors.black,
                                                  ))
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 0,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isDateSelected = !isDateSelected;
                                              SharedPref.save(
                                                value: !isDateSelected ? '0' : '1',
                                                prefKey: PrefKey.defaultDatePickAdmin,
                                              );
                                              print(
                                                  "Default Date Pick: ${SharedPref.get(prefKey: PrefKey.defaultDatePickAdmin)}");
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(width: 20),
                                                Expanded(
                                                  child: Text(
                                                    "Show",
                                                    style: TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                FlutterSwitch(
                                                  value: isDateSelected,
                                                  onToggle: (value) {
                                                    setState(() {
                                                      isDateSelected = value;
                                                      SharedPref.save(
                                                        value: value ? '1' : '0',
                                                        prefKey: PrefKey.defaultDatePickAdmin,
                                                      );
                                                      print(
                                                          "Default Date Pick: ${SharedPref.get(prefKey: PrefKey.defaultDatePickAdmin)}");
                                                    });
                                                  },
                                                  activeText: "Yes",
                                                  inactiveText: "No",
                                                  activeColor: Colors.indigo,
                                                  inactiveColor: Colors.grey,
                                                  activeTextColor: Colors.white,
                                                  inactiveTextColor: Colors.white,
                                                  valueFontSize: 14,
                                                  width: 60,
                                                  height: 28,
                                                  borderRadius: 50.0,
                                                  showOnOff: true,
                                                ),
                                                SizedBox(width: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            },
                          );
                          */
