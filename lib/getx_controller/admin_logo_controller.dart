// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../services/new_api.dart';
//
// class AdminLogoController extends GetxController {
//   RxBool loader = false.obs;
//
//   File? selectedImage;
//   final _picker = ImagePicker();
//
//   Future getImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
//
//     if (pickedFile != null) {
//       selectedImage = File(pickedFile.path);
//       update();
//
//       await updateProfileImage(profilePic: pickedFile.path);
//     } else {
//       print('No Image Selected');
//       Fluttertoast.showToast(msg: 'No Image Selected');
//     }
//   }
//
//   Future<void> updateProfileImage({String? profilePic}) async {
//     loader.value = true;
//     Map<String, dynamic> parameter = {
//       "customer_id": 35.toString(),
//     };
//     try {
//       print(parameter);
//
//       final response = await uploadProfileImage(
//         parameter: parameter,
//         profilePic: profilePic,
//       );
//
//       loader.value = false;
//       Fluttertoast.showToast(msg: response.message.toString());
//     } catch (error) {
//       loader.value = false;
//       Fluttertoast.showToast(msg: error.toString());
//       if (kDebugMode) {
//         print(error);
//       }
//     }
//   }
// }
