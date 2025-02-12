import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../getx_controller/load_excel_controller.dart';

const theme2 = Color(0xff0393f4);
const themecolor = Color(0xff0558b4);
const theme3 = Color(0xff70c0fd);
const kblack = Colors.black;
const kwhite = Colors.white;
const kgrey = Color(0xFFF5F5F5);

class Const {
  final List<String> paymentModeLists = ['Cash', 'Net Banking', 'UPI'];

  LoadAllFieldsController controller = Get.put(LoadAllFieldsController());

  /*==============================Load Firestore Data===============================
  ==================================================================================
  ================================================================================*/

  Future<void> loadAdminFromFirestore(String adminId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();
      if (doc.exists) {
        ensureDefaultFields(adminId);
        loadCategories(adminId);
      } else {
        print("Admin does not exists");
      }
    } catch (e) {
      print("Error loading admin data: $e");
    }
  }

  Future<void> ensureDefaultFields(String adminId) async {
    try {
      final adminRef = FirebaseFirestore.instance.collection('Admin').doc(adminId);

      DocumentSnapshot adminDoc = await adminRef.get();

      if (adminDoc.exists) {
        Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

        Map<String, dynamic> updates = {};

        if (!adminData.containsKey('show_delete_button')) {
          updates['show_delete_button'] = "Yes";
        }
        if (!adminData.containsKey('allow_date_to_change')) {
          updates['allow_date_to_change'] = "Yes";
        }
        if (!adminData.containsKey('is_auto_approve')) {
          updates['is_auto_approve'] = "Yes";
        }
        if (!adminData.containsKey('site_label')) {
          updates['site_label'] = "Employee";
        }
        if (!adminData.containsKey('lat')) {
          updates['lat'] = "";
        }
        if (!adminData.containsKey('lng')) {
          updates['lng'] = "";
        }
        if (!adminData.containsKey('place')) {
          updates['place'] = "";
        }

        if (updates.isNotEmpty) {
          await adminRef.update(updates);
          print("Default fields added/updated successfully.");
        } else {
          print("All default fields already exist.");
        }

        controller.allowDateToChange.value = adminData['allow_date_to_change'] ?? "Yes";
        controller.isAutoApprove.value = adminData['is_auto_approve'] ?? "Yes";
        controller.siteLable.value = adminData['site_label'] ?? "Employee";
        controller.showDeleteButton.value = adminData['show_delete_button'] ?? "Yes";
        controller.adminLat.value = adminData['lat'] ?? "";
        controller.adminLng.value = adminData['lng'] ?? "";
        controller.fullAdminAddress.value = adminData['place'] ?? "";
      } else {
        await adminRef.set({
          'show_delete_button': "Yes",
          'allow_date_to_change': "Yes",
          'is_auto_approve': "Yes",
          'site_label': "Employee",
          'lat': "",
          'lng': "",
          'place': "",
        }, SetOptions(merge: true));

        controller.allowDateToChange.value = "Yes";
        controller.isAutoApprove.value = "Yes";
        controller.siteLable.value = "Employee";
        controller.showDeleteButton.value = "Yes";
        controller.adminLat.value = "";
        controller.adminLng.value = "";
        controller.fullAdminAddress.value = "";

        print("Default fields created in a new document.");
      }
    } catch (e) {
      print("Error ensuring default fields: $e");
    }
  }

  Future<void> loadUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        final adminId = userData['adminId'];

        if (adminId != null) {
          final adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();

          if (adminDoc.exists) {
            ensureDefaultFields(adminId);
            loadAdminFields(adminId);
            loadCategories(adminId);
          }
        } else {
          print("AdminId is missing in user data");
        }
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error loading user and admin data: $e");
    }
  }

  /*============================Load Employee categories============================
  ==================================================================================
  ================================================================================*/

  Future<void> loadEmployeeCategories(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        final fetchedAdminId = userData['adminId'];

        await loadCategories(fetchedAdminId);
      } else {
        print("User not found.");
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  /*================================Load Categories=================================
  ==================================================================================
  ================================================================================*/

  Future<void> loadCategories(String adminId) async {
    try {
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('Admin').doc(adminId).collection('categories').get();

      if (categorySnapshot.docs.isNotEmpty) {
        List<String> categories = categorySnapshot.docs.map((doc) => doc['name'] as String).toList();
        controller.categoryLists.value = categories;
      } else {
        await addDefaultCategories(adminId);
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  Future<void> addDefaultCategories(String adminId) async {
    try {
      final defaultCategories = [
        'Food',
        'H.K. Material',
        'Veg',
        'Fuel',
        'Vehicle',
        'Allowance',
        'Bonus',
        'Business',
        'Investment Income',
        'Other Income',
        'Pension',
        'Salary',
        'Food expenses',
        'Transportation',
        'Subscriptions/Streaming Services',
        'Clothing',
        'Travel',
        'Gifts',
        'Charitable Giving'
      ];
      for (String category in defaultCategories) {
        await FirebaseFirestore.instance.collection('Admin').doc(adminId).collection('categories').add({
          'name': category.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      controller.categoryLists.value = defaultCategories;
      print("Default categories added successfully.");
    } catch (e) {
      print("Error adding default categories: $e");
    }
  }

  /*================================================================================
  ==================================================================================
  ================================================================================*/

  Future<void> loadAdminFields(String adminId) async {
    try {
      final adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(adminId).get();

      if (adminDoc.exists) {
        final adminData = adminDoc.data() as Map<String, dynamic>;

        controller.username.value = adminData['username'] ?? '';
        controller.email.value = adminData['email'] ?? '';
        controller.phone.value = adminData['phone'] ?? '';
        controller.companyName.value = adminData['company_name'] ?? '';
        controller.companyAddress.value = adminData['company_address'] ?? '';
        controller.companyLogo.value = adminData['company_logo'] ?? '';
        controller.referralCode.value = adminData['referralCode'] ?? '';
        controller.allowDateToChange.value = adminData['allow_date_to_change'] ?? 'Yes';
        controller.isAutoApprove.value = adminData['is_auto_approve'] ?? 'Yes';
        controller.siteLable.value = adminData['site_label'] ?? 'Employee';
        controller.showDeleteButton.value = adminData['show_delete_button'] ?? 'Yes';
        controller.adminLat.value = adminData['lat'] ?? '';
        controller.adminLng.value = adminData['lng'] ?? '';
        controller.fullAdminAddress.value = adminData['place'] ?? '';
      } else {
        print("Admin document does not exist");
      }
    } catch (e) {
      print("Error loading admin fields: $e");
    }
  }

  Future<void> ensureEmpDefaultFields(String userId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> updates = {};

        if (!userData.containsKey('lat')) {
          updates['lat'] = "";
        }
        if (!userData.containsKey('lng')) {
          updates['lng'] = "";
        }
        if (!userData.containsKey('place')) {
          updates['place'] = "";
        }

        if (updates.isNotEmpty) {
          await userRef.update(updates);
          print("Employee default fields added/updated successfully.");
        } else {
          print("Employee default fields already exist.");
        }

        controller.employeeLat.value = userData['lat'] ?? "";
        controller.employeeLng.value = userData['lng'] ?? "";
        controller.fullEmployeeAddress.value = userData['place'] ?? "";
      } else {
        await userRef.set({
          'lat': "",
          'lng': "",
          'place': "",
        }, SetOptions(merge: true));

        controller.employeeLat.value = "";
        controller.employeeLng.value = "";
        controller.fullEmployeeAddress.value = "";

        print("Employee default fields created in a new document.");
      }
    } catch (e) {
      print("Error ensuring employee default fields: $e");
    }
  }

/*================================================================================
  ==================================================================================
  ================================================================================*/
}

/*
  Delete account wala for IOS
  image edit profile mein nahi dala fir bhi bohot load ley che image path update hone par hi lena chahiye --
  camera and gallery nu dialog show --
  profile employee icons and logo show and search card design --
  all profile same setup as admin
  pending background color
  all max 100 data added in fazalcreation51 Account added
  all max 100 data added in mohsin@gmail.com Account
  all max 100 data added in create employees multiples
  categories replications -- specially ask sir
  set pin screen init load close and testing baki kabhi chalta hai kabhi nahi chalta👉
  Splash timing👉

  three boxes total credit, total debit and balance separately
  General to Employee
  Divider and delete Dialog add validation type DELETE... in Account delete
  card design update to theme color
  Location wala with adding updating while create expense also

  https://apps.apple.com/app/6740987927 IOS Mate karwanu baki che👉
  category loading existing user and new user all bariikee se check baki👉
  Share Wala👉
  default 100+ records also not showing check that also plz👉

  Add expense imageUrl problem
  App settings inside switch
  site orders real count (...)


  show expense list current month only else lazyLoad sir told make filter
  open excel inside app
  check filter wise pdf and excel share creations
  Card design as spin in iCheck sir ask fields

  Home Page par category wise filterations
  if we are updating in expense it is not updating inside this screen CategoryExpensePage() dialog why?
  Notifications wala with deep linking too
  And update doing firebase OTP wala also
*/

/* 04-02-2025

  Ask sir about categories list i have given and link in IPM so which we want to eep and which not sort it please
  category wise fix filterations inside both home pages
  give sir apk and remaining any changes update it as fast as possible and launch in both Play Store and IOS
  iCheck Apk update
  make apply google backup inside Gym App
  share referral wala baki hai

*/