import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/employee_section/home/employee_root_screen_navigation.dart';
import 'package:etmm/widget/helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../getx_controller/load_excel_controller.dart';

class EmployeeConfirmPin extends StatefulWidget {
  final bool? isFromSetPin;
  final String? code;
  final String? userId;
  final DocumentSnapshot userDoc;
  const EmployeeConfirmPin({Key? key, this.code, this.userId, required this.userDoc, this.isFromSetPin})
      : super(key: key);

  @override
  State<EmployeeConfirmPin> createState() => _EmployeeConfirmPinState();
}

class _EmployeeConfirmPinState extends State<EmployeeConfirmPin> {
  var selectedIndex = 0;
  String code = '';
  String? storedCode;
  bool isProcessing = false;

  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  @override
  void initState() {
    if (widget.userDoc['isSwitchOn'] == true) {
      storedCode = widget.userDoc['pin'];
      print(storedCode);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TextStyle textStyle = TextStyle(
    //   fontSize: 25,
    //   fontWeight: FontWeight.w500,
    //   color: Colors.black.withBlue(40),
    // );
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Row(
                mainAxisAlignment: widget.isFromSetPin == true ? MainAxisAlignment.center : MainAxisAlignment.start,
                crossAxisAlignment: widget.isFromSetPin == true ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  widget.isFromSetPin == true
                      ? SizedBox.shrink()
                      : Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: themecolor,
                                )),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                  widget.isFromSetPin == true
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Center(
                            child: Text(
                              'Enter PIN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  letterSpacing: 0.2, fontSize: 20, color: themecolor, fontWeight: FontWeight.w800),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 7.5),
                          child: Text(
                            'Re-Set PIN',
                            style: TextStyle(
                                letterSpacing: 0.2, fontSize: 20, color: themecolor, fontWeight: FontWeight.w800),
                          ),
                        )
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight(context, dividedBy: 16)),
                  child: Image(
                    image: AssetImage('assets/images/app-logo-bg.png'),
                    height: 120,
                    width: 120,
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'Set 4 Digit PIN',
                  style: TextStyle(color: themecolor, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DigitHolder(
                        selectedIndex: selectedIndex,
                        index: 0,
                        width: width,
                        code: code,
                      ),
                      DigitHolder(
                        selectedIndex: selectedIndex,
                        index: 1,
                        width: width,
                        code: code,
                      ),
                      DigitHolder(
                        selectedIndex: selectedIndex,
                        index: 2,
                        width: width,
                        code: code,
                      ),
                      DigitHolder(
                        selectedIndex: selectedIndex,
                        index: 3,
                        width: width,
                        code: code,
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: screenHeight(context, dividedBy: 5)),
                Spacer(),
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(1),
                              numbers: '1',
                            ),
                          ),
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(2),
                              numbers: '2',
                            ),
                          ),
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(3),
                              numbers: '3',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(4),
                              numbers: '4',
                            ),
                          ),
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(5),
                              numbers: '5',
                            ),
                          ),
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(6),
                              numbers: '6',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(7),
                              numbers: '7',
                            ),
                          ),
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(8),
                              numbers: '8',
                            ),
                          ),
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(9),
                              numbers: '9',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                backspace();
                              },
                              icon: Icon(
                                Icons.backspace_outlined,
                                color: themecolor,
                                size: 22,
                              ),
                            ),
                          ),
                          Expanded(
                            child: numbers_widget(
                              onTap: () => addDigit(0),
                              numbers: '0',
                            ),
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
            if (isProcessing)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  addDigit(int digit) {
    if (code.length > 3) {
      return;
    }
    setState(() {
      code = code + digit.toString();
      print('Confirm Code is $code');
      selectedIndex = code.length;
      if (code.length == 4) {
        setState(() {
          isProcessing = true;
        });
        Future.delayed(Duration(milliseconds: 200), () {
          if (widget.userDoc['isSwitchOn'] == true) {
            if (code == storedCode) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeRootScreen(
                    userId: widget.userDoc.id,
                    userDoc: widget.userDoc,
                    initialIndex: 0,
                  ),
                ),
              );
            } else {
              setState(() {
                code = '';
                selectedIndex = 0;
                isProcessing = false;
              });
              Fluttertoast.showToast(msg: "PINs do not match. Try again.");
            }
          } else {
            if (code == widget.code) {
              setState(() {
                isProcessing = true;
              });
              // Save PIN to Firestore
              /* FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({'pin': code}).then((_) {
                // Save the switch state as well
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.userId)
                    .update({'isSwitchOn': true}).then((_) {
                  Fluttertoast.showToast(msg: "PIN Set Successfully");
                  setState(() {
                    isProcessing = false;
                  });
                  Navigator.pop(context);
                }).catchError((error) {
                  Fluttertoast.showToast(msg: "Error setting switch state: $error");
                  setState(() {
                    isProcessing = false;
                  });
                });
              }).catchError((error) {
                Fluttertoast.showToast(msg: "Error setting PIN: $error");
                setState(() {
                  isProcessing = false;
                });
              });*/
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.userId)
                  .update({'pin': code, 'isSwitchOn': true}).then((_) async {
                Fluttertoast.showToast(msg: "PIN Set Successfully");
                setState(() {
                  isProcessing = false;
                });
                await loadController.updateEmployeePinStatusFromFirestore(widget.userId);
                Navigator.pop(context);
              }).catchError((error) {
                Fluttertoast.showToast(msg: "Error setting PIN: $error");
                setState(() {
                  isProcessing = false;
                });
              });
            } else {
              setState(() {
                code = '';
                selectedIndex = 0;
                isProcessing = false;
              });
              Fluttertoast.showToast(msg: "PINs do not match. Try again.");
            }
          }
        });
      }
    });
  }

  backspace() {
    if (code.length == 0) {
      return;
    }
    setState(() {
      code = code.substring(0, code.length - 1);
      selectedIndex = code.length;
    });
  }

  // Home({required String userId, required DocumentSnapshot<Object?> userDoc}) {}
}

class numbers_widget extends StatelessWidget {
  numbers_widget({Key? key, required this.numbers, required this.onTap}) : super(key: key);

  final String numbers;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Ink(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              numbers,
              style: TextStyle(color: themecolor, fontSize: 22, fontWeight: FontWeight.w700),
            )),
          ),
        ),
      ),
    );
  }
}

class DigitHolder extends StatelessWidget {
  final int selectedIndex;
  final int index;
  final String code;
  const DigitHolder({
    required this.selectedIndex,
    Key? key,
    required this.width,
    required this.index,
    required this.code,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CircleAvatar(
        backgroundColor: themecolor,
        radius: 15,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 13,
          child: code.length > index
              ? CircleAvatar(
                  radius: 10,
                  backgroundColor: themecolor,
                )
              : Container(),
        ),
      ),
    );
  }
}
