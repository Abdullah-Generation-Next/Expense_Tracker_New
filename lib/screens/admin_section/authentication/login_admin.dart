import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/admin_section/authentication/forgot_password_admin.dart';
import 'package:etmm/screens/admin_section/setup_pin/confirm_pin.dart';
import 'package:etmm/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/admin_root_screen_navigation.dart';
import 'sign_up_admin.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        // Authenticate using Firebase Authentication
        // UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // If login is successful, retrieve user details from Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Admin')
            .where('email', isEqualTo: _emailController.text)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          QueryDocumentSnapshot userDoc = querySnapshot.docs.first;
          // var userData = userDoc.data() as Map<String, dynamic>;

          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          if (!userData.containsKey('company_logo') || userData['company_logo'] == '') {
            await FirebaseFirestore.instance.collection('Admin').doc(userDoc.id).update({'company_logo': ''});
          }

          DocumentSnapshot<Map<String, dynamic>> updatedUserDoc =
              await FirebaseFirestore.instance.collection('Admin').doc(userDoc.id).get();

          // Save user credentials and adminId to shared preferences
          SharedPref.save(value: _emailController.text, prefKey: PrefKey.adminEmail);
          SharedPref.save(value: _passwordController.text, prefKey: PrefKey.adminPassword);

          await updatePasswordInFirestore(_passwordController.text);

          print(SharedPref.get(prefKey: PrefKey.adminEmail));
          print(SharedPref.get(prefKey: PrefKey.adminPassword));
          print(updatedUserDoc);

          await constants.loadAdminFromFirestore(userDoc.id).then((value) {
            if (updatedUserDoc['pin'] == null || updatedUserDoc['pin'] == "") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminRootScreen(
                    userId: updatedUserDoc.id,
                    userDoc: updatedUserDoc,
                    adminId: updatedUserDoc.id,
                    initialIndex: 0,
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminConfirmPin(
                    isFromSetPin: true,
                    userDoc: updatedUserDoc,
                  ),
                ),
              );
            }
          });

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AdminHome(
          //       userDoc: userDoc,
          //       adminId: userDoc.id,
          //       userId: userCredential.user!.uid, // Use Firebase user ID
          //     ),
          //   ),
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email not found in Firestore.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle authentication errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.code[0].toUpperCase()}${e.code.substring(1)}'),
          ),
        );
        // if (e.code == 'user-not-found') {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('No user found for that email.')),
        //   );
        // } else if (e.code == 'wrong-password') {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Incorrect password.')),
        //   );
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Error: ${e.message}')),
        //   );
        // }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updatePasswordInFirestore(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('Admin').doc(user.uid).update({
          'password': newPassword,
        });

        print('Password updated in Firestore successfully');
      } else {
        print('No user is currently logged in');
      }
    } catch (e) {
      print('Error updating password in Firestore: $e');
    }
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 30.0),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Admin Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.email, color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter your email';
                            }
                            if (value != value.toLowerCase()) {
                              return 'Email must be in lowercase';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPassword()),
                          );
                        },
                        style: ButtonStyle(
                          // ignore: deprecated_member_use
                          overlayColor: MaterialStatePropertyAll(Colors.transparent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Spacer(),
                            const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              // ignore: deprecated_member_use
                              backgroundColor: MaterialStatePropertyAll(themecolor),
                              // ignore: deprecated_member_use
                              foregroundColor: MaterialStatePropertyAll(Colors.white),
                            ),
                            onPressed: _isLoading ? null : () => _submitForm(context),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Text('Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      // height: 2.5,
                                    )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () => _navigateToSignup(context),
                          child: RichText(
                            // textScaleFactor: 1.5,
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w400
                                  // fontWeight: FontWeight.bold,
                                  ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blue,
                                    // decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const Text(
                          //   "Don't have an account?",
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     color: Colors.blue,
                          //     // fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10.0,
                left: 5.0,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_circle_left,
                    color: themecolor,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
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
