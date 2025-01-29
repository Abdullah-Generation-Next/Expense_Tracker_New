import 'package:email_validator/email_validator.dart';
import 'package:etmm/const/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
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
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 50),
                    TextFormField(
                      controller: emailController,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(labelText: 'Email'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) {
                        if (email == null || email.isEmpty) {
                          return 'Email cannot be empty';
                        } else if (!EmailValidator.validate(email)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 80),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themecolor,
                        minimumSize: Size.fromHeight(60),
                      ),
                      icon: Icon(
                        Icons.email_outlined,
                        color: kwhite,
                        size: 28,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 20, color: kwhite),
                        ),
                      ),
                      onPressed: resetPassword,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*Future<void> resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ));
      },
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      Navigator.of(context).pop(); // Dismiss the loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset Email Sent'),
            content: Text('Go to your email to reset your password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      Navigator.of(context).pop(); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An unknown error occurred')),
      );
    } catch (e) {
      print(e);
      Navigator.of(context).pop(); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unknown error occurred')),
      );
    }
  }*/

  Future<void> resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      Navigator.of(context).pop(); // Dismiss the loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset Email Sent'),
            content: Text('Go to your email to reset your password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      Navigator.of(context).pop(); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An unknown error occurred')),
      );
    } catch (e) {
      print(e);
      Navigator.of(context).pop(); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unknown error occurred')),
      );
    }
  }
}
