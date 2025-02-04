import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/shared_pref.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;

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
  RxBool deleteLoader = false.obs;

  Future<bool> getAdminSavedPinFromFirestore(adminId) async {
    loadAdminSwitch.value = true;
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();

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
    print(isAdminPinEnabled.value);
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
    print(isEmployeePinEnabled.value);
    // });
  }

  RxBool adminLocationLoading = false.obs;
  RxBool employeeLocationLoading = false.obs;

  Future<void> requestLocationPermission({required bool isAdmin, String? adminId, String? userId}) async {
    var status = await perm.Permission.location.status;
    if (!status.isGranted) {
      status = await perm.Permission.location.request();
    }

    if (status.isGranted) {
      getLocation(isAdmin: isAdmin, adminId: adminId, userId: userId);
    } else {
      Fluttertoast.showToast(msg: "Location permission denied");
      print('Location permission denied');
    }
  }

  RxString employeeLat = "".obs;
  RxString employeeLng = "".obs;

  RxString adminLat = "".obs;
  RxString adminLng = "".obs;

  RxString fullAdminAddress = "".obs;
  RxString fullEmployeeAddress = "".obs;

  Future<void> getLocation({required bool isAdmin, String? adminId, String? userId}) async {
    if (isAdmin) {
      adminLocationLoading.value = true;
    } else {
      employeeLocationLoading.value = true;
    }

    loc.Location location = loc.Location();

    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;
    loc.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    List<Placemark> placemarks =
        await placemarkFromCoordinates(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    Placemark placemark = placemarks.first;

    // Set location details in RxString
    String fullAddress =
        '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
    print(fullAddress);

    /*if (isAdmin) {
      adminLat.value = locationData.latitude?.toString() ?? '';
      adminLng.value = locationData.longitude?.toString() ?? '';
      adminLocationLoading.value = false;
      print("Admin Location: $fullAddress");
    } else {
      employeeLat.value = locationData.latitude?.toString() ?? '';
      employeeLng.value = locationData.longitude?.toString() ?? '';
      employeeLocationLoading.value = false;
      print("Employee Location: $fullAddress");
    }*/

    if (isAdmin) {
      // Admin location logic
      adminLat.value = locationData.latitude?.toString() ?? '';
      adminLng.value = locationData.longitude?.toString() ?? '';

      // Fetch Admin document from Firestore
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();

      if (adminDoc.exists) {
        Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
        if (adminData.containsKey('lat') && adminData.containsKey('lng') && adminData.containsKey('place')) {
          // Update the fields if they exist
          await adminDoc.reference.update({
            'lat': adminLat.value,
            'lng': adminLng.value,
            'place': fullAddress,
          });
        } else {
          // Create new fields if they don't exist
          await adminDoc.reference.set({
            'lat': adminLat.value,
            'lng': adminLng.value,
            'place': fullAddress,
          }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
        }
      }

      adminLocationLoading.value = false;
      fullAdminAddress.value = fullAddress;
      print("Admin Location: $fullAddress");
    } else {
      // Employee location logic
      employeeLat.value = locationData.latitude?.toString() ?? '';
      employeeLng.value = locationData.longitude?.toString() ?? '';

      // Fetch Employee document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('lat') && userData.containsKey('lng') && userData.containsKey('place')) {
          // Update the fields if they exist
          await userDoc.reference.update({
            'lat': employeeLat.value,
            'lng': employeeLng.value,
            'place': fullAddress,
          });
        } else {
          // Create new fields if they don't exist
          await userDoc.reference.set({
            'lat': employeeLat.value,
            'lng': employeeLng.value,
            'place': fullAddress,
          }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
        }
      }

      employeeLocationLoading.value = false;
      fullEmployeeAddress.value = fullAddress;
      print("Employee Location: $fullAddress");
    }
  }

  var userCount = 0.obs;

  void fetchUserCount(String adminId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('adminId', isEqualTo: adminId) // Replace with your adminId logic
          .get();

      userCount.value = querySnapshot.size; // Update observable
    } catch (e) {
      print("Error fetching user count: $e");
    }
  }
}

class AdminProfileController extends GetxController {
  RxString finalImageUrl = ''.obs;
  Rx<File?> image = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        image.value = File(pickedFile.path);
        print('Image Selected: ${pickedFile.path}');
      } else {
        print('No Image Selected');
        Fluttertoast.showToast(msg: 'No Image Selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      Fluttertoast.showToast(msg: 'Error picking image: $e');
    }
  }
}

class EmployeeProfileController extends GetxController {
  RxString finalImageUrl = ''.obs;
  Rx<File?> image = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        image.value = File(pickedFile.path);
        print('Image Selected: ${pickedFile.path}');
      } else {
        print('No Image Selected');
        Fluttertoast.showToast(msg: 'No Image Selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      Fluttertoast.showToast(msg: 'Error picking image: $e');
    }
  }
}
