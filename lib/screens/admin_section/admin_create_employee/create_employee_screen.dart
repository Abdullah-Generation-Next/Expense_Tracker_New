import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../const/const.dart';
import '../../../getx_controller/load_excel_controller.dart';

//ignore: must_be_immutable
class AddEmployeeScreen extends StatefulWidget {
  DocumentSnapshot? userDoc;
  String? adminId;
  AddEmployeeScreen({super.key, this.userDoc, this.adminId});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isActive = true;
  bool? currentUserIsActive;
  bool isLoading = false;
  bool alreadyRegistered = false;

  // final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  InputDecoration _buildInputDecoration(String label, IconData icon, focusNode) {
    return InputDecoration(
      labelText: label,
      counterText: "",
      labelStyle: TextStyle(color: focusNode.hasFocus ? themecolor : Colors.black),
      prefixIcon: Icon(icon, color: focusNode.hasFocus ? themecolor : Colors.black),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: focusNode.hasFocus ? themecolor : Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: focusNode.hasFocus ? themecolor : Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: focusNode.hasFocus ? themecolor : Colors.black),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserStatus();

    usernameFocusNode.addListener(() {
      setState(() {});
    });

    mobileFocusNode.addListener(() {
      setState(() {});
    });

    emailFocusNode.addListener(() {
      setState(() {});
    });

    passwordFocusNode.addListener(() {
      setState(() {});
    });

