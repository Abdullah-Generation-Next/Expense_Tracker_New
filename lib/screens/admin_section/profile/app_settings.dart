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
    constants.loadAdminFromFirestore(widget.adminId);
    loadController.lableController.text = loadController.siteLable.value;
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
              Text('Site Lable'),
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
              decoration: InputDecoration(hintText: 'Enter category name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Category name cannot be empty';
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
                String newLabel = loadController.lableController.text;
                if (newLabel.isNotEmpty) {
                  await loadController.updateSiteLabel(newLabel);
                  Navigator.pop(context);
                }
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
      body: Padding(
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
                            title: const Text('Categories',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Manage your expenses categories from here."),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryScreen(adminId: widget.adminId),
                                ),
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
                              CupertinoIcons.building_2_fill,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: const Text('Expense Lable',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Edit your expense lable over all app."),
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
                            subtitle: Text("All expenses make default auto approve."),
                            title: const Text('Auto Approve',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            onTap: () {
                              showCustomDialog(
                                title: "Auto Approve",
                                switchTitle: "Auto",
                                context: context,
                                initialSwitchValue: loadController.isAutoApprove.value == "Yes" ? true : false,
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
                                            .update({'is_auto_approve': value ? "Yes" : "No"});

                                        print("Firestore updated: is_auto_approve set to ${value ? "Yes" : "No"}");

                                        setState(() {
                                          loadController.isAutoApprove.value = value ? "Yes" : "No";
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
                              Icons.date_range_rounded,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: const Text('Allow Date to Change',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Set default date & time picker ON."),
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

                                        print("Firestore updated: allow_date_to_change set to ${value ? "Yes" : "No"}");

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
                            title: const Text('Show Delete Button Site',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Show delete button inside Employee expenses."),
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

                                        print("Firestore updated: show_delete_button set to ${value ? "Yes" : "No"}");

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
                            title: const Text('Add Default Location',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Store your current location."),
                            onTap: () {
                              // loadController.getCurrentLocation();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ],
                ),
                Obx(
                  () => loadController.locationLoading.isTrue
                      ? Center(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)),
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
                                    style:
                                        TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Please Wait...",
                                    style:
                                        TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
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
