import 'package:etmm/const/const.dart';
import 'package:flutter/material.dart';

import '../widget/helper.dart';

class enterpin_code extends StatefulWidget {
  const enterpin_code({Key? key}) : super(key: key);

  @override
  State<enterpin_code> createState() => _enterpin_codeState();
}

class _enterpin_codeState extends State<enterpin_code> {
  var selectedindex = 0;
  String code = '';
  // Summarycontroller _summarycontroller = Get.put(Summarycontroller());
  // Controller c = Get.put(Controller());

  // String? pincode = SharedPref.get(prefKey: PrefKey.setpin) != null ? SharedPref.get(prefKey: PrefKey.setpin) : null ;
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text("Enter PIN", style: TextStyle(fontSize: 24, color: Colors.black)),
        ),
        body: Column(
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
              'Enter 4 Digit PIN',
              style: TextStyle(color: themecolor, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DigitHolder(
                    selectedIndex: selectedindex,
                    index: 0,
                    width: width,
                    code: code,
                  ),
                  DigitHolder(
                    selectedIndex: selectedindex,
                    index: 1,
                    width: width,
                    code: code,
                  ),
                  DigitHolder(
                    selectedIndex: selectedindex,
                    index: 2,
                    width: width,
                    code: code,
                  ),
                  DigitHolder(
                    selectedIndex: selectedindex,
                    index: 3,
                    width: width,
                    code: code,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight(context, dividedBy: 4)),
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
                ],
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
      print('Code is $code');
      selectedindex = code.length;
      if (code.length == 4) {
        // if(pincode == code){
        //   setState(() {
        //     // c.state.value = true;
        //   });
        //   MainScreengo();
        // }else{
        //   code ="";
        //   Fluttertoast.showToast(msg: "Wrong Pin.");
        // }
      }
    });
  }

  MainScreengo() {
    // _summarycontroller.get_summarydetailsforhome();
  }
  backspace() {
    if (code.length == 0) {
      return;
    }
    setState(() {
      code = code.substring(0, code.length - 1);
      selectedindex = code.length;
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
      padding: const EdgeInsets.only(bottom: 0),
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
