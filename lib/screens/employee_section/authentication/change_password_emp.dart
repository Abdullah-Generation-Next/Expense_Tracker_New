import 'package:etmm/const/const.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeChangePassword extends StatefulWidget {
  final DocumentSnapshot? userDoc;
  final String userId;
  const EmployeeChangePassword({super.key, this.userDoc, required this.userId});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<EmployeeChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  final FocusNode oldPasswordFocusNode = FocusNode();
  final FocusNode newPasswordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  /*Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('password', isEqualTo: _oldPasswordController.text)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        await userDoc.reference.update({
          'password': _newPasswordController.text,
        });

        // Clear the text fields after password change
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );

        // Navigate to home page
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current password is incorrect')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing password: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }*/

  /* Second Last Updated
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_oldPasswordController.text == _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password cannot be the same as the old password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('password', isEqualTo: _oldPasswordController.text)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        await userDoc.reference.update({
          'password': _newPasswordController.text,
        });

        // Clear the text fields after password change
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );

        // Navigate to home page
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current password is incorrect')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing password: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  */

  Future<void> _changePassword(String userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_oldPasswordController.text == _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password cannot be the same as the old password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch the user's document using the provided userId
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        // Verify if the current password matches
        if (data['password'] == _oldPasswordController.text) {
          // Update the password
          await userDoc.reference.update({
            'password': _newPasswordController.text,
          });

          // Clear the input fields after successful password change
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );

          // Navigate to the previous screen or logout
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current password is incorrect')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing password: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
      suffixIcon: label == 'Current Password'
          ? IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            )
          : label == 'New Password'
              ? IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(
                    _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kgrey,
      appBar: AppBar(
        backgroundColor: themecolor,
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kwhite),
        ),
        iconTheme: IconThemeData(color: kwhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _oldPasswordController,
                  textInputAction: TextInputAction.next,
                  focusNode: oldPasswordFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(newPasswordFocusNode);
                  },
                  decoration: _buildInputDecoration('Current Password'),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please fill the field';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _newPasswordController,
                  textInputAction: TextInputAction.next,
                  focusNode: newPasswordFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                  },
                  decoration: _buildInputDecoration('New Password'),
                  obscureText: !_showNewPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please fill the field';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  decoration: _buildInputDecoration('Confirm Password'),
                  obscureText: !_showConfirmPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please fill the field';
                    } else if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Container(
                  height: 60,
                  child: ElevatedButton(
                    // ignore: deprecated_member_use
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xff0558b4))),
                    onPressed: _isLoading ? null : () => _changePassword(widget.userId),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
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
