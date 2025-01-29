import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PasswordResetPage extends StatefulWidget {
  final String resetToken;

  const PasswordResetPage({Key? key, required this.resetToken}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Query Firestore to find the reset token
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('password_resets')
            .where('token', isEqualTo: widget.resetToken)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          QueryDocumentSnapshot resetDoc = querySnapshot.docs.first;
          var resetData = resetDoc.data() as Map<String, dynamic>;
          // Check if the token is expired
          if (resetData['expiry'].toDate().isAfter(DateTime.now())) {
            // Update the password in the Admin collection
            await FirebaseFirestore.instance
                .collection('Admin')
                .where('email', isEqualTo: resetData['email'])
                .limit(1)
                .get()
                .then((adminQuery) {
              if (adminQuery.docs.isNotEmpty) {
                adminQuery.docs.first.reference.update({
                  'password': _passwordController.text,
                });
              }
            });
            // Delete the reset token
            await resetDoc.reference.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password reset successful')),
            );
            Navigator.pop(context); // Go back to login screen
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reset token expired')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid reset token')),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
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
                    return 'Enter your new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
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
                    return 'Confirm your new password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
