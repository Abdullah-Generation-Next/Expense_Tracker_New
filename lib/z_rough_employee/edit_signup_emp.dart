import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../const/const.dart';

class EmpEditProfilePage extends StatefulWidget {
  const EmpEditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EmpEditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? userId = _getCurrentUserId();
        if (userId != null) {
          // Get the current user document from Firestore
          final currentUserDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

          // Update the fields of the user document
          await currentUserDoc.reference.update({
            // 'username': _userNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'password': _passwordController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          // Handle case where user is not authenticated
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not authenticated')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _getCurrentUserId() {
    // Get the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is authenticated
    if (user != null) {
      // If the user is authenticated, return the user's UID
      return user.uid;
    } else {
      // If the user is not authenticated, return null
      return null;
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.black),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Login',
          style: TextStyle(fontWeight: FontWeight.bold, color: kwhite),
        ),
        backgroundColor: themecolor,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 20.0),
              // TextFormField(
              //   controller: _userNameController,
              //   keyboardType: TextInputType.name,
              //   style: const TextStyle(color: Colors.black),
              //   decoration: _buildInputDecoration('Username', Icons.person),
              //   validator: (value) =>
              //   value!.isEmpty ? 'Enter your username' : null,
              // ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black),
                decoration: _buildInputDecoration('Email', Icons.email),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your email';
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
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (!RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9]+)$').hasMatch(value)) {
                    return 'Password must contain at least one number or character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _submitForm(context),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
