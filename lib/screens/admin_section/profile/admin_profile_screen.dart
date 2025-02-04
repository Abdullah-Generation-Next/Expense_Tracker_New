import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/root_app.dart';
import 'package:etmm/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../getx_controller/load_excel_controller.dart';
import '../authentication/change_password_admin.dart';
import '../setup_pin/set_pin.dart';
import 'about_us_screen.dart';
import 'app_settings.dart';
import 'edit_profile_admin.dart';

class AdminProfileScreen extends StatefulWidget {
  final String adminId;
  final String userId;
  final DocumentSnapshot userDoc;
  const AdminProfileScreen({super.key, required this.userDoc, required this.adminId, required this.userId});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late DocumentSnapshot updatedUserDoc;

  // final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());
  AdminProfileController controller = Get.put(AdminProfileController());

  Future<void> launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Hello&body=How are you?',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  TextEditingController dialogController = TextEditingController();

  @override
  void initState() {
    // setState(() {
    //   isDateSelected = (SharedPref.get(prefKey: PrefKey.defaultDatePickAdmin) == null ||
    //           SharedPref.get(prefKey: PrefKey.defaultDatePickAdmin) == '1')
    //       ? true
    //       : false;
    // });
    updatedUserDoc = widget.userDoc;
    // controller.finalImageUrl.value = widget.userDoc['company_logo'];
    loadAdminCompanyLogo(widget.adminId);
    super.initState();
  }

