import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/widget/helper.dart';
import 'package:etmm/screens/employee_section/setup_pin/confirm_pin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmployeeSetPin extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userDoc;

  const EmployeeSetPin({
    Key? key,
    required this.userId,
    required this.userDoc,
  }) : super(key: key);

  @override
  State<EmployeeSetPin> createState() => _EmployeeSetPinState();
}

class _EmployeeSetPinState extends State<EmployeeSetPin> {
  var selectedIndex = 0;
  String code = '';
  bool isSwitchOn = false;
  bool isProcessing = false;
  bool alreadyPinStored = false;

  @override
  void initState() {
    // if (widget.userDocEmployee['isSwitchOn'] == true) {
    //   setState(() {
    //     isSwitchOn = true;
    //   });
    // } else {
    //   setState(() {
    //     isSwitchOn = false;
    //   });
    // }
    // fetchLatestData();
    super.initState();
  }

  /*void fetchLatestData() async {
    setState(() {
      isProcessing = true;
    });
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();

    setState(() {
      isSwitchOn = userSnapshot['isSwitchOn'] ?? false;
      alreadyPinStored = isSwitchOn;
      print(alreadyPinStored);
      print(isSwitchOn);
      isProcessing = false;
    });
  }*/

 /* void turnOffPin(BuildContext context) async {
    setState(() {
      isProcessing = true;
    });

    try {
      await FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({'pin': '', 'isSwitchOn': false});

      Fluttertoast.showToast(msg: "PIN turned off successfully");
      setState(() {
        isSwitchOn = false;
        alreadyPinStored = false;
      });
    } catch (error) {
      Fluttertoast.showToast(msg: "Error turning off PIN: $error");
      print(error);
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }*/

  Future<void> fetchLatestData() async {
    setState(() {
      isProcessing = true;
    });
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();

      setState(() {
        alreadyPinStored = (userSnapshot['pin']?.toString().isNotEmpty ?? false);
        isProcessing = false;
      });
    } catch (error) {
      print("Error fetching data: $error");
      setState(() {
        isProcessing = false;
      });
      Fluttertoast.showToast(msg: "Failed to fetch data. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(isSwitchOn);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: themecolor,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Set PIN',
                        style:
                            TextStyle(letterSpacing: 0.2, fontSize: 20, color: themecolor, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  /*Switch(
                    value: isSwitchOn,
                    onChanged: (value) {
                      // setState(() {
                      //   isSwitchOn = value;
                      // });
                      if (value == false && isSwitchOn == true) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm'),
                              content: Text('Do you really want to turn off PIN?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Reset Firestore values
                                    Navigator.of(context).pop();
                                    turnOffPin(context);
                                  },
                                  child: Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        setState(() {
                          isSwitchOn = value;
                        });
                      }
                    },
                    activeColor: themecolor,
                  ),*/
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
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
                // Flexible(child: Container()),
                // Expanded(child: Container()),
                // SizedBox(height: screenHeight(context, dividedBy: 4.5)),
                Spacer(),
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
    // if (!isSwitchOn) {
    //   return Fluttertoast.showToast(msg: "Please switch on from top-right corner to set PIN.");
    // }

    if (alreadyPinStored == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: Duration(seconds: 5),
            content: Text("The PIN is already set. You need to turn it off before re-setting a new PIN.")),
      );
      return;
    }

    if (code.length > 3) {
      return;
    }
    setState(() {
      code = code + digit.toString();
      print('Code is $code');
      selectedIndex = code.length;
      if (code.length == 4) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EmployeeConfirmPin(
                      code: code,
                      userId: widget.userId,
                      userDoc: widget.userDoc,
                    )));
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
