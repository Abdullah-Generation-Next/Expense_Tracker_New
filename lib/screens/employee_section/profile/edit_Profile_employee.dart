import 'dart:io';
import 'package:etmm/const/const.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../getx_controller/load_excel_controller.dart';

class EmployeeEditProfilePage extends StatefulWidget {
  final String userId;

  const EmployeeEditProfilePage({super.key, required this.userId});

  @override
  _EmployeeEditProfilePageState createState() => _EmployeeEditProfilePageState();
}

class _EmployeeEditProfilePageState extends State<EmployeeEditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isLoading1 = false;
  bool isLoading = true;

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // controller.onInit();
    controller.image.value = null;
    _loadProfileData();
  }

  EmployeeProfileController controller = Get.put(EmployeeProfileController());

  Future<void> _loadProfileData() async {
    try {
      if (kDebugMode) {
        print('Loading profile data for adminId: ${widget.userId}');
      }
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();

      if (adminDoc.exists) {
        Map<String, dynamic>? data = adminDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _userNameController.text = data['username'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['mobile'] ?? '';
            controller.finalImageUrl.value = data['employee_logo'] ?? '';
            isLoading = false;
          });
          if (kDebugMode) {
            print('Profile data loaded successfully');
          }
          // setState(() {
          //   isLoading = false;
          // });
        } else {
          if (kDebugMode) {
            print('No profile data found for this admin.');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No profile data found for this admin.')),
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        if (kDebugMode) {
          print('No profile document found for this admin.');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No profile document found for this admin.')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile data: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userId).get();

        String employeeName = userDoc.data()?['username'] ?? 'UnknownAdmin';
        print(employeeName);

        if (controller.image.value != null) {
          if (controller.finalImageUrl.value != '') {
            final oldImageRef = FirebaseStorage.instance.refFromURL(controller.finalImageUrl.value);
            await oldImageRef.delete();
          }

          final compressedImagePath = controller.image.value!.absolute.path + '_compressed.jpg';
          final compressedImage = await FlutterImageCompress.compressAndGetFile(
            controller.image.value!.absolute.path,
            compressedImagePath,
            quality: 95,
          );

          if (compressedImage != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('Users/$employeeName/Logos/${DateTime.now().millisecondsSinceEpoch}');
            await storageRef.putFile(File(compressedImage.path));
            controller.finalImageUrl.value = await storageRef.getDownloadURL();
          } else {
            throw Exception('Image compression failed');
          }
        }

        print('Updating profile for adminId: ${widget.userId}');
        await FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({
          'username': _userNameController.text,
          'email': _emailController.text,
          'mobile': _phoneController.text,
          'employee_logo': controller.finalImageUrl.value,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        print('Profile updated successfully!');
        // Navigator.pop(context);
        Navigator.pop(context, {
          'employee_logo': controller.finalImageUrl.value,
          'username': _userNameController.text,
          'email': _emailController.text,
          'mobile': _phoneController.text,
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error updating profile: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> removeEmployeeLogo(String userId) async {
    setState(() {
      _isLoading1 = true;
    });
    try {
      final adminRef = FirebaseFirestore.instance.collection('Users').doc(userId);

      await adminRef.update({'employee_logo': ''});

      controller.finalImageUrl.value = '';
      controller.image.value = null;

      print("Employee logo removed successfully.");
      Fluttertoast.showToast(msg: 'Employee logo removed successfully.');
    } catch (e) {
      print("Error removing employee logo: $e");
      Fluttertoast.showToast(msg: 'Error removing employee logo.');
    } finally {
      setState(() {
        _isLoading1 = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      counterText: "",
      // floatingLabelBehavior: FloatingLabelBehavior.always,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      border: const UnderlineInputBorder(),
    );
  }

  Future<void> showIDUploadImageSourceDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Select Image Source',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                minLeadingWidth: -5,
                leading: Icon(CupertinoIcons.photo_fill, color: themecolor),
                title: Text(
                  'Select from Gallery',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                minLeadingWidth: -5,
                leading: Icon(CupertinoIcons.camera_fill, color: themecolor),
                title: Text('Take a Photo', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  controller.getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: kwhite),
        ),
        backgroundColor: themecolor,
        iconTheme: const IconThemeData(color: kwhite),
      ),
      body: isLoading
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.95,
              child: Center(
                  child: CircularProgressIndicator(
                color: themecolor,
              )))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 150, maxHeight: 150),
                        child: Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.expand,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Material(
                                elevation: 0,
                                shape: CircleBorder(side: BorderSide(width: 3, color: Colors.grey)),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.transparent,
                                child: Obx(
                                  () => controller.image.value != null
                                      ? Ink.image(
                                          image: FileImage(File(controller.image.value!.path).absolute),
                                          fit: BoxFit.contain,
                                          width: 220,
                                          height: 220,
                                          child: InkWell(
                                            radius: 0,
                                            onTap: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (_) => Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 50, right: 50),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            image:
                                                                FileImage(File(controller.image.value!.path).absolute),
                                                            fit: BoxFit.cover),
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : (controller.finalImageUrl.value != "")
                                          ? Ink.image(
                                              image: NetworkImage(controller.finalImageUrl.value),
                                              fit: BoxFit.contain,
                                              width: 150,
                                              height: 150,
                                              child: InkWell(
                                                radius: 0,
                                                onTap: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (_) => Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 50, right: 50),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: DecorationImage(
                                                                image: NetworkImage(controller.finalImageUrl.value),
                                                                fit: BoxFit.cover),
                                                          ),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(context);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () async {
                                                await showDialog(
                                                  context: context,
                                                  builder: (_) => Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 50, right: 50),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Container(
                                                          width: double.infinity,
                                                          height: 250,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.blueGrey,
                                                            // image: DecorationImage(
                                                            //     image: AssetImage("assets/images/profile.png"), fit: BoxFit.contain),
                                                          ),
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 175,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.blueGrey,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 75,
                                                ),
                                              ),
                                            ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: -40,
                              left: 70,
                              child: Tooltip(
                                message: 'Upload Employee Logo/Image',
                                child: RawMaterialButton(
                                  onPressed: () {
                                    // controller.getImage();
                                    showIDUploadImageSourceDialog(context);
                                  },
                                  elevation: 2,
                                  fillColor: Colors.white,
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.grey,
                                  ),
                                  padding: EdgeInsets.all(7.5),
                                  shape: CircleBorder(side: BorderSide(color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _userNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      focusNode: usernameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(phoneFocusNode);
                      },
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration('Username', Icons.person),
                      validator: (value) => value!.isEmpty ? 'Enter your username' : null,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      // focusNode: emailFocusNode,
                      // onFieldSubmitted: (_) {
                      //   FocusScope.of(context).requestFocus(phoneFocusNode);
                      // },
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                      onTap: () {
                        Fluttertoast.showToast(msg: "You cannot edit your email ID.");
                      },
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
                      controller: _phoneController,
                      textInputAction: TextInputAction.done,
                      focusNode: phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(color: Colors.black),
                      decoration: _buildInputDecoration('Phone Number', Icons.phone_android),
                      maxLength: 10,
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
                        onPressed: _isLoading ? null : () => _submitForm(context),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white, // Make sure the text color is white
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Obx(
                      () => controller.finalImageUrl.value != ''
                          ? Column(
                              children: [
                                const SizedBox(height: 20),
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
                                    onPressed: _isLoading1
                                        ? null
                                        : () {
                                            // controller.finalImageUrl.value = '';
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Remove Employee Logo'),
                                                content: Text('Are you sure you want to remove the Employee logo?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await removeEmployeeLogo(widget.userId);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Remove'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    child: Center(
                                      child: _isLoading1
                                          ? const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            )
                                          : const Text(
                                              'Remove Profile Photo',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