    if (widget.userDoc != null) {
      _usernameController.text =
          widget.userDoc!.data().toString().contains('username') ? widget.userDoc!['username'] : '';
      _mobileController.text = widget.userDoc!.data().toString().contains('mobile') ? widget.userDoc!['mobile'] : '';
      _emailController.text = widget.userDoc!.data().toString().contains('email') ? widget.userDoc!['email'] : '';
      _passwordController.text =
          widget.userDoc!.data().toString().contains('password') ? widget.userDoc!['password'] : '';
      _isActive = widget.userDoc!.data().toString().contains('isActive') ? widget.userDoc!['isActive'] : true;
    }
  }

  Future<void> _fetchCurrentUserStatus() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.adminId).get();
      if (userDoc.exists) {
        setState(() {
          currentUserIsActive = userDoc['isActive'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user status: $e')),
      );
    }
  }

  /*
  Future<void> _submitForm(BuildContext context, /*{DocumentSnapshot? userDoc}*/) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        if (widget.userDoc == null) {
          final emailQuery = await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: _emailController.text)
              .get();

          if (emailQuery.docs.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email is already registered, please use a different one.')),
            );

            setState(() {
              alreadyRegistered = true;
              isLoading = false;
            });

            _formKey.currentState!.validate();
            return;
          }

          await FirebaseFirestore.instance.collection('Users').add({
            'adminId': widget.adminId,
            'username': _usernameController.text,
            'mobile': _mobileController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
            'pin': "",
            'isSwitchOn': false,
            'employee_logo': '',
          });
        } else {
          // Update existing user (No need to check email duplication)
          final Map<String, dynamic> userData = widget.userDoc?.data() as Map<String, dynamic>;

          if (!userData.containsKey('mobile')) {
            await FirebaseFirestore.instance.collection('Users').doc(widget.userDoc?.id).update({
              'mobile': _mobileController.text,
            });
          }

          await FirebaseFirestore.instance.collection('Users').doc(widget.userDoc?.id).update({
            'username': _usernameController.text,
            'mobile': _mobileController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
          });
        }

        Navigator.of(context).pop();

        // Clear fields after operation
        _usernameController.clear();
        _mobileController.clear();
        _emailController.clear();
        _passwordController.clear();

        setState(() {
          isLoading = false;
          alreadyRegistered = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
          alreadyRegistered = false;
        });
      }
    }
  }
  */

  Future<void> _submitForm(
    BuildContext context,
    /*{DocumentSnapshot? userDoc}*/
  ) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Query Firestore to check if the email already exists
        final emailQuery =
            await FirebaseFirestore.instance.collection('Users').where('email', isEqualTo: _emailController.text).get();

        if (emailQuery.docs.isNotEmpty && widget.userDoc == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email is already registered kindly register with new one.')),
          );
          // Fluttertoast.showToast(msg: "Email is already registered kindly register with new one.");
          setState(() {
            alreadyRegistered = true;
            isLoading = false;
          });
          _formKey.currentState!.validate();

          return;
        }

        if (widget.userDoc == null) {
          // Add new user if no existing email is found
          await FirebaseFirestore.instance.collection('Users').add({
            'adminId': widget.adminId,
            'username': _usernameController.text,
            'mobile': _mobileController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
            'pin': "",
            'isSwitchOn': false,
            'employee_logo': '',
          });
          Navigator.of(context).pop();
        } else {
          // Update existing user

          final Map<String, dynamic> userData = widget.userDoc?.data() as Map<String, dynamic>;

          if (!userData.containsKey('mobile')) {
            await FirebaseFirestore.instance.collection('Users').doc(widget.userDoc?.id).update({
              'mobile': _mobileController.text,
            });
          }

          await FirebaseFirestore.instance.collection('Users').doc(widget.userDoc?.id).update({
            'username': _usernameController.text,
            'mobile': _mobileController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
          });
          Navigator.of(context).pop();
        }

        _usernameController.clear();
        _mobileController.clear();
        _emailController.clear();
        _passwordController.clear();

        setState(() {
          isLoading = false;
          alreadyRegistered = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
          alreadyRegistered = false;
        });
      }
    }
  }

  /*
  Future<void> insertMultipleUsers(BuildContext context) async {
    final firestore = FirebaseFirestore.instance.collection('Users');

    List<Future<void>> batchInserts = [];
    final random = Random();

    for (int i = 0; i < 100; i++) {
      String randomUsername = "Abdullah${random.nextInt(100000)}";
      String randomMobile = "9${random.nextInt(1000000000).toString().padLeft(9, '0')}";
      String randomEmail = "abdullah${random.nextInt(100000)}@gnhub.com";

      final userData = {
        'adminId': widget.adminId,
        'username': randomUsername,
        'mobile': randomMobile,
        'email': randomEmail,
        'password': "123456",
        'isActive': true,
        'pin': "",
        'isSwitchOn': false,
        'employee_logo': "",
      };

      batchInserts.add(firestore.add(userData));
    }

    try {
      await Future.wait(batchInserts);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("10 Users inserted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  */

  @override
  void dispose() {
    usernameFocusNode.dispose();
    mobileFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kgrey,
      appBar: AppBar(
        backgroundColor: themecolor,
        title: Obx(
          () => Text(
            widget.userDoc == null
                ? 'Add ${loadController.siteLable.value /*.split(' ')[0]*/}'
                : 'Edit ${loadController.siteLable.value /*.split(' ')[0]*/}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite
                // backgroundColor: Color(0xff0393f4),
                ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // _showAddEditDialog(context);
        //       Navigator.push(
        //           context, MaterialPageRoute(builder: (context) => AddEmployeeScreen(adminId: widget.adminId)));
        //     },
        //     icon: Icon(Icons.person_add_alt_1),
        //   ),
        // ],
        iconTheme: IconThemeData(color: kwhite),
      ),
      bottomNavigationBar: Container(
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  // Navigator.of(context).pop();
                  _submitForm(
                    context, /*userDoc: widget.userDoc*/
                  );
                },
          style: ButtonStyle(
              // ignore: deprecated_member_use
              backgroundColor: MaterialStateProperty.all(themecolor),
              // ignore: deprecated_member_use
              foregroundColor: MaterialStateProperty.all(kwhite),
              // ignore: deprecated_member_use
              padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 50))),
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(widget.userDoc == null ? 'Create' : 'Save'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Form(
          key: _formKey,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Obx(
                    () => TextFormField(
                      controller: _usernameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      focusNode: usernameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(mobileFocusNode);
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration(
                        '${loadController.siteLable.value /*.split(' ')[0]*/} Name',
                        Icons.person,
                        usernameFocusNode,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter a username';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Obx(
                    () => TextFormField(
                      controller: _mobileController,
                      textInputAction: TextInputAction.next,
                      focusNode: mobileFocusNode,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(emailFocusNode);
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration(
                        '${loadController.siteLable.value /*.split(' ')[0]*/} Mobile No.',
                        Icons.phone,
                        mobileFocusNode,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter a mobile no.';
                        }
                        if (value.length < 10) {
                          return 'Mobile no. must not exceed 10 digits.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    focusNode: emailFocusNode,
                    readOnly: widget.userDoc != null ? true : false,
                    onTap: () {
                      widget.userDoc != null ? Fluttertoast.showToast(msg: "You cannot edit your email ID.") : null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: _buildInputDecoration(
                      'Email',
                      Icons.email,
                      emailFocusNode,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email';
                      }
                      value = value.trim();
                      if (value != value.toLowerCase()) {
                        return 'Email must be in lowercase';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      if (alreadyRegistered) {
                        return 'Email is already registered';
                      }
                      return null;
                      // if (!value.contains('@gmail.com')) {
                      //   return 'Enter a valid email (example@gmail.com)';
                      // }
                      // final emailRegex = RegExp(r"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$");
                      // if (!emailRegex.hasMatch(value)) {
                      //   return 'Enter a valid email (example@gmail.com)';
                      // }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    focusNode: passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.black),
                    readOnly: widget.userDoc != null ? true : false,
                    onTap: () {
                      widget.userDoc != null
                          ? Fluttertoast.showToast(
                              msg:
                                  "You cannot edit your Password once you created, you can only view your Password.\n If you want to update your Password use Change Password feature from Profile.")
                          : null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: passwordFocusNode.hasFocus ? themecolor : Colors.black),
                      prefixIcon: Icon(Icons.lock, color: passwordFocusNode.hasFocus ? themecolor : Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: passwordFocusNode.hasFocus ? themecolor : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: passwordFocusNode.hasFocus ? themecolor : Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: passwordFocusNode.hasFocus ? themecolor : Colors.black, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: passwordFocusNode.hasFocus ? themecolor : Colors.black),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      // if (!RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9]+)$')
                      //     .hasMatch(value)) {
                      //   return 'Password must contain at least one number or character';
                      // }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text('${loadController.siteLable.value /*.split(' ')[0]*/} Status:',
                              style: TextStyle(color: Colors.black, fontSize: 15)),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isActive = !_isActive;
                            });
                          },
                          child: Row(
                            children: [
                              Text('Active', style: TextStyle(color: Colors.green)),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 10,
                                width: 20,
                                margin: EdgeInsets.all(0),
                                padding: EdgeInsets.all(0),
                                child: Radio<bool>(
                                  value: true,
                                  groupValue: _isActive,
                                  activeColor: Colors.green,
                                  onChanged: (value) {
                                    setState(() {
                                      _isActive = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isActive = !_isActive;
                            });
                          },
                          child: Row(
                            children: [
                              Text('Inactive', style: TextStyle(color: Colors.red)),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 10,
                                width: 20,
                                margin: EdgeInsets.all(0),
                                padding: EdgeInsets.all(0),
                                child: Radio<bool>(
                                  value: false,
                                  groupValue: _isActive,
                                  activeColor: Colors.red,
                                  onChanged: (value) {
                                    setState(() {
                                      _isActive = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