  Future<void> loadAdminCompanyLogo(String adminId) async {
    await loadController.updateAdminPinStatusFromFirestore(widget.adminId);
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();

      if (adminDoc.exists && adminDoc.data() != null) {
        String logoUrl = adminDoc['company_logo'] ?? '';
        controller.finalImageUrl.value = logoUrl.isNotEmpty ? logoUrl : '';
      }
    } catch (e) {
      print("Error fetching admin company logo: $e");
    }
  }

  void _refreshProfileData() async {
    final updatedDoc = await FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).get();

    setState(() {
      updatedUserDoc = updatedDoc;
    });
  }

  /*Future<void> updatePinStatusFromFirestore() async {
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(widget.adminId) // Replace with your adminId or pass it dynamically
          .get();

      if (adminDoc.exists && adminDoc.data() != null) {
        Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

        String? savedPin = adminData['pin']?.toString();
        if (savedPin != null && savedPin != "" && savedPin.isNotEmpty && savedPin.length == 4) {
          setState(() {
            isPinEnabled = true;
          });
        } else {
          setState(() {
            isPinEnabled = false;
          });
        }
      } else {
        setState(() {
          isPinEnabled = false;
        });
      }
    } catch (error) {
      print("Error fetching PIN from Firestore: $error");
      setState(() {
        isPinEnabled = false;
      });
    }
  }*/

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadController.updateAdminPinStatusFromFirestore(widget.adminId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kgrey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: themecolor,
        automaticallyImplyLeading: false,
        title: Text(
          "Admin Profile",
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /* Old Updated to New
                                (updatedUserDoc['company_logo'] != null && updatedUserDoc['company_logo'] != "")
                                    ?
                                    // CircleAvatar(
                                    //         radius: 30,
                                    //         foregroundImage: NetworkImage(updatedUserDoc['company_logo'] ?? ""),
                                    //         backgroundColor: Colors.transparent,
                                    //         child: GestureDetector(
                                    //           onTap: () async {
                                    //             await showDialog(
                                    //               context: context,
                                    //               builder: (_) => Center(
                                    //                 child: Padding(
                                    //                   padding: const EdgeInsets.only(left: 50, right: 50),
                                    //                   child: GestureDetector(
                                    //                     onTap: () {
                                    //                       Navigator.pop(context);
                                    //                     },
                                    //                     child: Container(
                                    //                       width: double.infinity,
                                    //                       height: 250,
                                    //                       decoration: BoxDecoration(
                                    //                         shape: BoxShape.circle,
                                    //                         color: Colors.transparent,
                                    //                         image: DecorationImage(
                                    //                             image: NetworkImage(updatedUserDoc['company_logo'] ?? ""),
                                    //                             fit: BoxFit.fill),
                                    //                       ),
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             );
                                    //           },
                                    //         ),
                                    //       )
                                    CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.transparent,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (_) => Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 50, right: 50),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 250,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.transparent,
                                                        image: DecorationImage(
                                                          image: NetworkImage(updatedUserDoc['company_logo'] ?? ""),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: updatedUserDoc['company_logo'] != null &&
                                                  updatedUserDoc['company_logo'] != ""
                                              ? Container(
                                                  width: 100,
                                                  height: 100,
                                                  child: ClipOval(
                                                    clipBehavior: Clip.hardEdge,
                                                    child: Image.network(
                                                      updatedUserDoc['company_logo'] ?? "",
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (BuildContext context, Widget child,
                                                          ImageChunkEvent? loadingProgress) {
                                                        if (loadingProgress == null) {
                                                          // If the image has been loaded, show the image
                                                          return child;
                                                        } else {
                                                          // While loading, show the CircularProgressIndicator
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                      (loadingProgress.expectedTotalBytes ?? 1)
                                                                  : null,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (_) => Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 50, right: 50),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 250,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blueGrey,
                                                      // image: DecorationImage(
                                                      //     image: AssetImage("assets/images/profile.png"), fit: BoxFit.contain),
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 175,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 30,
                                          // backgroundImage: NetworkImage(
                                          //     'https://img.freepik.com/free-icon/user_318-159711.jpg?w=360'),
                                          backgroundColor: Colors.blueGrey,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                */
                              Obx(
                                () => (controller.finalImageUrl.value != "")
                                    ? CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.transparent,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (_) => Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 50, right: 50),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 250,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.transparent,
                                                        image: DecorationImage(
                                                          image: NetworkImage(controller.finalImageUrl.value),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: controller.finalImageUrl.value != ""
                                              ? Container(
                                                  width: 100,
                                                  height: 100,
                                                  child: ClipOval(
                                                    clipBehavior: Clip.hardEdge,
                                                    child: Image.network(
                                                      controller.finalImageUrl.value,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (BuildContext context, Widget child,
                                                          ImageChunkEvent? loadingProgress) {
                                                        if (loadingProgress == null) {
                                                          // If the image has been loaded, show the image
                                                          return child;
                                                        } else {
                                                          // While loading, show the CircularProgressIndicator
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                      (loadingProgress.expectedTotalBytes ?? 1)
                                                                  : null,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (_) => Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 50, right: 50),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 250,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blueGrey,
                                                      // image: DecorationImage(
                                                      //     image: AssetImage("assets/images/profile.png"), fit: BoxFit.contain),
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 175,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 40,
                                          // backgroundImage: NetworkImage(
                                          //     'https://img.freepik.com/free-icon/user_318-159711.jpg?w=360'),
                                          backgroundColor: Colors.blueGrey,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    updatedUserDoc['username'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Text(
                                    "(Admin)",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      launchEmail(updatedUserDoc['email']);
                                    },
                                    child: Text(
                                      updatedUserDoc['email'], // Assuming 'email' field exists in userDoc
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Inter',
                                        height: 1.21,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // const Text(
                              //   'Admin Panel',
                              //   // textAlign: TextAlign.center,
                              //   style: TextStyle(
                              //     color: Colors.black,
                              //     fontSize: 20,
                              //     fontWeight: FontWeight.bold,
                              //     fontFamily: 'Inter',
                              //   ),
                              // ),
                            ],
                          ),
                          // Spacer(),
                          // const SizedBox(height: 10),
                        ],
                      ),
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
                              CupertinoIcons.settings,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: const Text('App Settings',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Manage your app with more settings."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppSettingsScreen(adminId: widget.adminId),
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
                              Icons.edit,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: const Text('Edit Profile',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Edit your personal details."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () async {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => AdminEditProfilePage(adminId: widget.adminId),
                              //   ),
                              // );

                              final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminEditProfilePage(adminId: widget.adminId),
                                ),
                              );

                              if (updatedData != null && updatedData is Map<String, dynamic>) {
                                _refreshProfileData();
                              }
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
                              Icons.lock,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: const Text('Change Password',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Change your current password."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () {
                              // Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminChangePassword(userDoc: updatedUserDoc),
                                ),
                              );
                            },
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
                            title: Text(
                              'Set PIN',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16.0,
                                // fontWeight: FontWeight.w500,
                                height: 1.21,
                              ),
                            ),
                            leading: Icon(
                              Icons.lightbulb_outline,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              // setState(() {
                              //   _lightsOn = !_lightsOn;
                              //   print(_lightsOn);
                              // });
                              // if (_lightsOn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminSetPin(
                                          userId: widget.userId,
                                          userDoc: updatedUserDoc,
                                          adminId: widget.adminId,
                                        )),
                              );
                              // }
                            },
                          ),
                        ),
                        */
                        Card(
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.white,
                          child: Obx(() => SwitchListTile(
                              secondary: Icon(
                                Icons.pin_rounded,
                                // ignore: deprecated_member_use
                                color: themecolor.withOpacity(0.65),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              tileColor: Colors.white,
                              activeColor: themecolor,
                              title: Text(
                                'Set PIN',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  height: 1.21,
                                ),
                              ),
                              subtitle: Text("Secure your app with a PIN."),
                              value: loadController.isAdminPinEnabled.value,
                              onChanged: (value) async {
                                try {
                                  if (!value) {
                                    // When the switch is turned OFF (Disable PIN)
                                    await FirebaseFirestore.instance
                                        .collection('Admin')
                                        .doc(widget.adminId)
                                        .update({'isSwitchOn': false, 'pin': ''}); // Update Firestore
                                    // setState(() {
                                    loadController.isAdminPinEnabled.value = false;
                                    // });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("PIN disabled successfully.")),
                                    );
                                  } else {
                                    // When the switch is turned ON (Enable PIN)
                                    bool isSwitchOn =
                                        await loadController.getAdminSavedPinFromFirestore(widget.adminId);
                                    if (isSwitchOn) {
                                      // If already enabled in Firestore
                                      // setState(() {
                                      loadController.isAdminPinEnabled.value = true;
                                      // });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("PIN is already enabled.")),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminSetPin(
                                            userId: widget.userId,
                                            userDoc: updatedUserDoc,
                                            adminId: widget.adminId,
                                          ),
                                        ),
                                      ).then((result) async {
                                        final adminDoc = await FirebaseFirestore.instance
                                            .collection('Admin')
                                            .doc(widget.adminId)
                                            .get();
                                        // setState(() {
                                        loadController.isAdminPinEnabled.value = adminDoc['isSwitchOn'] ?? false;
                                        // });
                                        await loadController.updateAdminPinStatusFromFirestore(widget.adminId);
                                      });
                                    }
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("An error occurred: $e")),
                                  );
                                }
                              })),
                        ),
                        /*Card(
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
                            title: Text(
                              'Set Defaults',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16.0,
                                // fontWeight: FontWeight.w500,
                                height: 1.21,
                              ),
                            ),
                            leading: Icon(
                              Icons.settings,
                              color: Colors.grey,
                            ),
                            onTap: () {
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
                                                    "Set Default Date Pick",
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
                                                        "Select Date Picker",
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
                            },
                          ),
                        ),*/
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
                              CupertinoIcons.doc_text_fill,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: Text(
                              "About Us",
                              // ignore: deprecated_member_use
                              // textScaleFactor: 1.2,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            subtitle: Text("About the application."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () {
                              /*showDialog(
                                context: context,
                                builder: (BuildContext context) {
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
                                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "About App",
                                                  // ignore: deprecated_member_use
                                                  textScaleFactor: 1.7,
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
                                          // SizedBox(
                                          //   height: 10,
                                          // ),
                                          Expanded(
                                            child: ScrollConfiguration(
                                                behavior: ScrollBehavior().copyWith(overscroll: false),
                                                child: SingleChildScrollView(
                                                    child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                                                      child: Obx(() => Text(
                                                            "Expense Tracker provides the following features:\n"
                                                            "- Admin and ${loadController.siteLable.value} tracking with real-time date & time.\n"
                                                            "- Storing bill photos inside each expense.\n"
                                                            "- Edit admin profile.\n"
                                                            "- Manage ${loadController.siteLable.value}.\n"
                                                            "- Change admin password.\n"
                                                            "- View expense list.\n"
                                                            "- Filter expenses by date & time.\n"
                                                            "- Filter expenses by Title, Amount (high to low, low to high), Date (newest to oldest, oldest to newest).\n"
                                                            "- Download expense details in PDF and Excel formats.\n"
                                                            "- Set PIN for security purposes.\n\n"
                                                            "Admin Section Features:\n"
                                                            "- Assign ${loadController.siteLable.value}.\n"
                                                            "- View and manage expenses.\n\n"
                                                            "${loadController.siteLable.value} Features:\n"
                                                            "- Change password.\n"
                                                            "- View expenses list (Approved or Rejected by Admin).\n"
                                                            "- Set PIN for security purposes.",
                                                            // ignore: deprecated_member_use
                                                            textScaleFactor: 1.4,
                                                            style: TextStyle(
                                                              color: Colors.grey.shade700,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      height: 25,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 15),
                                                      child: Align(
                                                        alignment: Alignment.bottomRight,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                            elevation: MaterialStateProperty.all(2.5),
                                                            backgroundColor: MaterialStateProperty.all(themecolor),
                                                            overlayColor: MaterialStateProperty.all(Colors.grey),
                                                            foregroundColor: MaterialStateProperty.all(Colors.white),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Close"),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );*/
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AboutUsPage(),
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
                              Icons.star,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: Text(
                              "Rate Us",
                              // ignore: deprecated_member_use
                              // textScaleFactor: 1.2,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("Rate this application."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () async {
                              // LaunchReview.launch(androidAppId: "com.example.gym_app");
                              // launch("https://www.playstore.com");
                              // launch("https://play.google.com/store/apps/details?id=" + "com.example.gym_app");
                              // ignore: deprecated_member_use
                              await launch("https://play.google.com/store/apps/details?id=gnhub.expense.tracker");
                              Fluttertoast.showToast(msg: "Thank You For Rating Us\nOpening Play Store");
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
                              CupertinoIcons.question_circle_fill,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: Text(
                              "Contact Us",
                              // ignore: deprecated_member_use
                              // textScaleFactor: 1.2,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("Communication details."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25, right: 15),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Contact Us",
                                                    // ignore: deprecated_member_use
                                                    textScaleFactor: 1.4,
                                                    style: TextStyle(color: themecolor, fontWeight: FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                      splashRadius: 25,
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(
                                                        Icons.cancel,
                                                        color: themecolor,
                                                        size: 30,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 15, left: 20),
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(
                                                  "Personal Expense Tracker",
                                                  // ignore: deprecated_member_use
                                                  textScaleFactor: 1.5,
                                                  textAlign: TextAlign.start,
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Divider(thickness: 0.5, indent: 20, endIndent: 20),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 20, right: 20),
                                              child: Text(
                                                "We are thanking you for using our App.",
                                                // ignore: deprecated_member_use
                                                textScaleFactor: 1.5,
                                                style:
                                                    TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                                              child: Text(
                                                "Write us on Generation Next",
                                                // ignore: deprecated_member_use
                                                textScaleFactor: 1.5,
                                                style:
                                                    TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                                              child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    // ignore: deprecated_member_use
                                                    launch("https://gnhub.com/contact.aspx");
                                                  },
                                                  child: Text(
                                                    "info@gnhub.com",
                                                    // ignore: deprecated_member_use
                                                    textScaleFactor: 1.5,
                                                    style: TextStyle(
                                                        color: Colors.blueAccent,
                                                        decoration: TextDecoration.underline,
                                                        fontWeight: FontWeight.w500),
                                                  )),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                                              child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    // ignore: deprecated_member_use
                                                    launch("https://www.gnhub.com/");
                                                  },
                                                  child: Text(
                                                    "https://www.gnhub.com/",
                                                    // ignore: deprecated_member_use
                                                    textScaleFactor: 1.5,
                                                    style: TextStyle(
                                                        color: Colors.blueAccent,
                                                        decoration: TextDecoration.underline,
                                                        fontWeight: FontWeight.w500),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                              Icons.share_rounded,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: Text(
                              "Share",
                              // ignore: deprecated_member_use
                              // textScaleFactor: 1.2,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("Share this application."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () async {
                              String storeLink = 'https://play.google.com/store/apps/details?id=gnhub.expense.tracker';

                              // try {
                              //   DocumentSnapshot docSnapshot =
                              //       await FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).get();
                              //   if (docSnapshot.exists) {
                              //     String referralCode = docSnapshot.get('referralCode');
                              //     String shareableLink = '$storeLink&referral=$referralCode';
                              //     await Share.share(shareableLink);
                              //   } else {
                              //     throw Exception("Admin details not found");
                              //   }
                              // } catch (e) {
                              //   print("Error sharing link: $e");
                              // }

                              await Share.share(storeLink);
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
                              Icons.logout,
                              // ignore: deprecated_member_use
                              color: themecolor.withOpacity(0.65),
                            ),
                            title: const Text('Logout',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Sign out from this account."),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                            ),
                            onTap: () {
                              // Navigator.of(context).pop();
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
                                        style: const ButtonStyle(
                                            // ignore: deprecated_member_use
                                            backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
                                        onPressed: () async {
                                          try {
                                            // Sign out the user
                                            SharedPref.deleteAll();
                                            await FirebaseAuth.instance.signOut();
                                            // Navigate to the login page
                                            // ignore: use_build_context_synchronously
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => RootApp()),
                                              (Route<dynamic> route) => false, // Prevent going back to this screen
                                            );

                                            // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
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
                        ),
                        /*Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                "Account Deletion"
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),*/
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.grey, Colors.grey],
                                      // stops: [0.0, 0.5, 1.0], // Center strong, edges fade out
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Account Deletion",
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  height: 1.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [Colors.grey, Colors.grey, Colors.transparent],
                                      // stops: [0.0, 0.5, 1.0], // Center strong, edges fade out
                                    ),
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
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tileColor: Colors.white,
                            leading: Icon(
                              Icons.account_circle_outlined,
                              // ignore: deprecated_member_use
                              color: Colors.red,
                            ),
                            title: const Text('Delete Account',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                )),
                            subtitle: Text("Delete this account permanently."),
                            trailing: Obx(() => (loadController.deleteLoader.isTrue)
                                ? SizedBox(
                                    width: 24, // Fixed width for proper alignment
                                    height: 24, // Fixed height for proper alignment
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5, // Reduce thickness for better UI
                                      valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                                    ),
                                  )
                                : SizedBox.shrink()),
                            onTap: () {
                              // Navigator.of(context).pop();
                              /*showDialog(
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
                                        style: const ButtonStyle(
                                          // ignore: deprecated_member_use
                                            backgroundColor: MaterialStatePropertyAll(Colors.transparent)),
                                        onPressed: () async {
                                          try {
                                            // Sign out the user
                                            SharedPref.deleteAll();
                                            await FirebaseAuth.instance.signOut();
                                            // Navigate to the login page
                                            // ignore: use_build_context_synchronously
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => RootApp()),
                                                  (Route<dynamic> route) => false, // Prevent going back to this screen
                                            );

                                            // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
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
                              );*/
                              showDeleteAdminDialog(
                                  context, widget.adminId, SharedPref.get(prefKey: PrefKey.adminEmail) ?? "");
                              // showDeleteConfirmationDialog(
                              //     context, widget.adminId, SharedPref.get(prefKey: PrefKey.adminEmail) ?? "");
                            },
                          ),
                        ),
                        /*Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Backup Cash Book !!!"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '''
                                            Follow the steps

                                            Cashbook Local Backup
                                            1. Click on 'Backup' Button.
                                            2. Select/Create the specific folder on local storage to backup. (older one is 'cashbook_backup' or create a new one)
                                            3. Keep the file name 'Clients.csv' and 'Transactions.csv' in the same folder.
                                            4. That's it. Backup Done.
                                            ''',
                                          style:
                                              TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // EasyLoading.show(status: "Loading.");
                                          // AppDatabaseHelper().exportClientsToCsv();
                                          // EasyLoading.dismiss();
                                        },
                                        child: const Text("Backup"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xaaffffcd),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Color(0xffffecb5), width: 1)),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: RichText(
                                  text: TextSpan(
                                      text: "Note: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500, color: Color(0xff664d03), fontSize: 12),
                                      children: [
                                    TextSpan(
                                        text:
                                            "Kindly create a daily data backup routine to ensure the safety and integrity of your accounts.",
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xff664d03))),
                                    TextSpan(text: " Backup Now »"),
                                  ])),
                            ),
                          ),
                        ),*/
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ],
                ),
                Obx(() => (loadController.loadAdminSwitch.isTrue)
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
                    : SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteAdminDialog(BuildContext context, String adminId, String adminEmail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('⚠️ Delete Account'),
          content: Text(
            "Warning! Deleting this admin will remove all expense data and all employees associated with this admin. "
            "This action is irreversible.\n\nAre you absolutely sure you want to proceed?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                // Show second confirmation
                Navigator.pop(context);
                showDeleteConfirmationDialog(context, adminId, adminEmail);
              },
              child: Text('Proceed', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String adminId, String adminEmail) {
    dialogController.clear();

    bool isLoading = false;
    bool showRow = true;
    final FocusNode dialogFocusNode = FocusNode();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            title: Container(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(27), topRight: Radius.circular(27)),
                // ignore: deprecated_member_use
                color: Colors.red.withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Delete this Account?',
                    // ignore: deprecated_member_use
                    textScaleFactor: 0.8,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Tooltip(
                      message: "Close",
                      child: Icon(
                        Icons.cancel,
                        color: themecolor,
                        size: 30,
                      ),
                    ),
                  )
                ],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: Text(
                    "Doing so will permanently delete all associated data.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black, // Default text color
                                ),
                                children: [
                                  TextSpan(
                                    text: "Confirm that you want to delete this Account by typing: ",
                                    style: TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  TextSpan(
                                    text: "DELETE",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: formKey,
                        child: TextFormField(
                          controller: dialogController,
                          focusNode: dialogFocusNode,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              showRow = value.isEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            // border: OutlineInputBorder(),
                            hintText: "Type \"DELETE\"",
                            // labelText: "",
                            labelStyle:
                                // ignore: deprecated_member_use
                                TextStyle(color: dialogFocusNode.hasFocus ? themecolor : Colors.grey.withOpacity(0.95)),
                            // ignore: deprecated_member_use
                            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.95)),
                            errorText: (dialogController.text.isNotEmpty &&
                                    dialogController.text != "DELETE" &&
                                    dialogController.text != dialogController.text.toUpperCase())
                                ? "Block letters required"
                                : null,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: dialogFocusNode.hasFocus ? themecolor : Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: dialogFocusNode.hasFocus ? themecolor : Colors.black, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: dialogFocusNode.hasFocus ? themecolor : Colors.black),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 0),
                      showRow == true
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.info,
                                      color: Colors.red,
                                      size: 15,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Required",
                                      style: TextStyle(color: Colors.red),
                                    )
                                  ],
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.black)),
                style: ButtonStyle(
                    // ignore: deprecated_member_use
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    // ignore: deprecated_member_use
                    backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                    // ignore: deprecated_member_use
                    foregroundColor: MaterialStatePropertyAll(Colors.transparent)),
              ),
              TextButton(
                onPressed: isLoading == true
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          showRow = false;
                          if (dialogController.text == "DELETE") {
                            setState(() => isLoading = true);
                            // Simulate verification delay (2 seconds)
                            Future.delayed(Duration(seconds: 2), () {
                              // After verification, close dialog and show final confirmation
                              Navigator.pop(context);
                              showSecondConfirmation(context, adminId, adminEmail);
                            });
                          } else {
                            // setState(() {}); // Refresh UI to show validation error
                          }
                        } else {
                          showRow = true;
                        }
                      },
                style: ButtonStyle(
                  // ignore: deprecated_member_use
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  // ignore: deprecated_member_use
                  backgroundColor: MaterialStatePropertyAll(
                    (dialogController.text.isNotEmpty && dialogController.text == "DELETE")
                        // ignore: deprecated_member_use
                        ? Colors.red.withOpacity(0.10)
                        // ignore: deprecated_member_use
                        : Colors.grey.withOpacity(0.25),
                  ),
                  // ignore: deprecated_member_use
                  foregroundColor: MaterialStatePropertyAll(
                    (dialogController.text.isNotEmpty && dialogController.text == "DELETE") ? Colors.red : Colors.white,
                  ),
                ),
                child: isLoading == true
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Delete',
                        style: TextStyle(
                            // color: Colors.red,
                            fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  void showSecondConfirmation(BuildContext context, String adminId, String adminEmail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('🚨 Final Confirmation'),
          content: Text(
            "This is your last chance!\n\nDeleting this Account will PERMANENTLY erase all associated expenses, users, and data. "
            "This action cannot be undone.\n\nAre you sure you want to continue?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No, Keep this Account', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteAdmin(adminId, adminEmail); // Call delete function
              },
              child: Text('Yes, Confirm Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAdmin(String adminId, String adminEmail) async {
    loadController.deleteLoader.value = true;
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      print(user);
      // Step 1: Delete all Users under this Admin
      QuerySnapshot userSnapshot = await firestore.collection('Users').where('adminId', isEqualTo: adminId).get();
      for (var doc in userSnapshot.docs) {
        await firestore.collection('Users').doc(doc.id).delete();
      }
      print("✅ All users linked to this admin deleted.");

      // Step 2: Delete the Admin from Firestore
      await firestore.collection('Admin').doc(adminId).delete();
      print("✅ Admin deleted from Firestore.");

      // Step 3: Check if admin exists in Firebase Authentication
      deleteAdminAccount();
      /*user?.delete();

      // Step 4: Clear SharedPreferences and Navigate
      SharedPref.deleteAll();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RootApp()),
            (Route<dynamic> route) => false, // Prevent going back
      );

      print("🔥 Admin and all related data deleted successfully.");
      Fluttertoast.showToast(msg: "🔥 Admin and all related data deleted successfully.");*/
    } catch (e) {
      print("❌ Error deleting admin: $e");
    } finally {
      loadController.deleteLoader.value = false;
    }
  }

  Future<void> deleteAdminAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        // Fluttertoast.showToast(msg: "Account deleted successfully!");
        // Step 4: Clear SharedPreferences and Navigate
        SharedPref.deleteAll();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => RootApp()),
          (Route<dynamic> route) => false, // Prevent going back
        );
        print("🔥 Admin and all related data deleted successfully.");
        Fluttertoast.showToast(msg: "🔥 Admin and all related data deleted successfully.");
      } else {
        Fluttertoast.showToast(msg: "Error: User not found!");
        return; // Stop execution if the user is null
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete account: $e");
      return; // Stop execution if deletion fails
    }
  }

  /*Future<void> deleteAdmin(String adminId, String adminEmail) async {
    loadController.deleteLoader.value = true;
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      print(user);
      // Step 1: Delete all Users under this Admin
      QuerySnapshot userSnapshot = await firestore.collection('Users').where('adminId', isEqualTo: adminId).get();
      for (var doc in userSnapshot.docs) {
        await firestore.collection('Users').doc(doc.id).delete();
      }
      print("✅ All users linked to this admin deleted.");

      // Step 2: Delete the Admin from Firestore
      await firestore.collection('Admin').doc(adminId).delete();
      print("✅ Admin deleted from Firestore.");

      // Step 3: Check if admin exists in Firebase Authentication
      user?.delete();

      // Step 4: Clear SharedPreferences and Navigate
      SharedPref.deleteAll();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RootApp()),
            (Route<dynamic> route) => false, // Prevent going back
      );

      print("🔥 Admin and all related data deleted successfully.");
      Fluttertoast.showToast(msg: "🔥 Admin and all related data deleted successfully.");
    } catch (e) {
      print("❌ Error deleting admin: $e");
    } finally {
      loadController.deleteLoader.value = false;
    }
  }*/
}
