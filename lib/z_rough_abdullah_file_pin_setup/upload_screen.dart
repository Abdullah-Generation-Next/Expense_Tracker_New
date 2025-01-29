import 'dart:io';
import 'package:etmm/widget/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

// class _UploadScreenState extends State<UploadScreen> {
//   bool loading = false;
//
//   File? _image;
//
//   final picker = ImagePicker();
//
//   DatabaseReference databaseRef = FirebaseDatabase.instance.ref('Post');
//
//   firebase_storage.FirebaseStorage storage =
//       firebase_storage.FirebaseStorage.instance;
//
//   Future getImageGallery() async {
//     final pickedFile =
//         await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
//     setState(() {
//       if (pickedFile == null && _image == null) {
//         Utils().toastMessage('Image Not Selected');
//         loading = false;
//         print('No Image Picked');
//       } else {
//         _image = File(pickedFile!.path);
//       }
//     });
//   }

class _UploadScreenState extends State<UploadScreen> {
  bool loading = false;
  File? _image;
  final picker = ImagePicker();
  final storage = firebase_storage.FirebaseStorage.instance;

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Utils().toastMessage('Image Not Selected');
      }
    });
  }

  Future<String> uploadImageToFirebaseStorage() async {
    if (_image == null) {
      return ""; // Handle no image selected case
    }

    setState(() {
      loading = true;
    });

    try {
      final imageName = DateTime.now().millisecondsSinceEpoch.toString();
      final imageRef = storage.ref().child('Abdullah/$imageName.jpg');
      final uploadTask = imageRef.putFile(_image!.absolute);

      final snapshot = await uploadTask.whenComplete(() {
        // Fluttertoast.showToast(msg: "Image Uploaded Successfully");
      });
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print('Error uploading image: $error');
      Utils().toastMessage('Error Uploading Image');
      return "";
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Bill Photo : \n(Optional)",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
              ),
              // SizedBox(width: 10,),
              Center(
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    getImageGallery();
                  },
                  child: _image != null
                      ? Container(
                          height: 100,
                          width: 100,
                          child: Image.file(
                            _image!.absolute,
                            fit: BoxFit.cover,
                          ),
                          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                        )
                      : Center(
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Center(child: Icon(Icons.photo)),
                            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          ),
                        ),
                ),
              ),
              // SizedBox(width: 10,),
              /*RoundButton(
                  title: 'Upload',
                  loading: loading,
                  onTap: () async {
                    if (_image == null) {
                      Fluttertoast.showToast(
                          msg: "Please Select Image",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: themecolor,
                          textColor: kwhite,
                          fontSize: 15);
                      return;
                    }

                    final imageUrl = await uploadImageToFirebaseStorage();
                    if (imageUrl.isEmpty) {
                      setState(() {
                        loading = false;
                      });
                      return;
                    }
                  }),*/
            ],
          ),
        ],
      ),
    );
  }
}
