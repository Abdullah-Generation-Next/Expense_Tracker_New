import 'dart:io';
import 'package:etmm/const/const.dart';
import 'package:etmm/widget/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../../getx_controller/load_excel_controller.dart';

enum TransactionType { credit, debit }

class AddAdminExpense extends StatefulWidget {
  final String adminId;
  final DocumentSnapshot userDoc;
  final DocumentSnapshot? documentData;

  const AddAdminExpense({super.key, required this.adminId, this.documentData, required this.userDoc});

  @override
  State<AddAdminExpense> createState() => _AddAdminExpenseState();
}

class _AddAdminExpenseState extends State<AddAdminExpense> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPayment;
  TransactionType? _transactionType;
  File? _image;
  String? imageUrl;

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode amountFocusNode = FocusNode();
  final FocusNode remarkFocusNode = FocusNode();

  bool isLoading = false;

  final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  final List<String> categories = ['Technology', 'Health', 'Finance', 'Education', 'Entertainment'];
  final List<String> payment = ['Cash', 'Net Banking', 'UPI'];
  // List<String> _categories = ['Food', 'H.K. Material', 'Veg', 'Fuel', 'Vehicle'];

  // final ImagePicker _picker = ImagePicker();

  // Future<void> _pickImage(ImageSource source) async {
  //   final pickedImage = await _picker.pickImage(source: source);
  //   if (pickedImage != null) {
  //     setState(() {
  //       _image = File(pickedImage.path);
  //     });
  //   }
  // }

  /* Random Add 100 records
  Future<void> submitForm(BuildContext context, widget) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final expenseCollection = FirebaseFirestore.instance
        .collection('Admin')
        .doc(widget.userDoc.id)
        .collection('expense');

    List<String> categories = [
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

    List<String> paymentModes = ['Cash', 'Net Banking', 'UPI'];
    List<String> remarks = [
      'Vehicle',
      'Quick Lunch',
      'Evening Snack',
      'Daily Commute',
      'Office Supplies',
      'Fuel Refill',
      'Grocery Shopping',
      'Subscription Fee',
      'Monthly Rent',
      'Gift Purchase',
      'Medical Bill'
    ];

    double amount = 245;
    DateTime date = DateTime(2024, 1, 30);
    TimeOfDay time = TimeOfDay(hour: 17, minute: 41);
    Random random = Random();

    try {
      for (int i = 1; i <= 100; i++) {
        String title = 'Panipuri $i';
        String category = categories[random.nextInt(categories.length)];
        String payment = paymentModes[random.nextInt(paymentModes.length)];
        String remark = remarks[random.nextInt(remarks.length)];
        String transactionType = random.nextBool() ? 'Credit' : 'Debit';

        await expenseCollection.add({
          'title': title,
          'amount': amount,
          'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          'time': "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}",
          'category': category,
          'payment_mode': payment,
          'transactionType': transactionType,
          'remark': remark,
          'status': loadController.isAutoApprove.value == "No" ? 'Pending' : 'Approved',
        });

        amount += 20;
        date = date.add(Duration(days: 2));
        time = TimeOfDay(hour: time.hour, minute: (time.minute + 1) % 60);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('100 expense records added successfully'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add expenses: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  */

  Future<void> submitForm(BuildContext context, widget) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String title = _titleController.text;
    double amount = double.parse(_amountController.text);
    String date = _dateController.text;
    String time = _timeController.text;
    String remark = _remarkController.text;
    String category = _selectedCategory ?? '';
    String payment = _selectedPayment ?? '';

    try {
      final adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).get();
      final expenseCollection =
          FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('expense');

      String adminName = adminDoc.data()?['username'] ?? 'UnknownAdmin';
      print(adminName);

      String? finalImageUrl = widget.documentData?["imageUrl"];

      // Handle image upload and compression
      if (_image != null) {
        if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
          final oldImageRef = FirebaseStorage.instance.refFromURL(finalImageUrl);
          await oldImageRef.delete();
        }

        final compressedImagePath = _image!.absolute.path + '_compressed.jpg';
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          _image!.absolute.path,
          compressedImagePath,
          quality: 95,
        );

        if (compressedImage != null) {
          final storageRef =
              FirebaseStorage.instance.ref().child('Admin/$adminName/${DateTime.now().millisecondsSinceEpoch}');
          await storageRef.putFile(File(compressedImage.path));
          finalImageUrl = await storageRef.getDownloadURL();
        } else {
          throw Exception('Image compression failed');
        }
      }

      if (widget.documentData == null) {
        // Add a new expense document with `payment_mode`
        await expenseCollection.add({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'remark': remark,
          'category': category,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'payment_mode': payment.isNotEmpty ? payment : '', // Include payment_mode field
          'createdAt': FieldValue.serverTimestamp(),
          'imageUrl': finalImageUrl,
          'siteAddress': loadController.fullAdminAddress.value,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Update an existing expense document
        final expenseDocRef = expenseCollection.doc(widget.documentData.id);

        // Check if the `payment_mode` field exists and initialize it if missing
        final expenseDoc = await expenseDocRef.get();
        if (!expenseDoc.data()!.containsKey('payment_mode')) {
          await expenseDocRef.update({'payment_mode': ''});
        }

        // Update the expense document with new data
        await expenseDocRef.update({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'remark': remark,
          'category': category,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'payment_mode': payment.isNotEmpty ? payment : '', // Update payment_mode
          'updatedAt': FieldValue.serverTimestamp(),
          'imageUrl': finalImageUrl,
          'siteAddress': loadController.fullAdminAddress.value,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense updated successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Clear form fields after submission
      _titleController.clear();
      _amountController.clear();
      _dateController.clear();
      _timeController.clear();
      _remarkController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedPayment = null; // Reset payment dropdown
        // _transactionType = TransactionType.credit;
        _image = null;
      });

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add/update expense: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /*
  Future<void> submitForm(BuildContext context, widget) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String title = _titleController.text;
    double amount = double.parse(_amountController.text);
    String date = _dateController.text;
    String time = _timeController.text;
    String remark = _remarkController.text;
    String category = _selectedCategory ?? '';

    try {
      final adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).get();

      final expenseCollection =
          FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('expense');

      String adminName = adminDoc.data()?['username'] ?? 'UnknownAdmin';
      print(adminName);

      // if (_image != null) {
      //   final storageRef = FirebaseStorage.instance.ref().child('Admin/$adminName/${DateTime.now().millisecondsSinceEpoch}');
      //   await storageRef.putFile(_image!);
      //   imageUrl = await storageRef.getDownloadURL();
      // }

      /*String? finalImageUrl;

      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('Admin/$adminName/${DateTime.now().millisecondsSinceEpoch}');
        await storageRef.putFile(_image!);
        finalImageUrl = await storageRef.getDownloadURL();
      } else if (widget.documentData != null && widget.documentData?["imageUrl"] != '' && widget.documentData?["imageUrl"].isNotEmpty) {
        finalImageUrl = databaseImage;
      }*/

      String? finalImageUrl = widget.documentData?["imageUrl"];

      if (_image != null) {
        if (finalImageUrl != null && finalImageUrl.isNotEmpty && finalImageUrl != '') {
          final oldImageRef = FirebaseStorage.instance.refFromURL(finalImageUrl);
          await oldImageRef.delete();
        }

        final compressedImagePath = _image!.absolute.path + '_compressed.jpg';
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          _image!.absolute.path,
          compressedImagePath,
          quality: 5,
        );

        if (compressedImage != null) {
          final storageRef =
              FirebaseStorage.instance.ref().child('Admin/$adminName/${DateTime.now().millisecondsSinceEpoch}');
          await storageRef.putFile(File(compressedImage.path));
          finalImageUrl = await storageRef.getDownloadURL();
        } else {
          throw Exception('Image compression failed');
        }
      } else if (widget.documentData != null &&
          widget.documentData?["imageUrl"] != '' &&
          widget.documentData?["imageUrl"].isNotEmpty) {
        finalImageUrl = databaseImage;
      }

      if (widget.documentData == null) {
        // Add logic
        // final expenseDocRef =
        await expenseCollection.add({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'remark': remark,
          'category': category,
          'transactionType': _transactionType == TransactionType.credit ? 'credit' : 'debit',
          'createdAt': FieldValue.serverTimestamp(),
          'imageUrl': finalImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Edit logic
        final expenseDocRef = expenseCollection.doc(widget.documentData.id);

        await expenseDocRef.update({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'remark': remark,
          'category': category,
          'transactionType': _transactionType == TransactionType.credit ? 'credit' : 'debit',
          'updatedAt': FieldValue.serverTimestamp(),
          'imageUrl': finalImageUrl,
        });

        // if (_image != null) {
        //   final storageRef = FirebaseStorage.instance.ref().child('Admin/$adminName/${DateTime.now().millisecondsSinceEpoch}');
        //   await storageRef.putFile(_image!);
        //   final imageUrl = await storageRef.getDownloadURL();
        //   await expenseDocRef.update({'imageUrl': imageUrl});
        // }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense updated successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      _titleController.clear();
      _amountController.clear();
      _dateController.clear();
      _timeController.clear();
      _remarkController.clear();
      setState(() {
        _selectedCategory = null;
        _transactionType = TransactionType.credit;
        _image = null;
      });
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add/update expense: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  */

  bool loading = false;
  String? databaseImage;
  final storage = firebase_storage.FirebaseStorage.instance;
  final picker = ImagePicker();

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

  // Future<void> submitEditForm(BuildContext context, widget) async {
  //   if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
  //     return;
  //   }
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   String title = _titleController.text;
  //   double amount = double.parse(_amountController.text);
  //   String date = _dateController.text;
  //   String time = _timeController.text;
  //   String remark = _remarkController.text;
  //   String category = _selectedCategory ?? '';
  //
  //   try {
  //     final expenseCollection = FirebaseFirestore.instance
  //         .collection('Admin') // Assuming 'Admin' is the top collection
  //         .doc(widget.adminId)
  //         .collection('expense');
  //
  //     final expenseDocRef = await expenseCollection.add({
  //       'title': title,
  //       'amount': amount,
  //       'date': date,
  //       'time': time,
  //       'remark': remark,
  //       'category': category,
  //       // 'imageUrl': imageUrl,
  //       'transactionType':
  //           _transactionType == TransactionType.credit ? 'credit' : 'debit',
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //
  //     // Consider adding a success message specific to image upload (optional)
  //
  //     if (_image != null) {
  //       final storageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('expenses/${DateTime.now().millisecondsSinceEpoch}');
  //       await storageRef.putFile(_image!);
  //       final imageUrl = await storageRef.getDownloadURL();
  //       await expenseDocRef.update({'imageUrl': imageUrl});
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Expense added successfully'),
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //
  //     _titleController.clear();
  //     _amountController.clear();
  //     _dateController.clear();
  //     _timeController.clear();
  //     _remarkController.clear();
  //     setState(() {
  //       _selectedCategory = null;
  //       _transactionType = TransactionType.credit;
  //       _image = null;
  //     });
  //     Navigator.pop(context);
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to add expense: $error'),
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    constants.loadCategories(widget.adminId);

    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);
    // _timeController.text = TimeOfDay.fromDateTime(now).format(context);

    if (widget.documentData != null) {
      _titleController.text = widget.documentData?['title'];
      _amountController.text = widget.documentData!['amount'].toString();
      _remarkController.text = widget.documentData?['remark'];
      _dateController.text = widget.documentData?['date'];
      _timeController.text = widget.documentData?['time'];
      // _selectedCategory = widget.documentData?['category'];
      // _selectedPayment = widget.documentData?['payment_mode'];

      final loadedCategory = widget.documentData?['category'];
      // _selectedCategory = constants.categoryLists.contains(loadedCategory) ? loadedCategory : null;
      _selectedCategory = loadController.categoryLists.contains(loadedCategory) ? loadedCategory : null;

      _initializePaymentMode(widget.adminId, widget.documentData!.id);

      // final loadedPaymentMode = widget.documentData?['payment_mode'];
      // _selectedPayment = constants.categoryLists.contains(loadedPaymentMode) ? loadedPaymentMode : null;

      _transactionType =
          (widget.documentData?['transactionType'] == 'credit' || widget.documentData?['transactionType'] == 'Credit')
              ? TransactionType.credit
              : TransactionType.debit;
      databaseImage = widget.documentData?["imageUrl"];
      print(databaseImage);
    }

    super.initState();
  }

  Future<void> _initializePaymentMode(String adminId, String expenseId) async {
    try {
      final expenseDocRef =
          FirebaseFirestore.instance.collection('Admin').doc(adminId).collection('expense').doc(expenseId);

      final expenseDoc = await expenseDocRef.get();

      final data = expenseDoc.data();
      if (data == null) {
        print('Expense document does not exist or has no data.');
        return;
      }

      if (data.containsKey('payment_mode')) {
        // await expenseDocRef.update({'payment_mode': ''});
        // print('Added missing payment_mode field to expense document.');
        String loadedPaymentMode = data['payment_mode'] ?? '';
        if (constants.paymentModeLists.contains(loadedPaymentMode)) {
          setState(() {
            _selectedPayment = loadedPaymentMode; // Set to valid payment mode from Firestore
          });
        } else {
          setState(() {
            _selectedPayment = null;
          });
        }
      } else {
        setState(() {
          _selectedPayment = null;
        });
      }
    } catch (e) {
      print('Error initializing payment_mode: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final now = DateTime.now();
    if (widget.documentData == null) {
      _timeController.text = TimeOfDay.fromDateTime(now).format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolor,
        title: Text(
          widget.documentData != null ? 'Edit Expense' : 'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      focusNode: titleFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(amountFocusNode);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            textInputAction: TextInputAction.next,
                            focusNode: amountFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(remarkFocusNode);
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              } else if (value.length > 6) {
                                return '6 digits limit';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: DropdownButtonFormField<TransactionType>(
                            value: _transactionType,
                            items: [
                              DropdownMenuItem(
                                value: TransactionType.credit,
                                child: Text('Credit'),
                              ),
                              DropdownMenuItem(
                                value: TransactionType.debit,
                                child: Text('Debit'),
                              ),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                _transactionType = newValue!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a transaction type';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap:
                                    // SharedPref.get(prefKey: PrefKey.defaultDatePickAdmin) == "0"
                                    //     ? null
                                    //     :
                                    loadController.allowDateToChange.value == "No"
                                        ? null
                                        : () async {
                                            final DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2101),
                                            );
                                            if (pickedDate != null) {
                                              _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                            }
                                          },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a Date';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                              )),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Obx(
                            () => TextFormField(
                              controller: _timeController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Time',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              onTap: loadController.allowDateToChange.value == "No"
                                  ? null
                                  : () async {
                                      TimeOfDay? pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (pickedTime != null) {
                                        _timeController.text = pickedTime.format(context);
                                      }
                                    },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a time';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Obx(
                      () => DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          // items: _categories.map((String category) {
                          //   return DropdownMenuItem<String>(
                          //     value: category,
                          //     child: Text(category),
                          //   );
                          // }).toList(),
                          items: loadController.categoryLists.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedPayment,
                      // items: _payment.map((String payment) {
                      //   return DropdownMenuItem<String>(
                      //     value: payment,
                      //     child: Text(payment),
                      //   );
                      // }).toList(),
                      items: constants.paymentModeLists.map((String payment) {
                        return DropdownMenuItem<String>(
                          value: payment,
                          child: Text(payment),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPayment = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                        prefixIcon: Icon(CupertinoIcons.money_dollar_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a payment mode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _remarkController,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      focusNode: remarkFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Remark',
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    loadController.fullAdminAddress.value != ""
                        ? Column(
                            children: [
                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.location_solid,
                                    color: themecolor,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Your last location was fetched is"),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black),
                                  color: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Obx(() => Text(
                                              "${loadController.fullAdminAddress.value != "" ? loadController.fullAdminAddress : "You haven't updated your location yet!"}",
                                              style: TextStyle(color: Colors.black),
                                            ))),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        if (loadController.fullAdminAddress.value == "") {
                                          loadController.requestLocationPermission(
                                              isAdmin: true, adminId: widget.adminId);
                                        } else {
                                          showUpdateLocationDialog(context);
                                        }
                                      },
                                      child: Tooltip(
                                        message: "Update Current Location",
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        textStyle: TextStyle(color: Colors.black),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.transparent),
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                                          child: Text(
                                            'Update',
                                            style: TextStyle(
                                              color: themecolor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    const SizedBox(height: 25.0),
                    // UploadScreen(),
                    Padding(
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
                              /*Center(
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
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black)),
                                  )
                                      : widget.DocumentData != null ? Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.network(
                                      widget.DocumentData?["imageUrl"],
                                      fit: BoxFit.cover,
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black)),
                                  ) : Center(
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      child: Center(child: Icon(Icons.photo)),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black)),
                                    ),
                                  ),
                                ),
                              ),*/
                              Center(
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    getImageGallery();
                                  },
                                  child: _image != null
                                      ? Stack(
                                          children: [
                                            Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                              child: Image.file(
                                                _image!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                                right: 0,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _image = null;
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: Colors.red,
                                                    ))),
                                          ],
                                        )
                                      : (databaseImage != null && widget.documentData?["imageUrl"] != '')
                                          ? Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                              child: Image.network(
                                                databaseImage ?? "",
                                                fit: BoxFit.cover,
                                                loadingBuilder: (BuildContext context, Widget child,
                                                    ImageChunkEvent? loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  } else {
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                (loadingProgress.expectedTotalBytes ?? 1)
                                                            : null,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            )
                                          : Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                              child: Center(child: Icon(Icons.photo)),
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
                    ),
                    // Row(
                    //   children: [
                    //     _image == null
                    //         ? Text('No image selected.')
                    //         : Image.file(
                    //             _image!,
                    //             width: 100,
                    //             height: 100,
                    //             fit: BoxFit.cover,
                    //           ),
                    //     const SizedBox(width: 16.0),
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         showModalBottomSheet(
                    //           context: context,
                    //           builder: (context) {
                    //             return Column(
                    //               mainAxisSize: MainAxisSize.min,
                    //               children: [
                    //                 ListTile(
                    //                   leading: Icon(Icons.camera),
                    //                   title: Text('Take a Photo'),
                    //                   onTap: () {
                    //                     _pickImage(ImageSource.camera);
                    //                     Navigator.of(context).pop();
                    //                   },
                    //                 ),
                    //                 ListTile(
                    //                   leading: Icon(Icons.image),
                    //                   title: Text('Choose from Gallery'),
                    //                   onTap: () {
                    //                     _pickImage(ImageSource.gallery);
                    //                     Navigator.of(context).pop();
                    //                   },
                    //                 ),
                    //               ],
                    //             );
                    //           },
                    //         );
                    //       },
                    //       child: Text('Pick Image'),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 30.0),
                    Container(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() == true) {
                                  // Perform your add or edit logic here
                                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  //   builder: (context) => AdminExpensePage(adminId: widget.adminId, userDoc: widget.userDoc,),
                                  // ));
                                  submitForm(context, widget);
                                  // Navigator.pop(context);
                                }
                              },
                        style: ButtonStyle(
                          // ignore: deprecated_member_use
                          backgroundColor: MaterialStatePropertyAll(themecolor),
                          // ignore: deprecated_member_use
                          foregroundColor: MaterialStatePropertyAll(Colors.white),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                widget.documentData != null ? 'Edit' : 'Add',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => loadController.adminLocationLoading.isTrue
                ? Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 4,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Fetching Location",
                              style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Please Wait...",
                              style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void showUpdateLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Location"),
          content: Text("Are you sure you want to update your location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                loadController.requestLocationPermission(isAdmin: true, adminId: widget.adminId);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }
}

/*Future<void> submitAddForm(BuildContext context, widget) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    String title = _titleController.text;
    double amount = double.parse(_amountController.text);
    String date = _dateController.text;
    String time = _timeController.text;
    String remark = _remarkController.text;
    String category = _selectedCategory ?? '';

    try {
      final expenseCollection = FirebaseFirestore.instance
          .collection('Admin') // Assuming 'Admin' is the top collection
          .doc(widget.adminId)
          .collection('expense');

      final expenseDocRef = await expenseCollection.add({
        'title': title,
        'amount': amount,
        'date': date,
        'time': time,
        'remark': remark,
        'category': category,
        // 'imageUrl': imageUrl,
        'transactionType':
            _transactionType == TransactionType.credit ? 'credit' : 'debit',
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl' : "",
      });

      // Consider adding a success message specific to image upload (optional)

      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('expenses/${DateTime.now().millisecondsSinceEpoch}');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();
        await expenseDocRef.update({'imageUrl': imageUrl});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense added successfully'),
          duration: const Duration(seconds: 2),
        ),
      );

      _titleController.clear();
      _amountController.clear();
      _dateController.clear();
      _timeController.clear();
      _remarkController.clear();
      setState(() {
        _selectedCategory = null;
        _transactionType = TransactionType.credit;
        _image = null;
      });
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add expense: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }*/
