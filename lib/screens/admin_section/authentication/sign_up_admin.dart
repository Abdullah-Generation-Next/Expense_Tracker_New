import 'package:etmm/screens/admin_section/authentication/login_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../const/const.dart';
import '../../../services/shared_pref.dart';
import '../home/admin_root_screen_navigation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode companyFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  InputDecoration _buildInputDecoration(String label, IconData icon, {required MaterialColor color}) {
    return InputDecoration(
      counterText: "",
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.grey),
    );
  }

  String generateReferralCode(String adminId) {
    return adminId.substring(0, 6).toUpperCase();
  }

  Future<void> _signup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Get the newly created user
        User? user = userCredential.user;

        if (user != null) {
          final newAdminRef = FirebaseFirestore.instance.collection('Admin').doc(user.uid);

          String referralCode = generateReferralCode(user.uid);

          // Save additional user details in Firestore
          await newAdminRef.set({
            'username': _usernameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'password': _passwordController.text,
            'company_name': _companyController.text,
            'company_address': _companyAddressController.text,
            'pin': '',
            'isSwitchOn': false,
            'company_logo': '',
            'referralCode': referralCode,
            'allow_date_to_change': 'Yes',
            'is_auto_approve': 'Yes',
            'site_label': 'General',
            'show_delete_button': 'Yes',
          });

          // Save admin ID to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('adminId', user.uid);

          SharedPref.save(value: _emailController.text, prefKey: PrefKey.adminEmail);
          SharedPref.save(value: _passwordController.text, prefKey: PrefKey.adminPassword);

          print(SharedPref.get(prefKey: PrefKey.adminEmail));
          print(SharedPref.get(prefKey: PrefKey.adminPassword));
          // Fetch the user document
          DocumentSnapshot userDoc = await newAdminRef.get();
          print(userDoc);

          setState(() {
            _isLoading = false;
          });

          // Navigate to AdminHome
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AdminRootScreen(
                adminId: user.uid,
                userDoc: userDoc,
                userId: user.uid,
                initialIndex: 0,
              ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Create an Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _usernameController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  decoration: _buildInputDecoration('Username', Icons.person, color: Colors.grey),
                  validator: (value) => value!.isEmpty ? 'Enter your username' : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  decoration: _buildInputDecoration('Email', Icons.email, color: Colors.grey),
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
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  maxLength: 10,
                  decoration: _buildInputDecoration('Phone Number', Icons.phone_android, color: Colors.grey),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  focusNode: passwordFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(companyFocusNode);
                  },
                  textInputAction: TextInputAction.next,
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
                    filled: true, // Ensures the text field background is filled
                    fillColor: Colors.white, // Sets the fill color to white
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue), // Sets the underline color when focused
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Sets the underline color when enabled
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
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _companyController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.text,
                  focusNode: companyFocusNode,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  decoration: _buildInputDecoration('Company', Icons.business, color: Colors.grey),
                  validator: (value) => value!.isEmpty ? 'Enter your company name' : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _companyAddressController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.black),
                  decoration: _buildInputDecoration('Company Address', Icons.location_on, color: Colors.grey),
                  validator: (value) => value!.isEmpty ? 'Enter your company address' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      // ignore: deprecated_member_use
                      backgroundColor: MaterialStatePropertyAll(themecolor),
                      // ignore: deprecated_member_use
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                    ),
                    onPressed: _isLoading ? null : () => _signup(context),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Signup',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: kwhite,
                            )),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _navigateToLogin(context),
                    child: RichText(
                      textAlign: TextAlign.center,
                      // textScaleFactor: 1.5,
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w400
                            // fontWeight: FontWeight.bold,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Login',
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
                    //   "Already have an account? Login",
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     color: theme3,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
