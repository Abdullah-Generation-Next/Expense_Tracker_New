import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/getx_controller/load_excel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_employee_screen.dart';
import 'create_employee_screen.dart';

class CreateEmployeeDialog extends StatefulWidget {
  final String adminId;

  const CreateEmployeeDialog({Key? key, required this.adminId}) : super(key: key);

  @override
  _CreateEmployeeDialogState createState() => _CreateEmployeeDialogState();
}

class _CreateEmployeeDialogState extends State<CreateEmployeeDialog> {
  // final TextEditingController _usernameController = TextEditingController();
  // final TextEditingController _mobileController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // bool _isPasswordVisible = false;
  // bool _isActive = true;
  bool? _currentUserIsActive;
  bool isLoading = false;
  bool alreadyRegistered = false;

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  /* InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      counterText: "",
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.black),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }*/

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserStatus();
  }

  Future<void> _fetchCurrentUserStatus() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.adminId).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserIsActive = userDoc['isActive'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user status: $e')),
      );
    }
  }

  /*Future<void> _submitForm(BuildContext context, {DocumentSnapshot? userDoc}) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      print(isLoading);

      Navigator.of(context).pop();

      // String username = _usernameController.text;
      // String email = _emailController.text;
      // String password = _passwordController.text;

      try {
        if (userDoc == null) {
          await FirebaseFirestore.instance.collection('Users').add({
            'adminId': widget.adminId,
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
            'pin': "",
            'isSwitchOn': false,
          });
          // Navigator.of(context).pop();
          setState(() {
            isLoading = false;
          });
        } else {
          await FirebaseFirestore.instance.collection('Users').doc(userDoc.id).update({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
          });
          // Navigator.of(context).pop();
          setState(() {
            isLoading = false;
          });
        }

        // Navigator.of(context).pop();

        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }*/

  /* Future<void> _submitForm(BuildContext context, {DocumentSnapshot? userDoc}) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Query Firestore to check if the email already exists
        final emailQuery =
            await FirebaseFirestore.instance.collection('Users').where('email', isEqualTo: _emailController.text).get();

        if (emailQuery.docs.isNotEmpty && userDoc == null) {
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

        if (userDoc == null) {
          // Add new user if no existing email is found
          await FirebaseFirestore.instance.collection('Users').add({
            'adminId': widget.adminId,
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
            'pin': "",
            'isSwitchOn': false,
          });
          Navigator.of(context).pop();
        } else {
          // Update existing user
          await FirebaseFirestore.instance.collection('Users').doc(userDoc.id).update({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'isActive': _isActive,
          });
          Navigator.of(context).pop();
        }

        _usernameController.clear();
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
  }*/

  // Future<void> _submitForm(BuildContext context, {DocumentSnapshot? userDoc}) async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     String email = _emailController.text;
  //
  //     // Check if the email is already in Firestore
  //     QuerySnapshot emailQuery = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .where('email', isEqualTo: email)
  //         .get();
  //
  //     // Set isEmailValid based on whether email exists
  //     isEmailValid = emailQuery.docs.isEmpty || userDoc != null;
  //
  //     if (!isEmailValid) {
  //       // Re-run the form validation to show the error message
  //       _formKey.currentState!.validate();
  //       setState(() {
  //         isLoading = false;
  //       });
  //       return;
  //     }
  //
  //     // Proceed with submission logic if email is valid
  //     if (userDoc == null) {
  //       await FirebaseFirestore.instance.collection('Users').add({
  //         'adminId': widget.adminId,
  //         'username': _usernameController.text,
  //         'email': _emailController.text,
  //         'password': _passwordController.text,
  //         'isActive': _isActive,
  //         'pin': "",
  //         'isSwitchOn': false,
  //       });
  //     } else {
  //       await FirebaseFirestore.instance.collection('Users').doc(userDoc.id).update({
  //         'username': _usernameController.text,
  //         'email': _emailController.text,
  //         'password': _passwordController.text,
  //         'isActive': _isActive,
  //       });
  //     }
  //
  //     _usernameController.clear();
  //     _emailController.clear();
  //     _passwordController.clear();
  //
  //     setState(() {
  //       isLoading = false;
  //     });
  //
  //     Navigator.of(context).pop();
  //   }
  // }

