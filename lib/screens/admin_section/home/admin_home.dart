import 'dart:async';
import 'dart:io';
import 'package:etmm/const/const.dart';
import 'package:etmm/widget/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AdminHomeScreen extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userDoc;
  final String adminId;
  const AdminHomeScreen({Key? key, required this.userId, required this.userDoc, required this.adminId})
      : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String selectedTitle = '';
  String selectedMonth = 'All';
  List<String> months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final TextEditingController titleController = TextEditingController();

  String getFullMonthName(String monthAbbreviation) {
    switch (monthAbbreviation) {
      case 'All':
        return 'All';
      case 'January':
        return 'January';
      case 'February':
        return 'February';
      case 'March':
        return 'March';
      case 'April':
        return 'April';
      case 'May':
        return 'May';
      case 'June':
        return 'June';
      case 'July':
        return 'July';
      case 'August':
        return 'August';
      case 'September':
        return 'September';
      case 'October':
        return 'October';
      case 'November':
        return 'November';
      case 'December':
        return 'December';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _subscribeToFirestore();
    // Initialize selectedMonth to the current month
    DateTime now = DateTime.now();
    selectedMonth = months[now.month]; // Adjusting for 1-based index of months list
  }

  @override
  void dispose() {
    titleController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  // String filterSelectedMonth = 'All';

  StreamSubscription<QuerySnapshot>? _subscription;

  void _subscribeToFirestore() {
    _subscription = FirebaseFirestore.instance
        .collection('Admin')
        .doc(widget.userId)
        .collection('expense')
        .snapshots()
        .listen((snapshot) {
      // Handle snapshot updates here
    });
  }

  // Future<DocumentSnapshot> _fetchData() async {
  //   return await FirebaseFirestore.instance
  //       .collection('Admin')
  //       .doc(widget.userId)
  //       .collection('expense')
  //       .doc('documentId')
  //       .get();
  // }

  // bool _lightsOn = false;

  Future<bool> onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App Confirmation'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false; // Return false if the dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    String selectedMonthText = getFullMonthName(selectedMonth);

    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          // SystemNavigator.pop();
          // return Future.value(false);
          return onWillPop(context);
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: themecolor,
            title: Text(
              'Dashboard ${selectedMonthText.isNotEmpty && selectedMonthText != 'All' ? "- $selectedMonthText" : ""}',
              style: TextStyle(fontWeight: FontWeight.bold, color: kwhite),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list, color: kwhite),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CommonFilterDialog(
                        initialTitle: selectedTitle,
                        initialMonth: selectedMonth,
                        onTitleChanged: (value) {
                          setState(() {
                            selectedTitle = value;
                          });
                        },
                        onMonthChanged: (value) {
                          setState(() {
                            selectedMonth = value;
                          });
                          // setState(() {
                          //   filterSelectedMonth = value;
                          // });
                        },
                      );
                    },
                  );
                },
              ),
            ],
            iconTheme: IconThemeData(color: kwhite),
          ),
          /*drawer: Drawer(
            backgroundColor: kwhite,
            child: Column(
              // physics: NeverScrollableScrollPhysics(),
              // padding: EdgeInsets.zero,
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
                          CircleAvatar(
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
                          SizedBox(
                            width: 15,
                          ),
                          const Text(
                            'Admin Panel',
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // const SizedBox(height: 10),
                      Text(
                        widget.userDoc['username'], // Assuming 'username' field exists in userDoc
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        widget.userDoc['email'], // Assuming 'email' field exists in userDoc
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          height: 1.21,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.home,
                          color: Colors.grey,
                        ),
                        title: const Text('Home',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            )),
                        onTap: () {
                          Navigator.of(context).pop();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => AdminHome(
                          //       userId: widget.adminId,
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: Colors.grey,
                        ),
                        title: const Text('Edit Profile',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            )),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminEditProfilePage(adminId: widget.adminId),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        title: const Text('Employee List',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            )),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateEmployeeDialog(adminId: widget.adminId),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                        title: const Text('Change Password',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            )),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminChangePassword(userDoc: widget.userDoc),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.view_list,
                          color: Colors.grey,
                        ),
                        title: const Text('Expense List',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            )),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminExpensePage(
                                userDoc: widget.userDoc,
                                adminId: widget.adminId,
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
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
                                      userDoc: widget.userDoc,
                                      adminId: widget.adminId,
                                    )),
                          );
                          // }
                        },
                      ),
                      /*ListTile(
                        leading: Icon(
                          CupertinoIcons.doc_text_fill,
                          color: Colors.grey,
                        ),
                        title: Text(
                          "About Us",
                          // ignore: deprecated_member_use
                          textScaleFactor: 1.2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        onTap: () {
                          /*Dialog(
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
                                padding: const EdgeInsets.only(top: 15, left: 15),
                                child: Text(
                                  "About App",
                                  // ignore: deprecated_member_use
                                  textScaleFactor: 1.7,
                                  style: TextStyle(color: themecolor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                                child: Text(
                                  "Gym management provides following features :\n- Manage packages\n- Manage members\n- Filter members package wise\n- Showing Time, received, due fees amount\n- Add, Edit, Delete Member's Fees history\n- Members Fees history\n- Company Data settings\n- Backup\n- Simple design and navigation",
                                  // ignore: deprecated_member_use
                                  textScaleFactor: 1.4,
                                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                ),
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
                                      child: Text(
                                        "Close",
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );*/
                          showDialog(
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
                                        padding: const EdgeInsets.only(top: 15, left: 15),
                                        child: Text(
                                          "About App",
                                          // ignore: deprecated_member_use
                                          textScaleFactor: 1.7,
                                          style: TextStyle(color: themecolor, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                                        child: Text(
                                          "Gym management provides the following features :\n- Manage packages\n- Manage members\n- Filter members package wise\n- Showing Time, received, due fees amount\n- Add, Edit, Delete Member's Fees history\n- Members Fees history\n- Company Data settings\n- Backup\n- Simple design and navigation",
                                          // ignore: deprecated_member_use
                                          textScaleFactor: 1.4,
                                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                        ),
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
                                              child: Text(
                                                "Close",
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),*/
                      ListTile(
                        leading: Icon(
                          CupertinoIcons.doc_text_fill,
                          color: Colors.grey,
                        ),
                        title: Text(
                          "About Us",
                          // ignore: deprecated_member_use
                          // textScaleFactor: 1.2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
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
                                                  child: Text(
                                                    "Expense Tracker provides the following features:\n"
                                                    "- Admin and Employee expenses tracking with real-time date & time.\n"
                                                    "- Storing bill photos inside each expense.\n"
                                                    "- Edit admin profile.\n"
                                                    "- Manage employee list.\n"
                                                    "- Change admin password.\n"
                                                    "- View expense list.\n"
                                                    "- Filter expenses by date & time.\n"
                                                    "- Filter expenses by Title, Amount (high to low, low to high), Date (newest to oldest, oldest to newest).\n"
                                                    "- Download expense details in PDF and Excel formats.\n"
                                                    "- Set PIN for security purposes.\n\n"
                                                    "Admin Section Features:\n"
                                                    "- Assign employees.\n"
                                                    "- View and manage expenses.\n\n"
                                                    "Employee Section Features:\n"
                                                    "- Change password.\n"
                                                    "- View expenses list (Approved or Rejected by Admin).\n"
                                                    "- Set PIN for security purposes.",
                                                    // ignore: deprecated_member_use
                                                    textScaleFactor: 1.4,
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
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
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.star,
                          color: Colors.grey,
                        ),
                        title: Text(
                          "Rate Us",
                          // ignore: deprecated_member_use
                          // textScaleFactor: 1.2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        onTap: () async {
                          // LaunchReview.launch(androidAppId: "com.example.gym_app");
                          // launch("https://www.playstore.com");
                          // launch("https://play.google.com/store/apps/details?id=" + "com.example.gym_app");
                          // ignore: deprecated_member_use
                          launch(
                              "https://play.google.com/store/apps/details?id=gnhub.gym.management&pcampaignid=web_share");
                          Fluttertoast.showToast(msg: "Thank You For Rating Us\nOpening Play Store");
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          CupertinoIcons.question_circle_fill,
                          color: Colors.grey,
                        ),
                        title: Text(
                          "Contact Us",
                          // ignore: deprecated_member_use
                          // textScaleFactor: 1.2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
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
                                          child: Text(
                                            "GYM Management",
                                            // ignore: deprecated_member_use
                                            textScaleFactor: 1.5,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Divider(thickness: 0.5, indent: 20, endIndent: 20),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20, right: 20),
                                          child: Text(
                                            "We are thanking you for using our App.",
                                            // ignore: deprecated_member_use
                                            textScaleFactor: 1.5,
                                            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                                          child: Text(
                                            "Write us on Generation Next",
                                            // ignore: deprecated_member_use
                                            textScaleFactor: 1.5,
                                            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                                          child: InkWell(
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
                      ListTile(
                        leading: Icon(
                          Icons.share_rounded,
                          color: Colors.grey,
                        ),
                        title: Text(
                          "Share",
                          // ignore: deprecated_member_use
                          // textScaleFactor: 1.2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        onTap: () async {
                          // Share.share("https://play.google.com/store/apps/details?id=com.example.gym_app");
                          // List<String> filePaths = ['D:/A1 Flutter Projects January 2023/gym_app/build/app/outputs/flutter-apk/app-release.apk'];
                          // Share.shareFiles(File(filePaths),text: 'Check out my app!');
                          // Share.share("https://play.google.com/store/apps/details?id=com.example.gym_app");

                          // String apkPath = 'D:/A1 Flutter Projects January 2023/gym_app/build/app/outputs/flutter-apk/app-release.apk';
                          // print("Current directory: ${Directory.current.path}");
                          // String apkPath = 'build/app/outputs/flutter-apk/app-release.apk';
                          // apkPath = join(Directory.current.path, apkPath);  // Convert to absolute path
                          // List<String> filePaths = [apkPath];
                          // Share.shareFiles(filePaths, text: 'Check out my app!');
                          // String apkPath = 'assets/app-release.apk'; // Adjust the path based on your project structure
                          // ByteData bytes = await rootBundle.load(apkPath);
                          // List<int> fileBytes = bytes.buffer.asUint8List();
                          // await Share.file('app name', 'app-release.apk', fileBytes, 'application/vnd.android.package-archive');

                          // List<String> filePaths = (['https://play.google.com/store/apps/details?id=com.example.gym_app','https://drive.google.com/file/d/1-1ayAF5KVEbi-Wz24Pb2iIz5brWDXZW3/view?usp=drivesdk']);
                          // String driveLink = 'https://drive.google.com/file/d/1-1ayAF5KVEbi-Wz24Pb2iIz5brWDXZW3/view?usp=drivesdk';
                          // await Share.share(filePaths.toString());

                          // String playStoreLink = 'https://play.google.com/store/apps/details?id=com.example.gym_app';
                          // String driveLink = 'https://drive.google.com/file/d/1-1ayAF5KVEbi-Wz24Pb2iIz5brWDXZW3/view?usp=drivesdk';
                          String storeLink =
                              'https://play.google.com/store/apps/details?id=gnhub.gym.management&pcampaignid=web_share';

                          // List<String> filePaths = [playStoreLink, driveLink];
                          // String shareText = filePaths.join(', '); // Concatenate links without square brackets

                          await Share.share(storeLink);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.grey,
                        ),
                        title: const Text('Logout',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            )),
                        onTap: () {
                          Navigator.of(context).pop();
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
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),*/
          body: Stack(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 50,
                        width: double.infinity,
                        color: themecolor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: Card(
                          elevation: 5,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white, boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                spreadRadius: 0.5,
                                blurRadius: 2,
                              )
                            ]),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _getFilteredStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  print("true");
                                  return Center(
                                      child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ));
                                }
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                }
                                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                                // Calculate total credit and debit amounts
                                double totalCredit = 0.0;
                                double totalDebit = 0.0;

                                documents.forEach((doc) {
                                  double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
                                  String transactionType = doc['transactionType'].toString().toLowerCase();
                                  if (transactionType == 'credit') {
                                    totalCredit += amount;
                                  } else if (transactionType == 'debit') {
                                    totalDebit += amount;
                                  }
                                });

                                // Calculate final amount (total credit - total debit)
                                // double finalAmount = totalCredit - totalDebit;

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /*Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          child: Text(
                                            "Total Amount",
                                            // ignore: deprecated_member_use
                                            textScaleFactor: 1.4,
                                            style: TextStyle(
                                              color: themecolor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        // height: 150,
                                        // width: 150,
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          color: Color(0xff0558b4),
                                        ),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              // (finalAmount >= 0.0)
                                              //     ? '₹${finalAmount.toStringAsFixed(2)}'
                                              //     : '₹${finalAmount.abs().toString()}',
                                              (finalAmount >= 0.0)
                                                  ? '₹${finalAmount % 1 == 0 ? finalAmount.toStringAsFixed(0) : finalAmount.toStringAsFixed(2)}'
                                                  : '₹${finalAmount.abs() % 1 == 0 ? finalAmount.abs().toStringAsFixed(0) : finalAmount.abs().toStringAsFixed(2)} ${totalDebit > totalCredit ? 'Dr' : ''}',
                                              // ignore: deprecated_member_use
                                              textScaleFactor: 1.4,
                                              style: TextStyle(
                                                color: totalDebit > totalCredit ? Colors.white : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),*/
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Total Credit",
                                                  // ignore: deprecated_member_use
                                                  textScaleFactor: 1.4,
                                                  style: TextStyle(
                                                    color: themecolor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  totalCredit.toInt().toString(),
                                                  // ignore: deprecated_member_use
                                                  textScaleFactor: 1.4,
                                                  style: TextStyle(
                                                    color: themecolor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        // height: 150,
                                        // width: 150,
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          color: Color(0xff0558b4),
                                        ),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Total Debit",
                                                    // ignore: deprecated_member_use
                                                    textScaleFactor: 1.4,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    totalDebit.toInt().toString(),
                                                    // ignore: deprecated_member_use
                                                    textScaleFactor: 1.4,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _getFilteredStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                          ));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        // Debug: Print fetched documents
                        final List<DocumentSnapshot> documents = snapshot.data!.docs;

                        if (documents.isEmpty) {
                          return Center(
                            child: Text(
                              'No expenses found.',
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          );
                        }

                        // print("Fetched documents: ${documents.length}");
                        // documents.forEach((doc) {
                        //   print("Document: ${doc.data()}");
                        // });
                        //
                        // // Create a map to aggregate amounts by category
                        // final Map<String, double> categoryTotals = {};
                        // final Map<String, String> categoryTransactionType = {};
                        //
                        // for (var doc in documents) {
                        //   String category = doc['category'];
                        //   double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
                        //   String transactionType = doc['transactionType'].toString().toLowerCase();
                        //
                        //   // Debug: Print each document's details
                        //   print("Category: $category, Amount: $amount, Transaction Type: $transactionType");
                        //
                        //   // Aggregate the amounts for each category
                        //   if (categoryTotals.containsKey(category)) {
                        //     categoryTotals[category] = categoryTotals[category]! + amount;
                        //   } else {
                        //     categoryTotals[category] = amount;
                        //     categoryTransactionType[category] = transactionType;
                        //   }
                        // }
                        //
                        // // Debug: Print aggregated totals
                        // categoryTotals.forEach((category, total) {
                        //   print("Category: $category, Total Amount: $total");
                        // });
                        //
                        // final List<String> uniqueCategories = categoryTotals.keys.toList();

                        final Map<String, double> categoryCredits = {};
                        final Map<String, double> categoryDebits = {};

                        for (var doc in documents) {
                          String category = doc['category'];
                          double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
                          String transactionType = doc['transactionType'].toString().toLowerCase();

                          // Debug: Print each document's details
                          print("Category: $category, Amount: $amount, Transaction Type: $transactionType");

                          if (transactionType == 'credit') {
                            categoryCredits[category] = (categoryCredits[category] ?? 0.0) + amount;
                          } else if (transactionType == 'debit') {
                            categoryDebits[category] = (categoryDebits[category] ?? 0.0) + amount;
                          }
                        }

                        categoryCredits.forEach((category, total) {
                          double totalDebit = categoryDebits[category] ?? 0.0;
                          double finalAmount = total - totalDebit;
                          print("Category: $category, Final Amount: $finalAmount");
                        });

                        final List<String> uniqueCategories = categoryCredits.keys.toList();

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          itemCount: uniqueCategories.length,
                          itemBuilder: (context, index) {
                            // String category = uniqueCategories[index];
                            // double totalAmount = categoryTotals[category]!;
                            // String transactionType = categoryTransactionType[category]!;

                            String category = uniqueCategories[index];
                            double totalCredit = categoryCredits[category] ?? 0.0;
                            double totalDebit = categoryDebits[category] ?? 0.0;
                            double finalAmount = totalCredit - totalDebit;

                            // String category = uniqueCategoriesList[index];
                            // double totalCredit = categoryCredits[category] ?? 0.0;
                            // double totalDebit = categoryDebits[category] ?? 0.0;
                            // double finalAmount = totalCredit - totalDebit;

                            return Card(
                              color: kwhite,
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                minVerticalPadding: 20,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: kwhite,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryExpensePage(
                                        userId: widget.adminId,
                                        category: category,
                                        date: selectedMonthText,
                                      ),
                                    ),
                                  );
                                },
                                leading: Icon(Icons.shopping_bag, color: Colors.grey[500]),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(category),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            // '₹${totalAmount.abs().toStringAsFixed(2)}',
                                            '₹${finalAmount.abs().toStringAsFixed(finalAmount.truncateToDouble() == finalAmount ? 0 : 2)}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: finalAmount >= 0
                                                // transactionType == 'credit'
                                                ? const Color(0xFFDBE6CF)
                                                : const Color(0xFFF7D3C6),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          child: Text(
                                            '${/*transactionType == 'credit'*/ finalAmount >= 0 ? 'Cr' : 'Dr'}',
                                            style: TextStyle(
                                              color: finalAmount >= 0
                                                  // transactionType == 'credit'
                                                  ? const Color(0xFF6F9C40)
                                                  : const Color(0xFFAE2F09),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  // Stream<QuerySnapshot> _getFilteredStream(String selectedMonth) {
  //   return FirebaseFirestore.instance
  //       .collection('Admin')
  //       .doc(widget.userId)
  //       .collection('expense').snapshots();
  // }

  Stream<QuerySnapshot> _getFilteredStream() {
    Query query = FirebaseFirestore.instance.collection('Admin').doc(widget.userId).collection('expense');

    if (selectedTitle.isNotEmpty) {
      query = query.where('title', isEqualTo: selectedTitle);
    }

    if (selectedMonth != 'All') {
      DateTime firstDayOfMonth = _getFirstDayOfMonth(selectedMonth);
      DateTime lastDayOfMonth = _getLastDayOfMonth(selectedMonth);
      query = query.where('date', isGreaterThanOrEqualTo: firstDayOfMonth.toIso8601String());
      query = query.where('date', isLessThanOrEqualTo: lastDayOfMonth.toIso8601String());
    }

    return query.snapshots();
  }

  DateTime _getFirstDayOfMonth(String monthName) {
    int month = months.indexOf(monthName);
    DateTime now = DateTime.now();
    return DateTime(now.year, month, 1);
  }

  DateTime _getLastDayOfMonth(String monthName) {
    int month = months.indexOf(monthName);
    DateTime now = DateTime.now();
    return DateTime(now.year, month + 1, 0);
  }
}

class CategoryExpensePage extends StatelessWidget {
  final String userId;
  final String category;
  final String date;

  const CategoryExpensePage({
    Key? key,
    required this.userId,
    required this.category,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Hello World : ${date}");
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themecolor,
        title: Text(
          'Expenses for $category',
          style: TextStyle(fontWeight: FontWeight.bold, color: kwhite),
        ),
        iconTheme: IconThemeData(color: kwhite),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Admin')
            .doc(userId)
            .collection('expense')
            .where('category', isEqualTo: category)
            .snapshots(),
        // stream: FirebaseFirestore.instance
        //     .collection('Admin')
        //     .doc(userId)
        //     .collection('expense')
        //     .where('category', isEqualTo: category)
        //     .where('date', isGreaterThanOrEqualTo: startOfMonth)
        //     .where('date', isLessThanOrEqualTo: endOfMonth)
        //     .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themecolor),
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              'No expenses found for $category',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
            ));
          }

          final List<DocumentSnapshot> alldocuments = snapshot.data!.docs;

          // List<DocumentSnapshot> documents = [];
          // = alldocuments.where((doc) {
          //   // Assuming 'date' is of type DateTime
          //   return ; // Filter out documents with invalid 'date' fields
          // }).toList();

          /*alldocuments.forEach((element) {
            final dateField = element['date'];
            if (date == DateFormat('MMMM').format(DateTime.parse(dateField))) {
              documents.add(element);
            }
          });*/

          // if (date == 'All') {
          //   documents = alldocuments;
          // } else {
          //   alldocuments.forEach((element) {
          //     final dateField = element['date'];
          //     final documentDate = DateTime.parse(dateField);
          //     if (DateFormat('MMMM').format(documentDate) == date) {
          //       documents.add(element);
          //     }
          //   });
          // }

          List<DocumentSnapshot> documents = [];

          List<DocumentSnapshot> filteredByCategory = alldocuments.where((doc) {
            return doc['category'] == category;
          }).toList();

          if (date == 'All') {
            documents = filteredByCategory;
          } else {
            // documents = filteredByCategory.where((element) {
            //   final dateField = element['date'];
            //   final documentDate = DateTime.parse(dateField);
            //   return DateFormat('MMMM').format(documentDate) == date;
            // }).toList();

            documents = filteredByCategory.where((element) {
              final dateField = element['date'];
              String formattedDocumentDate;
              try {
                if (dateField == null || dateField.isEmpty || dateField == '') {
                  formattedDocumentDate = '--';
                } else {
                  DateTime? parsedDate = DateTime.tryParse(dateField);
                  if (parsedDate != null) {
                    formattedDocumentDate = DateFormat('MMMM').format(parsedDate);
                  } else {
                    formattedDocumentDate = '--';
                  }
                }
              } catch (e) {
                print("Date parsing error: $e");
                formattedDocumentDate = '--';
              }

              return formattedDocumentDate == date || formattedDocumentDate == '--';
            }).toList();
          }

          print('Filtered documents: $documents');

          print('Filtered Documents Count: ${documents.length}');
          documents.forEach((doc) {
            print('Title: ${doc['title']}, Amount: ${doc['amount']}, Date: ${doc['date']}');
          });

          print(documents);
          // Calculate total credit and debit amounts for this category
          double totalCredit = 0.0;
          double totalDebit = 0.0;
          documents.forEach((doc) {
            double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
            String transactionType = doc['transactionType'].toString().toLowerCase();
            if (transactionType == 'credit') {
              totalCredit += amount;
            } else if (transactionType == 'debit') {
              totalDebit += amount;
            }
          });

          // Calculate final amount (total credit - total debit)
          double finalAmount = totalCredit - totalDebit;

          return Stack(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                color: themecolor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Card(
                  // color: kwhite,
                  // elevation: 5,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
                  // margin: const EdgeInsets.all(15),
                  elevation: 5,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        spreadRadius: 0.5,
                        blurRadius: 2,
                      )
                    ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "Total Amount",
                              textAlign: TextAlign.center,
                              // ignore: deprecated_member_use
                              textScaleFactor: 1.4,
                              style: TextStyle(
                                color: themecolor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              color: themecolor,
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  // '₹${finalAmount.abs().toStringAsFixed(2)}${finalAmount < 0 ? ' Dr' : ''}',
                                  '₹${finalAmount.abs().toStringAsFixed(finalAmount.abs() % 1 == 0 ? 0 : 2)}${finalAmount < 0 ? ' Dr' : ''}',
                                  // ignore: deprecated_member_use
                                  textScaleFactor: 1.2,
                                  style: TextStyle(
                                    color: totalDebit > totalCredit ? Colors.white : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 80),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = documents[index];
                        String title = doc['title'];
                        String? date = doc['date'];
                        String time = doc['time'];
                        double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
                        String transactionType = doc['transactionType'].toString();
                        String remark = doc['remark'];
                        String? imageUrl = doc['imageUrl'];
                        String category = doc['category'];

                        String formattedDate;
                        try {
                          if (date == null || date.isEmpty || date == '') {
                            formattedDate = '--';
                          } else {
                            DateTime? parsedDate = DateTime.tryParse(date);
                            if (parsedDate != null) {
                              formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
                            } else {
                              formattedDate = '--';
                            }
                          }
                        } catch (e) {
                          print("Date parsing error: $e");
                          formattedDate = '--';
                        }

                        // Define hasRemark based on whether remark is present and not empty
                        bool hasRemark = remark.isNotEmpty;
                        bool hasImage = imageUrl != null && imageUrl != '';

                        return Card(
                            elevation: 5,
                            color: kwhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                // Show dialog box with expense details
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String displayDate = formattedDate != '--' ? formattedDate : "-No Date-";

                                    return AlertDialog(
                                      title: Text(
                                        'Expense Details',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start, // Align content to left
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center, // Align labels and values
                                            children: [
                                              Text(
                                                'Title:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                  child: Text(
                                                title
                                                // "Hello world how are you is every thing all right i cant find you "
                                                ,
                                                textAlign: TextAlign.end,
                                              )),
                                            ],
                                          ),
                                          const SizedBox(height: 8), // Add spacing between rows
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Amount:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(
                                                  '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Type:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(transactionType == 'credit' ? 'Credit' : 'Debit'),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Date:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(displayDate),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Time:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(time),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Category:',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(category),
                                            ],
                                          ),
                                          if (hasRemark) ...[
                                            Column(
                                              children: [
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Remark:',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                        child: Text(
                                                      remark
                                                      // "Hello world how are you is every thing all right i cant find you "
                                                      ,
                                                      textAlign: TextAlign.end,
                                                    )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (hasImage) ...[
                                            Column(
                                              children: [
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Bill Photo:",
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    InkWell(
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
                                                                        imageProvider: doc['imageUrl'] != null ||
                                                                                doc['imageUrl'] != ""
                                                                            ? NetworkImage(doc['imageUrl'])
                                                                                as ImageProvider<Object>?
                                                                            : AssetImage(
                                                                                "assets/images/app-logo-bg.png"),
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
                                                                            color:
                                                                                Colors.white, // Set the color to white
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
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(border: Border.all(color: Colors.black)),
                                                        child: Image.network(
                                                          doc['imageUrl'],
                                                          fit: BoxFit.cover,
                                                          loadingBuilder: (BuildContext context, Widget child,
                                                              ImageChunkEvent? loadingProgress) {
                                                            if (loadingProgress == null) {
                                                              return child;
                                                            } else {
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: loadingProgress.expectedTotalBytes != null
                                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                                          (loadingProgress.expectedTotalBytes ?? 1)
                                                                      : null,
                                                                  color: themecolor,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(), // Close the dialog
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: ListTile(
                                  tileColor: kwhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        // flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              '${formattedDate}',
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (hasRemark) ...[
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(Icons.note, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      remark,
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        // flex: 3,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              time,
                                              style: const TextStyle(fontFamily: 'Inter', fontSize: 12),
                                            ),
                                            Text(
                                              category,
                                              style: const TextStyle(fontFamily: 'Inter', fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        // flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(
                                                // '₹${amount.toStringAsFixed(2)}',
                                                '₹${amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: transactionType == 'credit'
                                                    ? const Color(0xFFDBE6CF)
                                                    : const Color(0xFFF7D3C6),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              child: Text(
                                                '${transactionType == 'credit' ? 'Cr' : 'Dr'}',
                                                style: TextStyle(
                                                  color: transactionType == 'credit'
                                                      ? const Color(0xFF6F9C40)
                                                      : const Color(0xFFAE2F09),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
