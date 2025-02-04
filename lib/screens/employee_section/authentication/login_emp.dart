import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/employee_section/home/employee_root_screen_navigation.dart';
import 'package:etmm/screens/root_app.dart';
import 'package:flutter/material.dart';
import 'package:etmm/services/shared_pref.dart';
import 'package:get/get.dart';
import '../../../getx_controller/load_excel_controller.dart';
import '../setup_pin/confirm_pin.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({Key? key}) : super(key: key);

  @override
  _EmployeeLoginPageState createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final constants = Const();

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('Email: ${_emailController.text}');
        print('Password: ${_passwordController.text}');

        // Check if a document with the provided email exists in Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: _emailController.text)
            .limit(1)
            .get();

        print('Query snapshot: $querySnapshot');

        if (querySnapshot.docs.isNotEmpty) {
          // Retrieve the first document (there should be only one matching document)
          DocumentSnapshot userDoc = querySnapshot.docs.first;

          print('User document: $userDoc');

          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          if (!userData.containsKey('employee_logo') || userData['employee_logo'] == '') {
            await FirebaseFirestore.instance.collection('Users').doc(userDoc.id).update({'employee_logo': ''});
          }

          DocumentSnapshot<Map<String, dynamic>> updatedUserDoc =
              await FirebaseFirestore.instance.collection('Users').doc(userDoc.id).get();

          // Check if the entered password matches the stored password
          if (updatedUserDoc['password'] == _passwordController.text) {
            // Check if the user is active
            if (updatedUserDoc['isActive']) {
              // Save email and password in Shared Preferences
              await SharedPref.save(value: _emailController.text, prefKey: PrefKey.empEmail);
              await SharedPref.save(value: _passwordController.text, prefKey: PrefKey.empPassword);

              print(SharedPref.get(prefKey: PrefKey.empEmail));
              print(SharedPref.get(prefKey: PrefKey.empPassword));
              print(updatedUserDoc);

              await constants.loadAdminFromFirestore(updatedUserDoc['adminId']).then((value) async {
                await constants.ensureEmpDefaultFields(updatedUserDoc.id);
                if (updatedUserDoc['pin'] == null || updatedUserDoc['pin'] == "") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeRootScreen(
                        userId: updatedUserDoc.id,
                        userDoc: updatedUserDoc,
                        initialIndex: 0,
                      ),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeConfirmPin(
                        isFromSetPin: true,
                        userDoc: updatedUserDoc,
                      ),
                    ),
                  );
                }
              });

              // Navigate to the employee home page
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => Home(
              //             userId: userDoc.id,
              //             userDoc: userDoc,
              //           )),
              // );
            } else {
              // Show a message if the user's status is inactive
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Your Status is inactive, contact the Administrator')),
              );
            }
          } else {
            // Show an error if the entered password is incorrect
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You entered a wrong email or password')),
            );
          }
        } else {
          // Show a message if no document with the provided email is found
          ScaffoldMessenger.of(context).showSnackBar(
            // SnackBar(content: Text('Your Status is inactive, contact the Administrator')),
            SnackBar(content: Text('Entered username or password does not exists')),
          );
        }
      } catch (e) {
        // Show an error if there's any exception during the process
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: Colors.grey, // Set the color of the icon to grey
      ),
      suffixIcon: icon == Icons.lock
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey, // Set the color of the visibility icon to grey
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RootApp(),
      ),
    );
    return Future.value(false); // Prevent default pop behavior
  }

  void _forgotPassword() {
    // Implement the forgot password logic here
    // For example, navigate to a password recovery page or show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Forgot Password',
          textAlign: TextAlign.center,
        ),
        content: const Text('Please contact the administrator to reset your password.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: kgrey,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0), // Add padding to the top
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              '${loadController.siteLable.value /*.split(" ")[0]*/} Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _buildInputDecoration('Email', Icons.email),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter your email';
                              }
                              if (value != value.toLowerCase()) {
                                return 'Email must be in lowercase';
                              }
                              // if (!value.contains('@gmail.com')) {
                              //   return 'Enter a valid email (example@gmail.com)';
                              // }
                              if (!value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: _buildInputDecoration('Password', Icons.lock),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              // if (!RegExp(
                              //         r'^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9]+)$')
                              //     .hasMatch(value)) {
                              //   return 'Password must contain at least one number or character';
                              // }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5.0), // Add space between password field and link
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                // ignore: deprecated_member_use
                                backgroundColor: MaterialStateProperty.resolveWith((states) => Color(0xff0558b4)),
                              ),
                              onPressed: _isLoading ? null : () => _submitForm(context),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, height: 2),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10.0,
                left: 10.0,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_circle_left,
                    color: themecolor,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RootApp(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
