import 'package:etmm/const/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminChangePassword extends StatefulWidget {
  final DocumentSnapshot userDoc;
  const AdminChangePassword({
    super.key,
    required this.userDoc,
  });

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<AdminChangePassword> {
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

  // Future<void> _changePassword() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     // String trimmedPassword = _oldPasswordController.text.trim();
  //     // final userDocData = widget.userDoc.data() as Map<String, dynamic>;
  //     //
  //     // QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Admin').where(userDocData['password'], isEqualTo: trimmedPassword).limit(1).get();
  //     // print("Document Data: ${userDocData}");
  //     //
  //     // if (querySnapshot.docs.isNotEmpty) {
  //     //   DocumentSnapshot userDoc = querySnapshot.docs.first;
  //     //   // DocumentSnapshot userDoc = widget.userDoc.data() as Map<String, dynamic>;
  //     //
  //     //   if (_newPasswordController.text == _confirmPasswordController.text) {
  //     //     if (_newPasswordController.text.length >= 6) {
  //     //       await userDoc.reference.update({
  //     //         'password': _newPasswordController.text,
  //     //       });
  //
  //     try {
  //       QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Admin').where('password', isEqualTo: _oldPasswordController.text).limit(1).get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         DocumentSnapshot userDoc = querySnapshot.docs.first;
  //
  //         if (_newPasswordController.text == _confirmPasswordController.text) {
  //           if (_newPasswordController.text.length >= 6) {
  //             await userDoc.reference.update({
  //               'password': _newPasswordController.text,
  //             });
  //
  //             _oldPasswordController.clear();
  //             _newPasswordController.clear();
  //             _confirmPasswordController.clear();
  //
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Password changed successfully')),
  //             );
  //
  //             Navigator.of(context).pop();
  //           } else {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                   content: Text('Password must be at least 6 characters')),
  //             );
  //           }
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //                 content:
  //                     Text('New password and confirm password do not match')),
  //           );
  //         }
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Current password is incorrect')),
  //         );
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error changing password: $e')),
  //       );
  //     } finally {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  /*Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current authenticated user
        User? user = FirebaseAuth.instance.currentUser;

        // Check if the user is authenticated and the old password is correct
        if (user != null) {
          // Re-authenticate the user with the old password
          String email = user.email!;
          String oldPassword = _oldPasswordController.text.trim();

          AuthCredential credential = EmailAuthProvider.credential(email: email, password: oldPassword);

          await user.reauthenticateWithCredential(credential);

          // Update the password in Firebase Authentication
          await user.updatePassword(_newPasswordController.text.trim());

          // Update the password in Firestore
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('Admin')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot userDoc = querySnapshot.docs.first;

            await userDoc.reference.update({
              'password': _newPasswordController.text.trim(),
            });

            // Clear the input fields
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully')),
            );

            // Optionally, log out the user or navigate them back to the login page
            Navigator.of(context).pop();
          }
        } else {
          // Handle user not logged in (shouldn't usually happen)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle authentication-related errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${e.message} Kindly enter correct current password')),
        );
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
  }*/

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current authenticated user
        User? user = FirebaseAuth.instance.currentUser;

        // Check if the user is authenticated
        if (user != null) {
          String email = user.email!;
          String oldPassword = _oldPasswordController.text.trim();
          String newPassword = _newPasswordController.text.trim();

          // Check if the new password is different from the old password
          if (oldPassword == newPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New password cannot be the same as the old password')),
            );
            return; // Exit the method if the passwords are the same
          }

          // Re-authenticate the user with the old password
          AuthCredential credential = EmailAuthProvider.credential(email: email, password: oldPassword);
          await user.reauthenticateWithCredential(credential);

          // Update the password in Firebase Authentication
          await user.updatePassword(newPassword);

          // Update the password in Firestore
          QuerySnapshot querySnapshot =
              await FirebaseFirestore.instance.collection('Admin').where('email', isEqualTo: email).limit(1).get();

          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot userDoc = querySnapshot.docs.first;

            await userDoc.reference.update({
              'password': newPassword,
            });

            // Clear the input fields
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully')),
            );

            // Optionally, log out the user or navigate them back to the login page
            Navigator.of(context).pop();
          }
        } else {
          // Handle user not logged in (shouldn't usually happen)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle authentication-related errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${e.message} Kindly enter correct current password')),
        );
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
  }

  InputDecoration _buildInputDecoration(String label, bool isVisible, VoidCallback onPressed) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                  decoration: _buildInputDecoration(
                    'Current Password',
                    _showPassword,
                    () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                  decoration: _buildInputDecoration(
                    'New Password',
                    _showNewPassword,
                    () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                  obscureText: !_showNewPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                  decoration: _buildInputDecoration(
                    'Confirm Password',
                    _showConfirmPassword,
                    () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  obscureText: !_showConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill the field';
                    } else if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      // ignore: deprecated_member_use
                      backgroundColor: MaterialStatePropertyAll(Color(0xff0558b4)),
                      // ignore: deprecated_member_use
                      padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
                    ),
                    onPressed: _isLoading ? null : () => _changePassword(),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
