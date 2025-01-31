import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/screens/employee_section/setup_pin/set_pin.dart';
import 'package:etmm/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../const/const.dart';
import '../../../getx_controller/load_excel_controller.dart';
import '../../root_app.dart';
import '../authentication/change_password_emp.dart';
import 'edit_Profile_employee.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userDoc;
  final bool fromAdmin;
  const EmployeeProfileScreen({super.key, required this.userId, required this.userDoc, this.fromAdmin = false});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late DocumentSnapshot updatedUserDoc;

  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());
  EmployeeProfileController controller = Get.put(EmployeeProfileController());

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

  @override
  void initState() {
    // setState(() {
    //   isDateSelected = (SharedPref.get(prefKey: PrefKey.defaultDatePickAdmin) == null ||
    //           SharedPref.get(prefKey: PrefKey.defaultDatePickAdmin) == '1')
    //       ? true
    //       : false;
    // });
    updatedUserDoc = widget.userDoc;
    // controller.finalImageUrl.value = updatedUserDoc['employee_logo'];
    loadEmployeeCompanyLogo(widget.userId);
    super.initState();
  }

  Future<void> loadEmployeeCompanyLogo(String userId) async {
    await loadController.updateEmployeePinStatusFromFirestore(widget.userId);
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (adminDoc.exists && adminDoc.data() != null) {
        String logoUrl = adminDoc['employee_logo'] ?? '';
        controller.finalImageUrl.value = logoUrl.isNotEmpty ? logoUrl : '';
      }
    } catch (e) {
      print("Error fetching employee logo: $e");
    }
  }

  void _refreshProfileData() async {
    final updatedDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();

    setState(() {
      updatedUserDoc = updatedDoc;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadController.updateEmployeePinStatusFromFirestore(widget.userId);
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
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Stack(
              children: [
                Column(
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /*GestureDetector(
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
                                              Icons.person_outlined,
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
                                    Icons.person_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),*/
                              /* Old Updated to New
                              (updatedUserDoc['employee_logo'] != null && updatedUserDoc['employee_logo'] != "")
                                  ?
                                  // CircleAvatar(
                                  //         radius: 30,
                                  //         foregroundImage: NetworkImage(updatedUserDoc['employee_logo'] ?? ""),
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
                                  //                             image: NetworkImage(updatedUserDoc['employee_logo'] ?? ""),
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
                                                        image: NetworkImage(updatedUserDoc['employee_logo'] ?? ""),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child:
                                            updatedUserDoc['employee_logo'] != null && updatedUserDoc['employee_logo'] != ""
                                                ? Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: ClipOval(
                                                      clipBehavior: Clip.hardEdge,
                                                      child: Image.network(
                                                        updatedUserDoc['employee_logo'] ?? "",
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
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Obx(
                                () => Text(
                                  '${loadController.siteLable.value /*.split(' ')[0]*/} Panel',
                                  // textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          // const SizedBox(height: 10),
                          Text(
                            updatedUserDoc['username'], // Assuming 'username' field exists in userDoc
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                height: 1.21,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
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
                                  onTap: () async {
                                    final updatedData = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmployeeEditProfilePage(userId: widget.userId),
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
                                  onTap: () {
                                    // Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmployeeChangePassword(userId: widget.userId),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              widget.fromAdmin == true
                                  ? SizedBox()
                                  : Card(
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
                                          value: loadController.isEmployeePinEnabled.value,
                                          onChanged: (value) async {
                                            try {
                                              if (!value) {
                                                // When the switch is turned OFF (Disable PIN)
                                                await FirebaseFirestore.instance
                                                    .collection('Users')
                                                    .doc(widget.userId)
                                                    .update({'isSwitchOn': false, 'pin': ''}); // Update Firestore
                                                // setState(() {
                                                loadController.isEmployeePinEnabled.value = false;
                                                // });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("PIN disabled successfully.")),
                                                );
                                              } else {
                                                // When the switch is turned ON (Enable PIN)
                                                bool isSwitchOn = await loadController
                                                    .getEmployeeSavedPinFromFirestore(widget.userId);
                                                if (isSwitchOn) {
                                                  // If already enabled in Firestore
                                                  // setState(() {
                                                  loadController.isEmployeePinEnabled.value = true;
                                                  // });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("PIN is already enabled.")),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => EmployeeSetPin(
                                                              userId: widget.userId,
                                                              userDoc: widget.userDoc,
                                                            )),
                                                  ).then((result) async {
                                                    final userDoc = await FirebaseFirestore.instance
                                                        .collection('Users')
                                                        .doc(widget.userId)
                                                        .get();
                                                    // setState(() {
                                                    loadController.isEmployeePinEnabled.value =
                                                        userDoc['isSwitchOn'] ?? false;
                                                    // });
                                                    await loadController
                                                        .updateEmployeePinStatusFromFirestore(widget.userId);
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
                              /* Old Card
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
                                            builder: (context) => EmployeeSetPin(
                                                  userId: widget.userId,
                                                  userDoc: widget.userDoc,
                                                )),
                                      );
                                      // }
                                    },
                                  ),
                                ),
                          */
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
                              widget.fromAdmin == true
                                  ? SizedBox()
                                  : Card(
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
                              widget.fromAdmin == true
                                  ? SizedBox()
                                  : Card(
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
                                                          (Route<dynamic> route) =>
                                                              false, // Prevent going back to this screen
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
                            ],
                          ),
                        ),
                        widget.fromAdmin == true
                            ? SizedBox()
                            : Column(children: [
                                SizedBox(
                                  height: 25,
                                ),
                                Card(
                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  elevation: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // color: Colors.purple,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: themecolor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(6, 5), // Shadow position
                                        ),
                                      ],
                                    ),
                                    child: ProfileCard(),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Card(
                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  elevation: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // color: Colors.purple,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: themecolor.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(6, 5), // Shadow position
                                        ),
                                      ],
                                    ),
                                    child: ProfileCard2(),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Card(
                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  elevation: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // color: Colors.purple,
                                      borderRadius: BorderRadius.circular(20),
                                      // border: Border.all(color: Color(0xffffecb5), width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: Color(0xaaffffcd).withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(6, 5), // Shadow position
                                        ),
                                      ],
                                    ),
                                    child: ProfileCard3(),
                                  ),
                                ),
                              ]),
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
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
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ],
                ),
                Obx(() => loadController.loadEmployeeSwitch.isTrue
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment.center,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                          ),
                        ),
                      )
                    : SizedBox.shrink()),
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
}

