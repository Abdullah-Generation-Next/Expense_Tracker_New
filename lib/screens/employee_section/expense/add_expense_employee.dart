import 'dart:io';
import 'package:etmm/const/const.dart';
import 'package:etmm/widget/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../getx_controller/load_excel_controller.dart';

// Assuming you have a TransactionType enum defined somewhere
enum TransactionType { credit, debit }

class AddEmployeeExpense extends StatefulWidget {
  final String userId;
  final DocumentSnapshot userDoc;
  final DocumentSnapshot? DocumentData;

  const AddEmployeeExpense({Key? key, required this.userId, required this.userDoc, this.DocumentData})
      : super(key: key);

  @override
  _AddEmployeeExpenseState createState() => _AddEmployeeExpenseState();
}

class _AddEmployeeExpenseState extends State<AddEmployeeExpense> {
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
  String? databaseImage;
  final storage = firebase_storage.FirebaseStorage.instance;

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode amountFocusNode = FocusNode();
  final FocusNode remarkFocusNode = FocusNode();

  final constants = Const();
  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  final List<String> categories = ['Technology', 'Health', 'Finance', 'Education', 'Entertainment'];
  final List<String> payment = ['Cash', 'Net Banking', 'UPI'];
  // List<String> _categories = ['Food', 'H.K. Material', 'Veg', 'Fuel', 'Vehicle']; // Example categories

  final picker = ImagePicker();

  bool isLoading = false;

  String? imageUrl;

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
    String payment = _selectedPayment ?? '';

    try {
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(widget.userDoc.id).get();

      final expenseCollection =
          FirebaseFirestore.instance.collection('Users').doc(widget.userDoc.id).collection('expenses');

      String employeeName = userDoc.data()?['username'] ?? 'UnknownEmployee';
      print(employeeName);

      // Initialize finalImageUrl with the current image URL from the database
      String? finalImageUrl = widget.DocumentData?["imageUrl"];

      if (_image != null) {
        if (finalImageUrl != null && finalImageUrl.isNotEmpty && finalImageUrl != '') {
          final oldImageRef = FirebaseStorage.instance.refFromURL(finalImageUrl);
          await oldImageRef.delete();
        }

        /*// Compress and upload the new image
        final storageRef = FirebaseStorage.instance.ref().child('Employees/$employeeName/${DateTime.now().millisecondsSinceEpoch}');
        // await storageRef.putFile(_image!);
        // finalImageUrl = await storageRef.getDownloadURL();
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          _image!.absolute.path,
          _image!.absolute.path + '_compressed.jpg',
          quality: 70,
        );

        if (compressedImage != null) {
          await storageRef.putFile(File(compressedImage.toString()));
          finalImageUrl = await storageRef.getDownloadURL();
        }*/

        // Compress and upload the new image
        final compressedImagePath = _image!.absolute.path + '_compressed.jpg';
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          _image!.absolute.path,
          compressedImagePath,
          quality: 5,
        );

        try {
          if (compressedImage != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('Employees/$employeeName/${DateTime.now().millisecondsSinceEpoch}');
            await storageRef.putFile(File(compressedImage.path));
            finalImageUrl = await storageRef.getDownloadURL();
          } else {
            throw Exception('Image compression failed');
          }
        } catch (e) {
          print('Error uploading file: $e');
        }
      } else if (widget.DocumentData != null &&
          widget.DocumentData?["imageUrl"] != '' &&
          widget.DocumentData?["imageUrl"] != null) {
        finalImageUrl = databaseImage;
      }