/*  void _showAddEditDialog(BuildContext context, {DocumentSnapshot? userDoc}) {
    if (userDoc != null) {
        _usernameController.text = userDoc.data().toString().contains('username') ? userDoc['username'] : '';
      _emailController.text = userDoc.data().toString().contains('email') ? userDoc['email'] : '';
      _passwordController.text = userDoc.data().toString().contains('password') ? userDoc['password'] : '';
      _isActive = userDoc.data().toString().contains('isActive') ? userDoc['isActive'] : true;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            userDoc == null ? 'Add Employee' : 'Edit Employee',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    focusNode: usernameFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(mobileFocusNode);
                    },
                    style: const TextStyle(color: Colors.black),
                    decoration: _buildInputDecoration(
                      'Employee Name',
                      Icons.person,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
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
                      'Employee Mobile No.',
                      Icons.phone,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter a mobile no.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    focusNode: emailFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: _buildInputDecoration(
                      'Email',
                      Icons.email,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email';
                      }
                      // if (!value.contains('@gmail.com')) {
                      //   return 'Enter a valid email (example@gmail.com)';
                      // }
                      if (alreadyRegistered) {
                        return 'Email is already registered';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    focusNode: passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status:', style: TextStyle(color: Colors.black)),
                      GestureDetector(
                        onTap: () {
                          // setState(() {
                          //   _isActive = !_isActive;
                          // });
                        },
                        child: Row(
                          children: [
                            Text('Active', style: TextStyle(color: Colors.black)),
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
                          // setState(() {
                          //   _isActive = !_isActive;
                          // });
                        },
                        child: Row(
                          children: [
                            Text('Inactive', style: TextStyle(color: Colors.black)),
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
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(themecolor),
                          foregroundColor: MaterialStateProperty.all(kwhite),
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 50))),
                      onPressed: isLoading
                          ? null
                          : () {
                              // Navigator.of(context).pop();
                              _submitForm(context, userDoc: userDoc);
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(userDoc == null ? 'Create' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }*/

  DeleteController controller = Get.put(DeleteController());

  Future<void> _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot userDoc, String username) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Employee'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this employee "${username}" ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                deleteEmployee(userDoc.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteEmployee(String userId) async {
    controller.showLoader.value = true;
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).delete();
      Get.snackbar('Success', 'Employee deleted successfully!', snackPosition: SnackPosition.BOTTOM);
    } catch (error) {
      Get.snackbar('Error', 'Failed to delete employee: $error', snackPosition: SnackPosition.BOTTOM);
    } finally {
      controller.showLoader.value = false;
    }
  }

  // final constants = Const();

  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kgrey,
      appBar: AppBar(
        backgroundColor: themecolor,
        title: Obx(() => Text(
              '${loadController.siteLable.value}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite
                  // backgroundColor: Color(0xff0393f4),
                  ),
            )),
        actions: [
          IconButton(
            onPressed: () {
              // _showAddEditDialog(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddEmployeeScreen(adminId: widget.adminId)));
            },
            icon: Icon(Icons.person_add_alt_1),
          ),
        ],
        iconTheme: IconThemeData(color: kwhite),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_currentUserIsActive != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Your status: ${_currentUserIsActive! ? 'Active' : 'Inactive'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _currentUserIsActive! ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .where('adminId', isEqualTo: widget.adminId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // if (!snapshot.hasData) {
                    //   return Center(child: CircularProgressIndicator(
                    //     valueColor:
                    //     AlwaysStoppedAnimation<Color>(Colors.white),
                    //   ));
                    // } else if (snapshot.data!.docs.isEmpty) {
                    //   return Center(
                    //     child: Text("No Employee Yet Created 😑😶 \n Try Creating one.",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.w500),),
                    //   );
                    // }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                      ));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No Employee Yet Created 😑😶 \n Try Creating one.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot userDoc = snapshot.data!.docs[index];

                        _checkAndUpdateEmployeeDoc(userDoc.id);

                        return Card(
                          color: kwhite,
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            tileColor: kwhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: Text(
                                userDoc.data().toString().contains('username') ? userDoc['username'] : 'No username'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userDoc.data().toString().contains('email') ? userDoc['email'] : 'No email'),
                                SizedBox(height: 8), // Add this line to add space
                                Container(
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: userDoc.data().toString().contains('isActive')
                                        ? userDoc['isActive']
                                            ? Colors.green[700]
                                            : Colors.red[700]
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    userDoc.data().toString().contains('isActive')
                                        ? userDoc['isActive']
                                            ? 'Active'
                                            : 'Inactive'
                                        : 'No status',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.grey),
                                  onPressed: () {
                                    // _showAddEditDialog(context, userDoc: userDoc);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddEmployeeScreen(userDoc: userDoc, adminId: widget.adminId)));
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () {
                                    String username = userDoc.data().toString().contains('username')
                                        ? userDoc['username']
                                        : 'Employee name not found';
                                    _showDeleteConfirmationDialog(context, userDoc, username);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => EmployeeDetailsScreen(userDoc: userDoc),
                              //   ),
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminEmployeeScreen(
                                    userId: userDoc.id,
                                    userDoc: userDoc,
                                    initialIndex: 0,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Obx(() => controller.showLoader.isTrue
              ? Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 100),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        border: Border.all(color: themecolor, width: 1)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Deleting Employee...",
                          style: TextStyle(color: themecolor),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CircularProgressIndicator(
                          color: themecolor,
                        )
                      ],
                    ),
                  ),
                )
              : SizedBox()),
        ],
      ),
    );
  }

  Future<void> _checkAndUpdateEmployeeDoc(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final userDoc = await docRef.get();

      if (userDoc.exists) {
        final data = userDoc.data();

        // Check if employee_logo exists
        if (data != null && (!data.containsKey('employee_logo') || data['employee_logo'] == '')) {
          await docRef.update({'employee_logo': ''});
        }
      }
    } catch (e) {
      print('Error checking/updating employee doc: $e');
    }
  }
}
