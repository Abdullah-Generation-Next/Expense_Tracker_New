import 'package:etmm/const/const.dart';
import 'package:etmm/widget/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';

import '../../../getx_controller/load_excel_controller.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final String userId;
  // final String date ;
  final DocumentSnapshot userDoc;
  final bool fromAdmin;

  const EmployeeHomeScreen({
    Key? key,
    required this.userId,
    required this.userDoc,
    this.fromAdmin = false,
  }) : super(key: key);

  @override
  _EmployeeHomeScreenState createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  String selectedTitle = '';
  String selectedMonth = 'All';
  String selectedMonthText = '';

  final TextEditingController titleController = TextEditingController();

  LoadAllFieldsController controller = Get.put(LoadAllFieldsController());
  final constants = Const();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize selectedMonth to current month or 'All' if needed
    DateTime now = DateTime.now();
    selectedMonth = months[now.month];
    constants.loadUserData(widget.userId);
  }

  final List<String> months = [
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

  // bool _lightsOn = false;

  // Future<bool> onWillPop(BuildContext context) async {
  //   return (await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('Exit App Confirmation'),
  //           content: const Text('Do you want to exit the app?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: const Text('No'),
  //             ),
  //             TextButton(
  //               onPressed: () => exit(0),
  //               child: const Text('Yes'),
  //             ),
  //           ],
  //         ),
  //       )) ??
  //       false; // Return false if the dialog is dismissed
  // }

  Future<bool> onWillPop(BuildContext context) async {
    if (widget.fromAdmin == true) {
      Navigator.of(context).pop();
      return false; // Prevent showing the dialog
    } else {
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
            leading: widget.fromAdmin == true
                ? null
                : Obx(
                    () => (controller.companyLogo.value != "")
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              foregroundImage: NetworkImage(controller.companyLogo.value),
                              child: GestureDetector(
                                onTap: () async {
                                  /*await showDialog(
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
                                  image: NetworkImage(controller.companyLogo.value),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );*/
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
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 10),
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
                                radius: 15,
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
                  ),
            title: Text(
              'Dashboard ${selectedMonthText.isNotEmpty && selectedMonthText != 'All' ? "- $selectedMonthText" : ""}',
              style: TextStyle(fontWeight: FontWeight.bold, color: kwhite),
            ),
            automaticallyImplyLeading: false,
            // leading: Builder(
            //   builder: (context) {
            //     return IconButton(
            //       icon: Icon(
            //         Icons.menu,
            //         color: kwhite,
            //       ),
            //       onPressed: () {
            //         Scaffold.of(context).openDrawer();
            //       },
            //     );
            //   },
            // ),
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
              // IconButton(
              //   icon: Icon(Icons.filter_list,color: kwhite,),
              //   onPressed: () {
              //     showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return AlertDialog(
              //           title: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               const Text('Filter Expenses'),
              //               IconButton(
              //                 icon: const Icon(Icons.close),
              //                 onPressed: () {
              //                   Navigator.of(context).pop();
              //                 },
              //               ),
              //             ],
              //           ),
              //           content: Column(
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               TextFormField(
              //                 controller: titleController,
              //                 decoration: const InputDecoration(
              //                   labelText: 'Title',
              //                 ),
              //                 onChanged: (value) {
              //                   setState(() {
              //                     selectedTitle = value;
              //                   });
              //                 },
              //               ),
              //               SizedBox(height: 16),
              //               InputDecorator(
              //                 decoration: const InputDecoration(
              //                   labelText: 'Month',
              //                   border: OutlineInputBorder(),
              //                   contentPadding: EdgeInsets.symmetric(
              //                       horizontal: 12, vertical: 8),
              //                 ),
              //                 child: DropdownButtonHideUnderline(
              //                   child: DropdownButton<String>(
              //                     value: selectedMonth,
              //                     isExpanded: true,
              //                     items: months.map((String month) {
              //                       return DropdownMenuItem<String>(
              //                         value: month,
              //                         child: Text(month),
              //                       );
              //                     }).toList(),
              //                     onChanged: (String? newValue) {
              //                       setState(() {
              //                         selectedMonth = newValue!;
              //                         selectedMonthText = selectedMonth;
              //                       });
              //                     },
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //           actions: [
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 TextButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       titleController.text = '';
              //                       selectedTitle = '';
              //                       selectedMonth = 'All';
              //                       selectedMonthText = getFullMonthName(0);
              //                     });
              //                     Navigator.of(context).pop();
              //                   },
              //                   child: const Text(
              //                     'Reset',
              //                     style: TextStyle(fontSize: 15),
              //                   ),
              //                 ),
              //                 ElevatedButton(
              //                   onPressed: () {
              //                     setState(() {
              //                       selectedTitle = titleController.text;
              //                     });
              //                     Navigator.of(context).pop();
              //                   },
              //                   child: const Text(
              //                     'Apply',
              //                     style: TextStyle(fontSize: 15),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ],
              //         );
              //       },
              //     );
              //
              //   },
              // ),
            ],
          ),
          /*drawer: Drawer(
            backgroundColor: kwhite,
            child: Column(
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
                              Icons.person_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          const Text(
                            'Employee Panel',
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
                        title: Text(
                          'Change Password',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.0,
                            // fontWeight: FontWeight.w500,
                            // height: 1.21,
                          ),
                        ),
                        leading: Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmployeeChangePassword(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'View Expenses',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.0,
                            // fontWeight: FontWeight.w500,
                            // height: 1.21,
                          ),
                        ),
                        leading: Icon(
                          Icons.list,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpenseListEmployee(
                                userDoc: widget.userDoc,
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
                            // height: 1.21,
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
                            MaterialPageRoute(builder: (context) => EmployeeSetPin(userId: widget.userId, userDoc: widget.userDoc)),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.0,
                            // fontWeight: FontWeight.w500,
                            // height: 1.21,
                          ),
                        ),
                        leading: Icon(
                          Icons.logout_sharp,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Logout Confirmation'),
                                content: const Text(
                                  'Do you want to logout?',
                                  style: TextStyle(fontSize: 15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'No',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                                    ),
                                    onPressed: () async {
                                      try {
                                        SharedPref.deleteAll();
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RootApp(),
                                          ),
                                              (Route<dynamic> route) => false,
                                        );
                                      } catch (e) {
                                        if (kDebugMode) {
                                          print('Error signing out: $e');
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),*/
          body: Stack(children: [
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
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
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
                                            //     : '₹${finalAmount.abs().toString()} ',
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
                      // final Map<String, double> categoryTotals = {};
                      // final Map<String, String> categoryTransactionType = {};
                      //
                      // for (var doc in documents) {
                      //   String category = doc['category'];
                      //   double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
                      //   String transactionType = doc['transactionType'].toString().toLowerCase();
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

                          return Card(
                            color: kwhite,
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              minVerticalPadding: 20,
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryDetailsPage(
                                      userId: widget.userId,
                                      category: category,
                                      // userDoc: widget.userDoc,
                                      date: selectedMonthText,
                                      // You may need to pass the document if required
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
                                          '₹${finalAmount.abs().toStringAsFixed(finalAmount.truncateToDouble() == finalAmount ? 0 : 2)} ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: 5,
                                      // ),
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
                ),
              ],
            ),
          ])),
    );
  }

  /*
                Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.transparent,
                foregroundImage: NetworkImage(controller.companyLogo.value),
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
                                  image: NetworkImage(controller.companyLogo.value),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            */

  // String _getUsername(String email) {
  //   // Split email address by '@' symbol and return the first part
  //   return email.split('@').first;
  // }

  Stream<QuerySnapshot> _getFilteredStream() {
    Query query = FirebaseFirestore.instance.collection('Users').doc(widget.userId).collection('expenses');

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

class CategoryDetailsPage extends StatelessWidget {
  final String userId;
  final String category;
  // final DocumentSnapshot userDoc;
  final String date;

  const CategoryDetailsPage({
    Key? key,
    required this.userId,
    required this.category,
    // required this.userDoc,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Hello World : ${date != '' ? date : ""}");
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
            .collection('Users')
            .doc(userId)
            .collection('expenses')
            .where('category', isEqualTo: category)
            .snapshots(),
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
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
            ));
          }

          final List<DocumentSnapshot> alldocuments = snapshot.data!.docs;

          // List<DocumentSnapshot> documents = [];
          //
          // alldocuments.forEach((element) {
          //   final dateField = element['date'];
          //   if (date == DateFormat('MMMM').format(DateTime.parse(dateField))) {
          //     documents.add(element);
          //   }
          // });
          // print(documents);

          // documents.forEach((doc) {
          //   final dateField = doc['date'];
          //   if (dateField == DateFormat('MMMM').format(DateTime.parse(dateField))) {
          //     documents.add(doc);
          //   }
          // });

          // Widget _buildDialog(String title, String date, String remark, String time, String category, double amount, String transactionType) {
          //   return AlertDialog(
          //     title: Text(title),
          //     content: SingleChildScrollView(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text('Date: ${DateFormat('dd-MM').format(DateTime.parse(date))}'),
          //           if (remark != null && remark.isNotEmpty) ...[
          //             SizedBox(height: 5),
          //             Text('Remark: $remark'),
          //           ],
          //           Text('Time: $time'),
          //           Text('Category: $category'),
          //           Text('Amount: ₹${amount.toStringAsFixed(2)}'),
          //           Text(
          //             'Transaction Type: ${transactionType == 'credit' ? 'Credit' : 'Debit'}',
          //           ),
          //         ],
          //       ),
          //     ),
          //     actions: [
          //       TextButton(
          //         onPressed: () => Navigator.pop(context),
          //         child: Text('Close'),
          //       ),
          //     ],
          //   );
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
              // This container represents the AppBar
              Container(
                height: 50,
                width: double.infinity,
                color: themecolor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
              // This card is positioned to overlap with the AppBar
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Card(
                  elevation: 5,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  // margin: const EdgeInsets.all(15),
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
                              textScaleFactor: 1.2,
                              style: TextStyle(
                                color: themecolor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // height: 50, // Fixed height for better layout
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              color: themecolor,
                            ),
                            child: Center(
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
                      ],
                    ),
                  ),
                ),
              ),
              // This column contains the rest of your content
              Column(
                children: [
                  SizedBox(height: 80),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = documents[index];
                        String title = doc['title'];
                        String? date = doc['date'];
                        String time = doc['time'];
                        double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
                        String transactionType = doc['transactionType'].toString().toLowerCase();
                        String? remark = doc['remark'];
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

                        // Check if remark is not null and not empty
                        bool hasRemark = remark != null && remark.isNotEmpty;
                        bool hasImage = imageUrl != null && imageUrl != '';

                        return Card(
                            color: kwhite,
                            elevation: 5,
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
                                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(amount % 1 == 0
                                                    ? '₹${amount.toStringAsFixed(0)}'
                                                    : '₹${amount.toStringAsFixed(2)}'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Type:',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                // const SizedBox(height: 8),
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
                                  // minVerticalPadding: -1,
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
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              '${formattedDate}',
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (remark != null && remark.isNotEmpty) ...[
                                              // SizedBox(height: 0.0), // Adjust spacing as needed
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.note, size: 16, color: Colors.grey),
                                                  SizedBox(width: 5),
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