      if (widget.DocumentData == null) {
        await expenseCollection.add({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'category': category,
          'payment_mode': payment,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': remark,
          'status': 'Pending',
          'imageUrl': finalImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final expenseDocRef = expenseCollection.doc(widget.DocumentData.id);

        await expenseDocRef.update({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'category': category,
          'payment_mode': payment,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': remark,
          'status': 'Pending',
          'imageUrl': finalImageUrl,
        });

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
      print(error);
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
    String status = widget.DocumentData?["status"] ?? '';

    try {
      final expenseCollection =
          FirebaseFirestore.instance.collection('Users').doc(widget.userDoc.id).collection('expenses');

      // Initialize the final image URL with the current value from the widget
      String? finalImageUrl = widget.DocumentData?["imageUrl"];

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
          final employeeName = widget.userDoc.data()?['username'] ?? 'UnknownEmployee';
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('${loadController.siteLable.value}/$employeeName/${DateTime.now().millisecondsSinceEpoch}');
          await storageRef.putFile(File(compressedImage.path));
          finalImageUrl = await storageRef.getDownloadURL();
        } else {
          throw Exception('Image compression failed');
        }
      }

      if (widget.DocumentData == null) {
        // Add a new expense document and ensure `payment_mode` is included
        await expenseCollection.add({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'category': category,
          'payment_mode': payment, // Ensure payment_mode is added
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': remark,
          'status': loadController.isAutoApprove.value == "No" ? 'Pending' : 'Approved',
          // loadController.isAutoApprove.value == "Yes"
          //         ? 'Approved'
          //         : 'Rejected',
          'imageUrl': finalImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Update an existing expense document
        final expenseDocRef = expenseCollection.doc(widget.DocumentData.id);

        final expenseDoc = await expenseDocRef.get();
        // Check if the payment_mode field exists; initialize if it doesn't
        if (!expenseDoc.data()!.containsKey('payment_mode')) {
          await expenseDocRef.update({'payment_mode': ''});
        }

        // Update the document with new data
        await expenseDocRef.update({
          'title': title,
          'amount': amount,
          'date': date,
          'time': time,
          'category': category,
          'payment_mode': payment, // Update payment_mode properly
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': remark,
          'status': status,
          'imageUrl': finalImageUrl,
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
        // _selectedCategory = null;
        // _selectedPayment = null; // Reset payment selection
        _transactionType = TransactionType.credit;
        _image = null;
      });

      Navigator.pop(context);
    } catch (error) {
      print('Error: $error');
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

  bool loading = false;

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
  void initState() {
    constants.loadEmployeeCategories(widget.userId);

    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);

    if (widget.DocumentData != null) {
      _titleController.text = widget.DocumentData?['title'];
      _amountController.text = widget.DocumentData!['amount'].toString();
      _remarkController.text = widget.DocumentData?['remark'];
      _dateController.text = widget.DocumentData?['date'];
      _timeController.text = widget.DocumentData?['time'];
      // _selectedCategory = widget.DocumentData?['category'];
      // _selectedPayment = widget.DocumentData?['payment_mode'];

      final loadedCategory = widget.DocumentData?['category'];
      // _selectedCategory = constants.categoryLists.contains(loadedCategory) ? loadedCategory : null;
      _selectedCategory = loadController.categoryLists.contains(loadedCategory) ? loadedCategory : null;

      _initializePaymentMode(widget.userId, widget.DocumentData!.id);

      _transactionType =
          widget.DocumentData?['transactionType'] == 'Credit' ? TransactionType.credit : TransactionType.debit;
      databaseImage = widget.DocumentData?["imageUrl"];
      print(databaseImage);
    }
    super.initState();
  }

  Future<void> _initializePaymentMode(String userId, String expenseId) async {
    try {
      final expenseDocRef =
          FirebaseFirestore.instance.collection('Users').doc(userId).collection('expenses').doc(expenseId);

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
    if (widget.DocumentData == null) {
      _timeController.text = TimeOfDay.fromDateTime(now).format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: themecolor,
          title: Text(
            widget.DocumentData != null ? 'Edit Expense' : 'Add Expense',
            style: TextStyle(fontWeight: FontWeight.bold, color: kwhite),
          ),
          iconTheme: IconThemeData(color: kwhite),
        ),
        body: SingleChildScrollView(
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
                    textInputAction: TextInputAction.next,
                    focusNode: titleFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(amountFocusNode);
                    },
                    keyboardType: TextInputType.text,
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
                              onTap: loadController.allowDateToChange.value == "No"
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
                        child: Obx(() => TextFormField(
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
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: _selectedCategory,
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
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedPayment,
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
                    textInputAction: TextInputAction.done,
                    focusNode: remarkFocusNode,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      prefixIcon: Icon(Icons.note),
                    ),
                    // Optional validator
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter a remark';
                    //   }
                    //   return null;
                    // },
                  ),
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
                                    : (databaseImage != null && widget.DocumentData?["imageUrl"] != '')
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
                  //       _image!,
                  //       width: 100,
                  //       height: 100,
                  //       fit: BoxFit.cover,
                  //     ),
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
                  const SizedBox(height: 30),
                  Container(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() == true) {
                                submitForm(context, widget);
                              }
                              // if (_formKey.currentState!.validate()) {
                              //   // Handle image upload and URL retrieval
                              //   final imageUrl = await uploadImageToFirebaseStorage();
                              //
                              //   FirebaseFirestore.instance
                              //       .collection('Users')
                              //       .doc(widget.userDoc.id)
                              //       .collection('expenses')
                              //       .add({
                              //     'title': _titleController.text,
                              //     'amount': double.parse(_amountController.text),
                              //     'date': _dateController.text,
                              //     'time': _timeController.text,
                              //     'category': _selectedCategory,
                              //     'transactionType': _transactionType == TransactionType.credit
                              //         ? 'Credit'
                              //         : 'Debit',
                              //     'remark': _remarkController.text,
                              //     'status': 'Pending',
                              //     'imageUrl': imageUrl,
                              //   });
                              //
                              //   // Clear form data and navigate back
                              //   _titleController.clear();
                              //   _amountController.clear();
                              //   _dateController.clear();
                              //   _timeController.clear();
                              //   _remarkController.clear();
                              //   setState(() {
                              //     _image = null;
                              //   });
                              //   Navigator.of(context).pop();
                              // }
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
                              widget.DocumentData != null ? 'Edit' : 'Add',
                              style: TextStyle(fontSize: 20, color: Colors.white), // Use kwhite if available
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

/*Future<void> submitForm(BuildContext context, widget) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userDoc.id)
          .get();

      String employeeName = userDoc.data()?['username'] ?? 'UnknownEmployee';

      final expenseCollection =
          FirebaseFirestore.instance.collection('Users').doc(widget.userDoc.id).collection('expenses');

      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('Employees/$employeeName/${DateTime.now().millisecondsSinceEpoch}');
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      }

      if (widget.DocumentData == null) {
        // final expenseDocRef =
        await expenseCollection.add({
          'title': _titleController.text,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'time': _timeController.text,
          'category': _selectedCategory,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': _remarkController.text,
          'status': 'Pending',
          'imageUrl': (imageUrl != null) ? imageUrl : "",
        });

        // if (_image != null) {
        //   final storageRef = FirebaseStorage.instance
        //       .ref()
        //       .child('expenses/${DateTime.now().millisecondsSinceEpoch}');
        //   await storageRef.putFile(_image!);
        //   final imageUrl = await storageRef.getDownloadURL();
        //   await expenseDocRef.update({'imageUrl': imageUrl});
        // }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Edit logic
        final expenseDocRef = expenseCollection.doc(widget.DocumentData.id);

        await expenseDocRef.update({
          'title': _titleController.text,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'time': _timeController.text,
          'category': _selectedCategory,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': _remarkController.text,
          'status': 'Pending',
          'imageUrl': (imageUrl != null) ? imageUrl : "",
        });

        if (_image != null) {
          final storageRef = FirebaseStorage.instance.ref().child('Employees/$employeeName/${DateTime.now().millisecondsSinceEpoch}');
          await storageRef.putFile(_image!);
          final imageUrl = await storageRef.getDownloadURL();
          await expenseDocRef.update({'imageUrl': imageUrl});
        }

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
  }*/

/*

  // Without deleting old image from firestore storage database function while updating expense data

  Future<void> submitForm(BuildContext context, widget) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userDoc.id)
          .get();

      String employeeName = userDoc.data()?['username'] ?? 'UnknownEmployee';

      final expenseCollection =
      FirebaseFirestore.instance.collection('Users').doc(widget.userDoc.id).collection('expenses');

      // Determine which image URL to use
      String? finalImageUrl;

      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('Employees/$employeeName/${DateTime.now().millisecondsSinceEpoch}');
        await storageRef.putFile(_image!);
        finalImageUrl = await storageRef.getDownloadURL();
      } else if (widget.DocumentData != null && widget.DocumentData?["imageUrl"] != '' && widget.DocumentData?["imageUrl"].isNotEmpty) {
        finalImageUrl = databaseImage;
      }

      if (widget.DocumentData == null) {
        await expenseCollection.add({
          'title': _titleController.text,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'time': _timeController.text,
          'category': _selectedCategory,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': _remarkController.text,
          'status': 'Pending',
          'imageUrl': finalImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final expenseDocRef = expenseCollection.doc(widget.DocumentData.id);

        await expenseDocRef.update({
          'title': _titleController.text,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'time': _timeController.text,
          'category': _selectedCategory,
          'transactionType': _transactionType == TransactionType.credit ? 'Credit' : 'Debit',
          'remark': _remarkController.text,
          'status': 'Pending',
          'imageUrl': finalImageUrl,
        });

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
  }*/

// With deleting old image from firestore storage database function while updating expense data