//ignore: must_be_immutable
class ProfileCard extends StatelessWidget {
  LoadAllFieldsController controller = Get.put(LoadAllFieldsController());

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // colors: [Color(0xFFAB47BC), Color(0xFF7E57C2)],
          colors: [
            Color(0xFF7E57C2),
            // ignore: deprecated_member_use
            themecolor.withOpacity(0.75),
            Color(0xFF7E57C2),
            Color(0xFF7E57C2),
            // ignore: deprecated_member_use
            themecolor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              // CircleAvatar(
              //   radius: 30,
              //   backgroundImage: NetworkImage(
              //       controller.companyLogo.value
              //       ),
              // ),
              Container(
                height: 105,
                width: 100,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // image: DecorationImage(
                  //   image: NetworkImage(
                  //     controller.companyLogo.value,
                  //   ),fit: BoxFit.cover,
                  // )
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Obx(() => (controller.companyLogo.value != "")
                      ? GestureDetector(
                          onTap: () async {
                            double screenHeight = MediaQuery.of(context).size.height;
                            double targetHeight = screenHeight * 0.75;
                            await showDialog(
                              context: context,
                              builder: (_) => Center(
                                child: Container(
                                  height: targetHeight,
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 25),
                                  // color: Color(0xffeeeeee),
                                  color: Colors.transparent,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: PhotoViewGallery.builder(
                                        itemCount: 1,
                                        builder: (context, index) {
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider: NetworkImage(controller.companyLogo.value),
                                            minScale: PhotoViewComputedScale.contained * 1,
                                            maxScale: PhotoViewComputedScale.covered * 2,
                                          );
                                        },
                                        scrollPhysics: BouncingScrollPhysics(),
                                        backgroundDecoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        pageController: PageController(),
                                        loadingBuilder: (context, progress) {
                                          if (progress == null) {
                                            return SizedBox.shrink();
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: progress.expectedTotalBytes != null
                                                    ? progress.cumulativeBytesLoaded /
                                                        (progress.expectedTotalBytes ?? 1)
                                                    : null,
                                                color: Colors.white, // Set the color to white
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            controller.companyLogo.value,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                                    color: Colors.white,
                                  ),
                                );
                              }
                            },
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 0.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                Text(
                                  "No Photo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ],
                            ),
                            /*Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.5),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text("No Photo",textAlign: TextAlign.center,style: TextStyle(
                              fontWeight: FontWeight.w600,color: Colors.white
                            ),)),
                      ),
                    ],
                  ),*/
                          ),
                        )),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        controller.companyName.value,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        launchEmail(controller.email.value);
                      },
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          controller.email.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Owner :",
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "${controller.username.value}",
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        // ignore: deprecated_member_use
                        launch("tel:${controller.phone.value}");
                      },
                      child: Row(
                        children: [
                          Text(
                            "Contact :",
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "${controller.phone.value}",
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Address :",
                          style: GoogleFonts.poppins(
                            // fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 120,
                          child: Text(
                            "${controller.companyAddress.value}",
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget infoText(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

//ignore: must_be_immutable
class ProfileCard2 extends StatelessWidget {
  LoadAllFieldsController controller = Get.put(LoadAllFieldsController());

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // colors: [Color(0xFFAB47BC), Color(0xFF7E57C2)],
          colors: [
            // Color(0xFF7E57C2),
            // ignore: deprecated_member_use
            themecolor.withOpacity(0.75),
            // Color(0xFF7E57C2),
            // Color(0xFF7E57C2),
            // ignore: deprecated_member_use
            themecolor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              // CircleAvatar(
              //   radius: 30,
              //   backgroundImage: NetworkImage(
              //       controller.companyLogo.value
              //       ),
              // ),
              Container(
                height: 105,
                width: 100,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // image: DecorationImage(
                  //   image: NetworkImage(
                  //     controller.companyLogo.value,
                  //   ),fit: BoxFit.cover,
                  // )
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Obx(() => (controller.companyLogo.value != "")
                      ? GestureDetector(
                          onTap: () async {
                            double screenHeight = MediaQuery.of(context).size.height;
                            double targetHeight = screenHeight * 0.75;
                            await showDialog(
                              context: context,
                              builder: (_) => Center(
                                child: Container(
                                  height: targetHeight,
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 25),
                                  // color: Color(0xffeeeeee),
                                  color: Colors.transparent,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: PhotoViewGallery.builder(
                                        itemCount: 1,
                                        builder: (context, index) {
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider: NetworkImage(controller.companyLogo.value),
                                            minScale: PhotoViewComputedScale.contained * 1,
                                            maxScale: PhotoViewComputedScale.covered * 2,
                                          );
                                        },
                                        scrollPhysics: BouncingScrollPhysics(),
                                        backgroundDecoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        pageController: PageController(),
                                        loadingBuilder: (context, progress) {
                                          if (progress == null) {
                                            return SizedBox.shrink();
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: progress.expectedTotalBytes != null
                                                    ? progress.cumulativeBytesLoaded /
                                                        (progress.expectedTotalBytes ?? 1)
                                                    : null,
                                                color: Colors.white, // Set the color to white
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            controller.companyLogo.value,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                                    color: Colors.white,
                                  ),
                                );
                              }
                            },
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 0.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                Text(
                                  "No Photo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ],
                            ),
                            /*Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.5),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text("No Photo",textAlign: TextAlign.center,style: TextStyle(
                              fontWeight: FontWeight.w600,color: Colors.white
                            ),)),
                      ),
                    ],
                  ),*/
                          ),
                        )),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        controller.companyName.value,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        launchEmail(controller.email.value);
                      },
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          controller.email.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Owner :",
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 120,
                          child: Text(
                            "${controller.username.value}",
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        // ignore: deprecated_member_use
                        launch("tel:${controller.phone.value}");
                      },
                      child: Row(
                        children: [
                          Text(
                            "Contact :",
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 120,
                            child: Text(
                              "${controller.phone.value}",
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                // fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Address :",
                          style: GoogleFonts.poppins(
                            // fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 120,
                          child: Text(
                            "${controller.companyAddress.value}",
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget infoText(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

//ignore: must_be_immutable
class ProfileCard3 extends StatelessWidget {
  LoadAllFieldsController controller = Get.put(LoadAllFieldsController());

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // colors: [Color(0xFFAB47BC), Color(0xFF7E57C2)],
          colors: [
            // Color(0xFF7E57C2),
            // ignore: deprecated_member_use
            Color(0xaaffffcd).withOpacity(0.75),
            // Color(0xFF7E57C2),
            // Color(0xFF7E57C2),
            // ignore: deprecated_member_use
            Color(0xaaffffcd).withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xffffecb5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              // CircleAvatar(
              //   radius: 30,
              //   backgroundImage: NetworkImage(
              //       controller.companyLogo.value
              //       ),
              // ),
              Container(
                height: 105,
                width: 100,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // image: DecorationImage(
                  //   image: NetworkImage(
                  //     controller.companyLogo.value,
                  //   ),fit: BoxFit.cover,
                  // )
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Obx(() => (controller.companyLogo.value != "")
                      ? GestureDetector(
                          onTap: () async {
                            double screenHeight = MediaQuery.of(context).size.height;
                            double targetHeight = screenHeight * 0.75;
                            await showDialog(
                              context: context,
                              builder: (_) => Center(
                                child: Container(
                                  height: targetHeight,
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 25),
                                  // color: Color(0xffeeeeee),
                                  color: Colors.transparent,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: PhotoViewGallery.builder(
                                        itemCount: 1,
                                        builder: (context, index) {
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider: NetworkImage(controller.companyLogo.value),
                                            minScale: PhotoViewComputedScale.contained * 1,
                                            maxScale: PhotoViewComputedScale.covered * 2,
                                          );
                                        },
                                        scrollPhysics: BouncingScrollPhysics(),
                                        backgroundDecoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        pageController: PageController(),
                                        loadingBuilder: (context, progress) {
                                          if (progress == null) {
                                            return SizedBox.shrink();
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: progress.expectedTotalBytes != null
                                                    ? progress.cumulativeBytesLoaded /
                                                        (progress.expectedTotalBytes ?? 1)
                                                    : null,
                                                color: Colors.white, // Set the color to white
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            controller.companyLogo.value,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                                    color: Colors.white,
                                  ),
                                );
                              }
                            },
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent,
                              border: Border.all(color: Color(0xff664d03), width: 0.75),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Color(0xff664d03),
                                  size: 60,
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                Text(
                                  "No Photo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff664d03)),
                                ),
                              ],
                            ),
                            /*Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.5),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text("No Photo",textAlign: TextAlign.center,style: TextStyle(
                              fontWeight: FontWeight.w600,color: Colors.white
                            ),)),
                      ),
                    ],
                  ),*/
                          ),
                        )),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        controller.companyName.value,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff664d03),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        launchEmail(controller.email.value);
                      },
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          controller.email.value,
                          // ignore: deprecated_member_use
                          textScaleFactor: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color(0xff664d03),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Owner :",
                            // ignore: deprecated_member_use
                            textScaleFactor: 1,
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff664d03),
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 120,
                          child: Text(
                            "${controller.username.value}",
                            // ignore: deprecated_member_use
                            textScaleFactor: 1,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff664d03),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        // ignore: deprecated_member_use
                        launch("tel:${controller.phone.value}");
                      },
                      child: Row(
                        children: [
                          Text(
                            "Contact :",
                            // ignore: deprecated_member_use
                            textScaleFactor: 1,
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff664d03),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 120,
                            child: Text(
                              "${controller.phone.value}",
                              // ignore: deprecated_member_use
                              textScaleFactor: 1,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                // fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff664d03),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Address :",
                          // ignore: deprecated_member_use
                          textScaleFactor: 1,
                          style: GoogleFonts.poppins(
                            // fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff664d03),
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: 120,
                          child: Text(
                            "${controller.companyAddress.value}",
                            // ignore: deprecated_member_use
                            textScaleFactor: 1,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff664d03),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget infoText(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class CustomCard extends StatelessWidget {
  const CustomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with curve
        CustomPaint(
          painter: CurvedCardPainter(),
          child: Container(
            width: 350,
            height: 130,
          ),
        ),

        // Card Content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/300', // Dummy Image
                  ),
                ),
                const SizedBox(width: 15),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Bold",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Title: Illustration of little girl",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          InfoColumn(title: "2342", subtitle: "Popularity"),
                          SizedBox(width: 15),
                          InfoColumn(title: "4736", subtitle: "Like"),
                          SizedBox(width: 15),
                          InfoColumn(title: "136", subtitle: "Followed"),
                        ],
                      )
                    ],
                  ),
                ),

                // Ranking Number
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "4",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Ranking",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Info Column Widget
class InfoColumn extends StatelessWidget {
  final String title;
  final String subtitle;

  const InfoColumn({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

// CustomPainter for the Curved Design
class CurvedCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(20)))
      ..moveTo(size.width * 0.75, 0)
      ..arcToPoint(
        Offset(size.width, size.height * 0.5),
        radius: const Radius.circular(80),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(size.width * 0.75, size.height),
        radius: const Radius.circular(80),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
