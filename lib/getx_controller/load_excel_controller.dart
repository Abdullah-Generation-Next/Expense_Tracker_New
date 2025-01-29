import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/shared_pref.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

class LoadExcelController extends GetxController {
  RxBool loadingDialog = false.obs;
}

class DeleteController extends GetxController {
  RxBool showLoader = false.obs;
}

class LoadAllFieldsController extends GetxController {
  RxString allowDateToChange = "".obs;
  RxString isAutoApprove = "".obs;
  RxString siteLable = "".obs;
  RxString showDeleteButton = "".obs;

  RxString username = "".obs;
  RxString email = "".obs;
  RxString phone = "".obs;
  RxString companyName = "".obs;
  RxString companyAddress = "".obs;
  RxString companyLogo = "".obs;
  RxString referralCode = "".obs;

  RxList<String> categoryLists = <String>[].obs;

  TextEditingController lableController = TextEditingController();

  Future<void> updateSiteLabel(String newLabel) async {
    siteLable.value = newLabel;
    try {
      final adminEmail = SharedPref.get(prefKey: PrefKey.adminEmail);
      if (adminEmail != null) {
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('Admin').where('email', isEqualTo: adminEmail).get();

        if (querySnapshot.docs.isNotEmpty) {
          String adminId = querySnapshot.docs.first.id;
          await FirebaseFirestore.instance.collection('Admin').doc(adminId).update({'site_label': newLabel});

          lableController.text = newLabel;
          print(lableController.text);

          print("Firestore updated: site_label set to $newLabel");
        }
      }
    } catch (e) {
      print("Error updating site_label: $e");
    }
  }

  RxBool isAdminPinEnabled = false.obs;
  RxBool loadAdminSwitch = false.obs;

  Future<bool> getAdminSavedPinFromFirestore(userId) async {
    loadAdminSwitch.value = true;
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (adminDoc.exists && adminDoc.data() != null) {
        return (adminDoc.data() as Map<String, dynamic>)['isSwitchOn'] == true;
      }
    } catch (e) {
      print("Error fetching PIN: $e");
    } finally {
      loadAdminSwitch.value = false;
    }
    return false;
  }

  Future<void> updateAdminPinStatusFromFirestore(adminId) async {
    bool isSwitchOn = await getAdminSavedPinFromFirestore(adminId);
    // setState(() {
    isAdminPinEnabled.value = isSwitchOn;
    // });
  }

  RxBool isEmployeePinEnabled = false.obs;
  RxBool loadEmployeeSwitch = false.obs;

  Future<bool> getEmployeeSavedPinFromFirestore(userId) async {
    loadEmployeeSwitch.value = true;
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (adminDoc.exists && adminDoc.data() != null) {
        return (adminDoc.data() as Map<String, dynamic>)['isSwitchOn'] == true;
      }
    } catch (e) {
      print("Error fetching PIN: $e");
    } finally {
      loadEmployeeSwitch.value = false;
    }
    return false;
  }

  Future<void> updateEmployeePinStatusFromFirestore(adminId) async {
    bool isSwitchOn = await getEmployeeSavedPinFromFirestore(adminId);
    // setState(() {
    isEmployeePinEnabled.value = isSwitchOn;
    // });
  }

  RxBool locationLoading = false.obs;

  /*Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }*/

  /*Future<String> getPlaceName(double latitude, double longitude) async {
    List<Placemark> placeMarks =
    await placemarkFromCoordinates(latitude, longitude);
    return placeMarks.first.name ?? 'Unknown Place';
  }*/

  // Future<Position?> getCurrentLocation() async {
  //   try {
  //     locationLoading.value = true;
  //
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       await Geolocator.openLocationSettings();
  //       locationLoading.value = false;
  //       return null;
  //     }
  //
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.deniedForever ||
  //           permission == LocationPermission.denied) {
  //         locationLoading.value = false;
  //         return null;
  //       }
  //     }
  //
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     locationLoading.value = false;
  //     return position;
  //   } catch (e) {
  //     locationLoading.value = false;
  //     print("Error fetching location: $e");
  //     return null;
  //   }
  // }
  //
  // Future<String> getPlaceName(double latitude, double longitude) async {
  //   try {
  //     List<Placemark> placeMarks =
  //     await placemarkFromCoordinates(latitude, longitude);
  //     return placeMarks.first.name ?? 'Unknown Place';
  //   } catch (e) {
  //     print("Error fetching place name: $e");
  //     return 'Unknown Place';
  //   }
  // }
}

class AdminProfileController extends GetxController {
  RxString finalImageUrl = ''.obs;
  Rx<File?> image = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> getImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile != null) {
        image.value = File(pickedFile.path);
        print('Image Selected: ${pickedFile.path}');
      } else {
        print('No Image Selected');
        Fluttertoast.showToast(msg: 'No Image Selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      Fluttertoast.showToast(msg: 'Error picking image $e');
    }
  }

  @override
  void onInit() {
    image.value = null;
    super.onInit();
  }

}

class EmployeeProfileController extends GetxController {
  RxString finalImageUrl = ''.obs;
  Rx<File?> image = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> getImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile != null) {
        image.value = File(pickedFile.path);
        print('Image Selected: ${pickedFile.path}');
      } else {
        print('No Image Selected');
        Fluttertoast.showToast(msg: 'No Image Selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      Fluttertoast.showToast(msg: 'Error picking image $e');
    }
  }

  @override
  void onInit() {
    image.value = null;
    super.onInit();
  }

}
