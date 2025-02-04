import 'dart:io';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/admin_section/expense/add_expense_admin.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../../../getx_controller/load_excel_controller.dart';
import '../../../widget/pdf_viewer.dart';

enum TransactionType { credit, debit }

class AdminExpensePage extends StatefulWidget {
  final DocumentSnapshot userDoc;
  final String adminId;

  const AdminExpensePage({
    Key? key,
    required this.userDoc,
    required this.adminId,
  }) : super(key: key);

  @override
  _AdminExpensePageState createState() => _AdminExpensePageState();
}

class _AdminExpensePageState extends State<AdminExpensePage> {
  String _sortField = 'date'; // Default sort field
  bool _isAscending = true; // Default sort order
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  TransactionType transactionType = TransactionType.credit;
  String? selectedCategory;
  final List<String> _categories = ['Technology', 'Health', 'Finance', 'Education', 'Entertainment'];
  String _titleFilter = '';
  String _fromDateFilter = '';
  String _toDateFilter = '';
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  LoadExcelController controller = Get.put(LoadExcelController());
  DeleteController deleteController = Get.put(DeleteController());

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    controller.loadingDialog.value = false;
  }

  Future<void> _showDownloadOptions(BuildContext context) async {
    String? _selectedOption = 'PDF'; // Default option

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              title: Text('Download as'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: const Text('PDF'),
                    value: 'PDF',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Excel'),
                    value: 'Excel',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    // ignore: deprecated_member_use
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    // ignore: deprecated_member_use
                    backgroundColor: MaterialStatePropertyAll(themecolor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 15)),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    // ignore: deprecated_member_use
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    // ignore: deprecated_member_use
                    backgroundColor: MaterialStatePropertyAll(themecolor),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(_selectedOption);
                    controller.loadingDialog.value = true;

                    if (_selectedOption == 'PDF') {
                      await shareOrOpenExpenseSummaryPdf();
                    } else if (_selectedOption == 'Excel') {
                      await shareOrOpenExpenseSummaryExcel();
                    }
                  },
                  child: Text('Download', style: TextStyle(fontSize: 15)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> shareOrOpenExpenseSummaryExcel() async {
    final userDocData = widget.userDoc.data() as Map<String, dynamic>;

    final email = userDocData['email'];
    final name = userDocData['username'];
    // final name = _getUsernameFromEmail(email);

    final expenses = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(widget.userDoc.id)
        .collection('expense')
        .get()
        .then((snapshot) => snapshot.docs);

    final excelFile = await generateExpenseSummaryExcel(name, email, expenses);

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/ExpenseSummary.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excelFile);

    controller.loadingDialog.value = false;
    _showFileActionDialogExcel(filePath);
  }

  Future<void> _showFileActionDialogExcel(String filePath) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Action'),
          content: Text('Do you want to open or share the Excel file?'),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     _openExcelFile(filePath);
            //   },
            //   child: Text('Open'),
            // ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareExcelFile(filePath);
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareExcelFile(String filePath) async {
    try {
      XFile fileName = XFile(filePath);
      await Share.shareXFiles([fileName], text: 'Expense Summary');
    } catch (e) {
      print('Error sharing file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share file: $e')),
      );
    }
  }

  Future<List<int>> generateExpenseSummaryExcel(
      String userName, String userEmail, List<DocumentSnapshot> expenses) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Set heading styles
    final headingStyle = workbook.styles.add('headingStyle');
    headingStyle.fontSize = 18;
    headingStyle.bold = true;
    headingStyle.hAlign = xlsio.HAlignType.center;

    final boldStyle = workbook.styles.add('boldStyle');
    boldStyle.bold = true;
    boldStyle.hAlign = xlsio.HAlignType.center;

    final detailsStyle = workbook.styles.add('detailsStyle');
    detailsStyle.hAlign = xlsio.HAlignType.center;

    // Set headings
    sheet.getRangeByIndex(1, 1).setText('Expense Summary');
    sheet.getRangeByIndex(1, 1).cellStyle = headingStyle;
    sheet.getRangeByIndex(2, 1).setText('Name: $userName');
    sheet.getRangeByIndex(2, 1).cellStyle = detailsStyle;
    sheet.getRangeByIndex(3, 1).setText('Email: $userEmail');
    sheet.getRangeByIndex(3, 1).cellStyle = detailsStyle;
    sheet.getRangeByIndex(4, 1).setText(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    sheet.getRangeByIndex(4, 1).cellStyle = detailsStyle;

    // Merge header cells
    sheet.getRangeByIndex(1, 1, 1, 7).merge();
    sheet.getRangeByIndex(2, 1, 2, 7).merge();
    sheet.getRangeByIndex(3, 1, 3, 7).merge();
    sheet.getRangeByIndex(4, 1, 4, 7).merge();

    // Set table headers
    const headers = ['Title', 'Amount', 'Type', 'Category', 'Date', 'Time', 'Image'];
    for (int col = 0; col < headers.length; col++) {
      sheet.getRangeByIndex(6, col + 1).setText(headers[col]);
      sheet.getRangeByIndex(6, col + 1).cellStyle = boldStyle;
      sheet.getRangeByIndex(6, col + 1).columnWidth = 20;
    }

    // Variables to calculate totals
    double totalCredit = 0;
    double totalDebit = 0;

    // Populate data rows
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i].data() as Map<String, dynamic>;
      final rowIndex = 7 + i;

      // Safely extract data
      final title = expense['title']?.toString() ?? '--';
      final amount = expense['amount'] != null ? '${expense['amount']}' : '--';
      final transactionType = expense['transactionType']?.toString() ?? '--';
      final category = expense['category']?.toString() ?? '--';
      final date = expense['date']?.toString() ?? '--';
      final time = expense['time']?.toString() ?? '--';
      final imageUrl = expense['imageUrl']?.toString() ?? '';

      // Add data to cells
      sheet.getRangeByIndex(rowIndex, 1).setText(title);
      sheet.getRangeByIndex(rowIndex, 2).setText(amount);
      sheet.getRangeByIndex(rowIndex, 3).setText(transactionType);
      sheet.getRangeByIndex(rowIndex, 4).setText(category);
      sheet.getRangeByIndex(rowIndex, 5).setText(date);
      sheet.getRangeByIndex(rowIndex, 6).setText(time);

      // Calculate totals
      if (amount != '--') {
        final parsedAmount = double.tryParse(amount) ?? 0.0;
        if (transactionType.toLowerCase() == 'credit') {
          totalCredit += parsedAmount;
        } else if (transactionType.toLowerCase() == 'debit') {
          totalDebit += parsedAmount;
        }
      }

      // Handle image
      if (imageUrl.isNotEmpty) {
        final imageBytes = await fetchImageBytes(imageUrl);
        if (imageBytes != null) {
          final originalImage = img.decodeImage(imageBytes);
          final resizedImage = img.copyResize(originalImage!, width: 80, height: 80);

          sheet.pictures.addStream(rowIndex, 7, img.encodePng(resizedImage));
          sheet.getRangeByIndex(rowIndex, 7).rowHeight = 60;
          sheet.getRangeByIndex(rowIndex, 7).columnWidth = 15;
        } else {
          sheet.getRangeByIndex(rowIndex, 7).setText('Invalid image');
        }
      } else {
        sheet.getRangeByIndex(rowIndex, 7).setText('');
      }

      // Align cells
      for (int j = 1; j <= 6; j++) {
        sheet.getRangeByIndex(rowIndex, j).cellStyle.hAlign = xlsio.HAlignType.center;
      }
    }

    // Add total row
    final totalRowIndex = expenses.length + 7;
    final netAmount = totalCredit - totalDebit;

    sheet.getRangeByIndex(totalRowIndex, 1).setText('Total');
    sheet.getRangeByIndex(totalRowIndex, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(totalRowIndex, 1).cellStyle.hAlign = xlsio.HAlignType.center;

    sheet.getRangeByIndex(totalRowIndex, 2).setNumber(netAmount);
    sheet.getRangeByIndex(totalRowIndex, 2).cellStyle.bold = true;
    sheet.getRangeByIndex(totalRowIndex, 2).cellStyle.hAlign = xlsio.HAlignType.center;

    final creditOrDebit = netAmount >= 0 ? 'Credit' : 'Debit';
    sheet.getRangeByIndex(totalRowIndex, 3).setText(creditOrDebit);
    sheet.getRangeByIndex(totalRowIndex, 3).cellStyle.bold = true;
    sheet.getRangeByIndex(totalRowIndex, 3).cellStyle.hAlign = xlsio.HAlignType.center;

    // Set thick border for total row
    final totalRange = sheet.getRangeByIndex(totalRowIndex, 1, totalRowIndex, 2);
    totalRange.cellStyle.borders.all.lineStyle = xlsio.LineStyle.medium;

    // Save to bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    return bytes;
  }

  Future<Uint8List?> fetchImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }

  Future<void> shareOrOpenExpenseSummaryPdf() async {
    try {
      final userDocData = widget.userDoc.data() as Map<String, dynamic>;

      final userEmail = userDocData['email'];
      final userName = userDocData['username'];
      // final userName = _getUsernameFromEmail(userEmail);

      final expenses = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(widget.userDoc.id)
          .collection('expense')
          .get()
          .then((snapshot) => snapshot.docs);

      final pdf = generateExpenseSummaryPDF(userName, userEmail, expenses);

      final pdfBytes = await pdf.save();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ExpenseSummary.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      controller.loadingDialog.value = false;
      await showFileActionDialogPdf(filePath);
    } catch (e) {
      print("Error generating or sharing PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate or share PDF: $e')),
      );
    }
  }

  Future<void> showFileActionDialogPdf(String filePath) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Action'),
          content: Text('Do you want to open or share the PDF file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerPage(path: filePath),
                  ),
                );
              },
              child: Text('Open'),
            ),
            TextButton(
              onPressed: () async {
                XFile fileName = XFile(filePath);
                Navigator.of(context).pop();
                await Share.shareXFiles([fileName], text: 'Expense Summary PDF');
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  pw.Document generateExpenseSummaryPDF(String userName, String userEmail, List<DocumentSnapshot> expenses) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          children: [
            pw.Text(
              'Expense Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Name : $userName',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Email: $userEmail',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              DateFormat('dd-MM-yyyy').format(DateTime.now()),
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Expense Details',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColor.fromInt(0xFF9E9E9E)),
              children: [
                // Table header row
                pw.TableRow(
                  children: [
                    pw.Text('Title',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Amount',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Type',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Category',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Time',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  ],
                ),
                // Table data rows
                ...expenses.map((expense) {
                  final data = expense.data() as Map<String, dynamic>;
                  return pw.TableRow(
                    children: [
                      pw.Text(data['title'], textAlign: pw.TextAlign.center),
                      pw.Text('${data['amount'].toStringAsFixed(2)}', textAlign: pw.TextAlign.center),
                      pw.Text(data['transactionType'], textAlign: pw.TextAlign.center),
                      pw.Text(data['category'], textAlign: pw.TextAlign.center),
                      // pw.Text(data['date'], textAlign: pw.TextAlign.center),
                      // pw.Text(data['time'], textAlign: pw.TextAlign.center),
                      pw.Text(data.containsKey('date') && data['date'] != '' ? data['date'] : '--',
                          textAlign: pw.TextAlign.center),
                      pw.Text(data.containsKey('time') && data['time'] != '' ? data['time'] : '--',
                          textAlign: pw.TextAlign.center),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  /*String _getUsernameFromEmail(String email) {
    return email.split('@').first;
  }*/

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _remarkController.dispose();
    _categoryController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Filter",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            CupertinoIcons.clear,
                            color: Colors.black,
                          )),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                ListTile(
                  title: Text('Title'),
                  trailing: _sortField == 'title' ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _sortField = 'title';
                      _isAscending = true;
                    });
                    setModalState(() {});
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Amount (High to Low)'),
                  trailing: _sortField == 'amount' && !_isAscending ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _sortField = 'amount';
                      _isAscending = false;
                    });
                    setModalState(() {});
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Amount (Low to High)'),
                  trailing: _sortField == 'amount' && _isAscending ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _sortField = 'amount';
                      _isAscending = true;
                    });
                    setModalState(() {});
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Date (Newest to Oldest)'),
                  trailing: _sortField == 'date' && !_isAscending ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _sortField = 'date';
                      _isAscending = false;
                    });
                    setModalState(() {});
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Date (Oldest to Newest)'),
                  trailing: _sortField == 'date' && _isAscending ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _sortField = 'date';
                      _isAscending = true;
                    });
                    setModalState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editExpense(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>? ?? {};

    final title = document['title'];
    final amount = document['amount'].toString();
    final date = document['date'];
    final time = document['time'];
    final remark = document['remark'];
    final category = document['category'];
    final paymentMode = document['payment_mode'];
    final address = data.containsKey('siteAddress') ? data['siteAddress'] : null;
    // final address = document['siteAddress'] ?? "";
    final transactionType = document['transactionType'] == 'credit' ? TransactionType.credit : TransactionType.debit;
    final imageUrl = (document['imageUrl'] != null) ? document['imageUrl'] : "";

    // String formattedDate = date != null && date.isNotEmpty
    //     ? DateFormat('dd-MM-yyyy').format(DateTime.parse(date))
    //     : '--';

    // Future<void> deleteExpense(BuildContext context, String adminId, String documentId) async {
    //   Navigator.of(context).pop();
    //   try {
    //     await FirebaseFirestore.instance
    //         .collection('Admin')
    //         .doc(adminId)
    //         .collection('expense')
    //         .doc(documentId)
    //         .delete()
    //         .then((_) {
    //       Fluttertoast.showToast(msg: "Expense Deleted Successfully");
    //     }).catchError((error) {
    //       Fluttertoast.showToast(msg: "Error Deleting: $error");
    //     });
    //   } catch (e) {
    //     Fluttertoast.showToast(msg: "Unexpected Error: $e");
    //     print("Unexpected Error: $e");
    //   }
    // }

    Future<void> deleteExpense(BuildContext context, String adminId, String documentId) async {
      deleteController.showLoader.value = true;
      try {
        // Fetch the expense document to get the imageUrl
        final expenseDoc = await FirebaseFirestore.instance
            .collection('Admin')
            .doc(adminId)
            .collection('expense')
            .doc(documentId)
            .get();

        if (expenseDoc.exists) {
          final imageUrl = expenseDoc.data()?['imageUrl'];

          // If imageUrl is present, delete the image from Firebase Storage
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final oldImageRef = FirebaseStorage.instance.refFromURL(imageUrl);
            await oldImageRef.delete();
            print("Image deleted successfully from Firebase Storage");
          }

          // Now delete the expense document
          await FirebaseFirestore.instance
              .collection('Admin')
              .doc(adminId)
              .collection('expense')
              .doc(documentId)
              .delete()
              .then((_) {
            Fluttertoast.showToast(msg: "Expense Deleted Successfully");
          }).catchError((error) {
            Fluttertoast.showToast(msg: "Error Deleting: $error");
          });
        } else {
          Fluttertoast.showToast(msg: "Expense does not exist");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Unexpected Error: $e");
        print("Unexpected Error: $e");
      } finally {
        deleteController.showLoader.value = false;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String formatDate(String date) {
          if (date == '' || date.isEmpty) {
            return '-No Date-';
          }

          try {
            final parsedDate = DateTime.parse(date);
            final formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
            return formattedDate;
          } catch (e) {
            return '-Invalid Date-';
          }
        }

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Expense Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // SizedBox(
              //   height: 50,
              // ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: kblack,
                ), // Use IconButton for X icon
                onPressed: () => Navigator.of(context).pop(), // Close dialog
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to left
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Align labels and values
                children: [
                  Text(
                    'Title:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Text(
                    title
                    // "Hello world how are you is every thing all right i cant find you "
                    ,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  )),
                ],
              ),
              const SizedBox(height: 8), // Add spacing between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      '₹${double.tryParse(amount)?.toStringAsFixed(double.tryParse(amount)!.truncateToDouble() == double.tryParse(amount) ? 0 : 2) ?? '0'}',
                    ),
                  ), // Assuming currency symbol
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Type:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(transactionType == TransactionType.credit ? 'Credit' : 'Debit'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(formatDate(date)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(time),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  // Spacer(),
                  Expanded(
                      child: Text(
                    category
                    // "Hello world how are you is every thing all right i cant find you "
                    ,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Mode:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(paymentMode),
                ],
              ),
              if (data.containsKey('siteAddress') && document['siteAddress']?.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Address:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        // Spacer(),
                        Expanded(
                            child: Text(
                          address
                          // "Hello world how are you is every thing all right i cant find you "
                          ,
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        )),
                      ],
                    ),
                  ],
                ),
              if (document['remark']?.isNotEmpty ?? false)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remark:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        // Spacer(),
                        Expanded(
                            child: Text(
                          remark
                          // "Hello world how are you is every thing all right i cant find you "
                          ,
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        )),
                      ],
                    ),
                  ],
                ),
              if (imageUrl != "")
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bill Photo:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () async {
                            double screenHeight = MediaQuery.of(context).size.height;
                            double targetHeight = screenHeight * 0.75;
                            await showDialog(
                              context: context,
                              builder: (_) => Center(
                                child: Container(
                                  height: targetHeight,
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 25),
                                  // color: Color(0xffeeeeee),
                                  color: Colors.transparent,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: PhotoViewGallery.builder(
                                        itemCount: 1,
                                        builder: (context, index) {
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider: imageUrl != null || imageUrl != ""
                                                ? NetworkImage(imageUrl) as ImageProvider<Object>?
                                                : AssetImage("assets/images/app-logo-bg.png"),
                                            minScale: PhotoViewComputedScale.contained * 1,
                                            maxScale: PhotoViewComputedScale.covered * 2,
                                          );
                                        },
                                        scrollPhysics: BouncingScrollPhysics(),
                                        backgroundDecoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        pageController: PageController(),
                                        loadingBuilder: (context, progress) {
                                          if (progress == null) {
                                            return SizedBox.shrink();
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: progress.expectedTotalBytes != null
                                                    ? progress.cumulativeBytesLoaded /
                                                        (progress.expectedTotalBytes ?? 1)
                                                    : null,
                                                color: Colors.white, // Set the color to white
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                      color: themecolor,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                // Delete expense from Firestore
                // try{
                //   FirebaseFirestore.instance.collection('Admin').doc().collection('expense').doc(document.id).delete().then((_) {
                //     Navigator.of(context).pop(); // Close dialog after deletion
                //   });
                // } catch (e) {
                //   Fluttertoast.showToast(msg: "Error Deleting $e");
                // }

                Navigator.of(context).pop();
                deleteExpense(context, widget.userDoc.id, document.id);

                // Navigator.of(context).pop();
                // FirebaseFirestore.instance
                //     .collection('Users')
                //     .doc(widget.userDoc.id)
                //     .collection('expenses')
                //     .doc(document.id)
                //     .delete()
                //     .then((_) {
                //   // Close dialog after deletion
                // });
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ),
            // SizedBox(
            //   width: 100,
            // ),
            TextButton(
              onPressed: () {
                // Navigate to edit expense page (replace with your implementation)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddAdminExpense(
                              adminId: widget.adminId,
                              documentData: document,
                              userDoc: widget.userDoc,
                            ))).then((_) => Navigator.of(context).pop()); // Close dialog after navigation
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    TextEditingController titleFilterController = TextEditingController(text: _titleFilter);
    TextEditingController fromDateFilterController = TextEditingController(text: _fromDateFilter);
    TextEditingController toDateFilterController = TextEditingController(text: _toDateFilter);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Apply Filters'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextFormField(
                //   controller: titleFilterController,
                //   decoration: const InputDecoration(
                //     labelText: 'Title',
                //   ),
                // ),
                TextFormField(
                  controller: fromDateFilterController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _fromDateFilter.isEmpty ? DateTime.now() : DateFormat('dd-MM-yyyy').parse(_fromDateFilter),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      fromDateFilterController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'From Date',
                  ),
                ),
                TextFormField(
                  controller: toDateFilterController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _toDateFilter.isEmpty ? DateTime.now() : DateFormat('dd-MM-yyyy').parse(_toDateFilter),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      toDateFilterController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'To Date',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    // ignore: deprecated_member_use
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    // ignore: deprecated_member_use
                    backgroundColor: MaterialStatePropertyAll(themecolor),
                  ),
                  onPressed: () {
                    setState(() {
                      titleFilterController.text = '';
                      _fromDateFilter = '';
                      _toDateFilter = '';
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    // ignore: deprecated_member_use
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    // ignore: deprecated_member_use
                    backgroundColor: MaterialStatePropertyAll(themecolor),
                  ),
                  onPressed: () {
                    setState(() {
                      _titleFilter = titleFilterController.text;
                      _fromDateFilter = fromDateFilterController.text;
                      _toDateFilter = toDateFilterController.text;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the snapshot to calculate the total amount

    _timeController.text = TimeOfDay.now().format(context);
    selectedCategory = _categories.isNotEmpty ? _categories[0] : null;

    final expenseStream =
        FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('expense').snapshots();

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Show the exit confirmation dialog and wait for the user's response
        bool exit = await _showExitConfirmationDialog(context);
        // Return true to allow exiting if the user confirms, false otherwise
        return exit;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: themecolor,
          automaticallyImplyLeading: false,
          title: const Text(
            'Expense',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite
                // backgroundColor: Color(0xff0393f4),
                ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: kwhite,
              ),
              onPressed: () => _showFilterDialog(context),
            ),
            IconButton(
              icon: Icon(
                Icons.sort,
                color: kwhite,
              ),
              onPressed: _showSortBottomSheet,
            ),
            IconButton(
              icon: Icon(
                Icons.download,
                color: kwhite,
              ),
              onPressed: () async {
                await _showDownloadOptions(context);
              },
            ),
          ],
          iconTheme: IconThemeData(color: kwhite),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: expenseStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No expenses found.',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              );
            }

            List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;

            if (_fromDateFilter.isNotEmpty) {
              DateTime fromDate = DateTime.parse(_fromDateFilter);
              sortedDocs = sortedDocs.where((doc) {
                String dateStr = (doc.data() as Map<String, dynamic>)['date'] ?? '';
                DateTime docDate;
                try {
                  docDate = DateTime.parse(dateStr);
                } catch (e) {
                  return false; // Skip documents with invalid date format
                }
                return docDate.isAfter(fromDate) || docDate.isAtSameMomentAs(fromDate);
              }).toList();
            }

            if (_toDateFilter.isNotEmpty) {
              DateTime toDate = DateTime.parse(_toDateFilter);
              sortedDocs = sortedDocs.where((doc) {
                String dateStr = (doc.data() as Map<String, dynamic>)['date'] ?? '';
                DateTime docDate;
                try {
                  docDate = DateTime.parse(dateStr);
                } catch (e) {
                  return false; // Skip documents with invalid date format
                }
                return docDate.isBefore(toDate) || docDate.isAtSameMomentAs(toDate);
              }).toList();
            }

            // Sorting logic
            sortedDocs.sort((a, b) {
              var aValue = (a.data() as Map<String, dynamic>)[_sortField];
              var bValue = (b.data() as Map<String, dynamic>)[_sortField];
              if (aValue is String && bValue is String) {
                return _isAscending
                    ? aValue.toLowerCase().compareTo(bValue.toLowerCase())
                    : bValue.toLowerCase().compareTo(aValue.toLowerCase());
              } else if (aValue is num && bValue is num) {
                return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
              } else if (aValue is Timestamp && bValue is Timestamp) {
                var aDate = aValue.toDate();
                var bDate = bValue.toDate();
                return _isAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
              }
              return 0; // Default case, if the types don't match
            });

            // Calculate the total amount
            double totalAmount = sortedDocs.fold(0.0, (sum, document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              double amount = data['amount'];
              String transactionType = data['transactionType'];
              if (transactionType == 'credit') {
                return sum + amount;
              } else if (transactionType == 'debit') {
                return sum - amount;
              } else {
                return sum; // In case of unknown transaction type, no change to sum
              }
            });

            // ignore: deprecated_member_use
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      _buildExpenseList(context, sortedDocs), // Pass sortedDocs here if needed
                      const SizedBox(
                          height: 75), // Space to ensure content is not hidden under the total amount container
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      height: 50,
                      color: themecolor,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        // bottom: 0,
                        // left: 0,
                        // right: 0,
                        padding: EdgeInsets.all(0),
                        child: Card(
                          elevation: 5,
                          margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            // margin: EdgeInsets.only(top: 10),
                            height: 65,
                            // padding: const EdgeInsets.symmetric(horizontal: 20),
                            // color: Colors.transparent,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    spreadRadius: 0.5,
                                    blurRadius: 2,
                                  )
                                ]),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Total Amount",
                                      textAlign: TextAlign.center,
                                      // ignore: deprecated_member_use
                                      textScaleFactor: 1.4,
                                      style: TextStyle(
                                        color: themecolor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        color: themecolor,
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            (totalAmount >= 0.0)
                                                ? '₹${totalAmount.toStringAsFixed(2)}'
                                                : '₹${totalAmount.abs().toString()} Dr',
                                            // ignore: deprecated_member_use
                                            textScaleFactor: 1.4,
                                            style: TextStyle(
                                              color: totalAmount >= 0.0 ? Colors.white : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(() => controller.loadingDialog.isTrue || deleteController.showLoader.isTrue
                    ? Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 100),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              border: Border.all(color: themecolor, width: 1)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                controller.loadingDialog.isTrue
                                    ? "Generating Excel file please wait..."
                                    : "Deleting Expense...",
                                style: TextStyle(color: themecolor),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CircularProgressIndicator(
                                color: themecolor,
                              )
                            ],
                          ),
                        ),
                      )
                    : SizedBox()),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: themecolor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAdminExpense(
                  adminId: widget.adminId,
                  userDoc: widget.userDoc,
                ),
              ),
            );

            // showDialog(
            //   context: context,
            //   barrierDismissible: false,
            //   builder: (BuildContext context) {
            //     return AlertDialog(
            //       title: const Text('Add Transaction'),
            //       content: SingleChildScrollView(
            //         child: Form(
            //           key: _formKey,
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               TextFormField(
            //                 controller: _titleController,
            //                 keyboardType: TextInputType.text,
            //                 decoration: const InputDecoration(
            //                   labelText: 'Title',
            //                   prefixIcon: Icon(Icons.title),
            //                 ),
            //                 validator: (value) =>
            //                     value!.isEmpty ? 'Enter the title' : null,
            //               ),
            //               TextFormField(
            //                 controller: _amountController,
            //                 keyboardType: TextInputType.number,
            //                 decoration: const InputDecoration(
            //                   labelText: 'Amount',
            //                   prefixIcon: Icon(Icons.currency_rupee),
            //                 ),
            //                 validator: (value) =>
            //                     value!.isEmpty ? 'Enter the amount' : null,
            //               ),
            //               DropdownButtonFormField<String>(
            //                 value: _selectedCategory,
            //                 items: _categories.map((String category) {
            //                   return DropdownMenuItem<String>(
            //                     value: category,
            //                     child: Text(category),
            //                   );
            //                 }).toList(),
            //                 onChanged: (newValue) {
            //                   _selectedCategory =
            //                       newValue; // Remove setState from here
            //                 },
            //                 decoration: const InputDecoration(
            //                   labelText: 'Category',
            //                   prefixIcon: Icon(Icons.category),
            //                 ),
            //                 validator: (value) {
            //                   if (value == null || value.isEmpty) {
            //                     return 'Please select a category';
            //                   }
            //                   return null;
            //                 },
            //               ),
            //               TextFormField(
            //                 controller: _dateController,
            //                 readOnly: true,
            //                 onTap: () async {
            //                   final DateTime? pickedDate =
            //                       await showDatePicker(
            //                     context: context,
            //                     initialDate: DateTime.now(),
            //                     firstDate: DateTime(2000),
            //                     lastDate: DateTime(2101),
            //                   );
            //                   if (pickedDate != null) {
            //                     setState(() {
            //                       _dateController.text =
            //                           DateFormat('yyyy-MM-dd')
            //                               .format(pickedDate);
            //                     });
            //                   }
            //                 },
            //                 decoration: const InputDecoration(
            //                   labelText: 'Date',
            //                   prefixIcon: Icon(Icons.calendar_today),
            //                 ),
            //               ),
            //               TextFormField(
            //                 controller: _timeController,
            //                 readOnly: true,
            //                 onTap: () async {
            //                   final TimeOfDay? pickedTime =
            //                       await showTimePicker(
            //                     context: context,
            //                     initialTime: TimeOfDay.now(),
            //                   );
            //                   if (pickedTime != null) {
            //                     setState(() {
            //                       _timeController.text =
            //                           pickedTime.format(context);
            //                     });
            //                   }
            //                 },
            //                 decoration: const InputDecoration(
            //                   labelText: 'Time',
            //                   prefixIcon: Icon(Icons.access_time),
            //                 ),
            //               ),
            //               DropdownButtonFormField<TransactionType>(
            //                 value: _transactionType,
            //                 onChanged: (value) {
            //                   setState(() {
            //                     _transactionType = value!;
            //                   });
            //                 },
            //                 items: TransactionType.values
            //                     .map((type) => DropdownMenuItem(
            //                           value: type,
            //                           child: Text(
            //                             type == TransactionType.credit
            //                                 ? 'Credit'
            //                                 : 'Debit',
            //                           ),
            //                         ))
            //                     .toList(),
            //                 decoration: const InputDecoration(
            //                   labelText: 'Type',
            //                   prefixIcon: Icon(Icons.credit_card),
            //                 ),
            //               ),
            //               TextFormField(
            //                 controller: _remarkController,
            //                 keyboardType: TextInputType.text,
            //                 decoration: const InputDecoration(
            //                   labelText: 'Remark',
            //                   prefixIcon: Icon(Icons.note),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       actions: [
            //         TextButton(
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //           child: const Text('Cancel'),
            //         ),
            //         ElevatedButton(
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //             if (_formKey.currentState != null &&
            //                 _formKey.currentState!.validate()) {
            //               _submitForm(context);
            //               // Navigator.of(context).pop();
            //             }
            //           },
            //           child: const Text('Save'),
            //         ),
            //       ],
            //     );
            //   },
            // );
          },
          child: const Icon(
            Icons.add,
            color: kwhite,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, List<DocumentSnapshot> sortedDocs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDocs.length,
      itemBuilder: (context, index) {
        DocumentSnapshot document = sortedDocs[index];
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        // Define hasRemark based on whether remark is present and not empty
        bool hasRemark = data.containsKey('remark') && data['remark'] != null && data['remark'].isNotEmpty;
        String formattedDate;
        try {
          formattedDate = DateFormat('dd-MM').format(DateTime.parse(data['date']));
        } catch (e) {
          formattedDate = "--";
        }

        return GestureDetector(
          onTap: () => _editExpense(context, document),
          child: Card(
            color: Colors.grey[100],
            elevation: 3,
            margin: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            child: ListTile(
              tileColor: kwhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['title']}",
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${formattedDate}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                        if (hasRemark) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.note, size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  data['remark'],
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${data['time']}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${data['category']}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            '₹${double.tryParse(data['amount'].toString())?.toStringAsFixed(double.tryParse(data['amount'].toString())!.truncateToDouble() == double.tryParse(data['amount'].toString()) ? 0 : 2) ?? '0'}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: data['transactionType'] == 'credit' ? Color(0xFFDBE6CF) : Color(0xFFF7D3C6),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: Text(
                            data['transactionType'] == 'credit' ? 'Cr' : 'Dr',
                            style: TextStyle(
                              color: data['transactionType'] == 'credit' ? Color(0xFF6F9C40) : Color(0xFFAE2F09),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    // Always return true to allow exiting without confirmation dialog
    return true;
  }
}

/*Future<void> _showDownloadOptions(BuildContext context) async {
    String? _selectedOption = 'PDF'; // Default option

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              title: Text('Download as'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: const Text('PDF'),
                    value: 'PDF',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Excel'),
                    value: 'Excel',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(themecolor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 15)),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(themecolor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(_selectedOption);
                  },
                  child: Text('Download', style: TextStyle(fontSize: 15)),
                ),
              ],
            );
          },
        );
      },
    ).then((String? selectedOption) async {
      if (selectedOption != null) {
        if (selectedOption == 'PDF') {
          await shareExpenseSummary();
        } else if (selectedOption == 'Excel') {
          // await shareExpenseSummaryExcel();
          await shareOrOpenExpenseSummaryExcel();
        }
      }
    });
  }*/

/*
  Future<void> shareExpenseSummary() async {
    // Fetch user document data
    final userDocData = widget.userDoc.data() as Map<String, dynamic>;

    // Extract username from the email
    final Email = userDocData['email'];
    final Name = _getUsernameFromEmail(Email);

    // Fetch expenses from Firestore
    final expense = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(widget.userDoc.id)
        .collection('expense')
        .get()
        .then((snapshot) => snapshot.docs);

    // Generate the PDF document
    final pdf = generateExpenseSummaryPDF(Name, Email, expense);

    // Share the PDF document
    await shareExpenseSummaryPDF(pdf);
  }

  Future<void> shareExpenseSummaryPDF(pw.Document pdf) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/expense_summary.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareFiles([file.path], mimeTypes: ['application/pdf']);
  }

  pw.Document generateExpenseSummaryPDF(String userName, String userEmail, List<DocumentSnapshot> expenses) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          children: [
            // Heading section
            pw.Text(
              'Expense Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Name : $userName',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Email: $userEmail',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              DateFormat('dd-MM-yyyy').format(DateTime.now()),
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 16),

            // Expense details heading
            pw.Text(
              'Expense Details',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            // Expense table
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColor.fromInt(0xFF9E9E9E)),
              children: [
                // Table header row
                pw.TableRow(
                  children: [
                    pw.Text('Title',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Amount',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Type',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Category',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    pw.Text('Time',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  ],
                ),
                // Table data rows
                ...expenses.map((expense) {
                  final data = expense.data() as Map<String, dynamic>;
                  return pw.TableRow(
                    children: [
                      pw.Text(data['title'], textAlign: pw.TextAlign.center),
                      pw.Text('${data['amount'].toStringAsFixed(2)}', textAlign: pw.TextAlign.center),
                      pw.Text(data['transactionType'], textAlign: pw.TextAlign.center),
                      pw.Text(data['category'], textAlign: pw.TextAlign.center),
                      // pw.Text(data['date'], textAlign: pw.TextAlign.center),
                      // pw.Text(data['time'], textAlign: pw.TextAlign.center),
                      pw.Text(data.containsKey('date') && data['date'] != '' ? data['date'] : '--',
                          textAlign: pw.TextAlign.center),
                      pw.Text(data.containsKey('time') && data['time'] != '' ? data['time'] : '--',
                          textAlign: pw.TextAlign.center),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  String _getUsernameFromEmail(String email) {
    return email.split('@').first;
  }

  Future<void> shareOrOpenExpenseSummaryExcel() async {
    // Fetch user document data
    final userDocData = widget.userDoc.data() as Map<String, dynamic>;

    // Extract username from the email
    final email = userDocData['email'];
    final name = _getUsernameFromEmail(email);

    // Fetch expenses from Firestore
    final expenses = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(widget.userDoc.id)
        .collection('expense')
        .get()
        .then((snapshot) => snapshot.docs);

    // Generate the Excel document
    final excelFile = generateExpenseSummaryExcel(name, email, expenses);

    // Save the file locally
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/ExpenseSummary.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excelFile);

    // Show dialog to ask user for action
    _showFileActionDialog(filePath);
  }

  Future<void> _showFileActionDialog(String filePath) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Action'),
          content: Text('Do you want to open or share the Excel file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openExcelFile(filePath);
              },
              child: Text('Open'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareExcelFile(filePath);
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openExcelFile(String filePath) async {
    try {
      // Open the file using the open_file package
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open file: $e')),
      );
    }
  }

  Future<void> _shareExcelFile(String filePath) async {
    try {
      // Share the file using the share package
      await Share.shareFiles([filePath], text: 'Expense Summary');
    } catch (e) {
      print('Error sharing file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share file: $e')),
      );
    }
  }

  Future<void> shareExpenseSummaryExcel() async {
    // Fetch user document data
    final userDocData = widget.userDoc.data() as Map<String, dynamic>;

    // Extract username from the email
    final email = userDocData['email'];
    final name = _getUsernameFromEmail(email);

    // Fetch expenses from Firestore
    final expenses = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(widget.userDoc.id)
        .collection('expense')
        .get()
        .then((snapshot) => snapshot.docs);

    // Generate the Excel document
    final excelFile = generateExpenseSummaryExcel(name, email, expenses);

    // Share the Excel document
    await shareExcelFile(excelFile);
  }

  Future<void> shareExcelFile(List<int> excelFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ExpenseSummary.xlsx');
    await file.writeAsBytes(excelFile);

    // Share the file using a sharing plugin
    await Share.shareFiles([file.path], text: 'Expense Summary');
  }

  List<int> generateExpenseSummaryExcel(String userName, String userEmail, List<DocumentSnapshot> expenses) {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Set heading styles
    final headingStyle = workbook.styles.add('headingStyle');
    headingStyle.fontSize = 18;
    headingStyle.bold = true;
    headingStyle.hAlign = xlsio.HAlignType.center;

    // Set bold style for the table headers
    final boldStyle = workbook.styles.add('boldStyle');
    boldStyle.bold = true;
    boldStyle.hAlign = xlsio.HAlignType.center;

    // Set user details
    final detailsStyle = workbook.styles.add('detailsStyle');
    detailsStyle.hAlign = xlsio.HAlignType.center;

    sheet.getRangeByIndex(1, 1).setText('Expense Summary');
    sheet.getRangeByIndex(1, 1).cellStyle = headingStyle;

    sheet.getRangeByIndex(2, 1).setText('Name: $userName');
    sheet.getRangeByIndex(2, 1).cellStyle = detailsStyle;

    sheet.getRangeByIndex(3, 1).setText('Email: $userEmail');
    sheet.getRangeByIndex(3, 1).cellStyle = detailsStyle;

    sheet.getRangeByIndex(4, 1).setText(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    sheet.getRangeByIndex(4, 1).cellStyle = detailsStyle;

    // Merge cells for user details to center-align them
    sheet.getRangeByIndex(1, 1, 1, 6).merge();
    sheet.getRangeByIndex(2, 1, 2, 6).merge();
    sheet.getRangeByIndex(3, 1, 3, 6).merge();
    sheet.getRangeByIndex(4, 1, 4, 6).merge();

    // Set table headers
    const headers = ['Title', 'Amount', 'Type', 'Category', 'Date', 'Time'];
    for (int col = 0; col < headers.length; col++) {
      sheet.getRangeByIndex(6, col + 1).setText(headers[col]);
      sheet.getRangeByIndex(6, col + 1).cellStyle = boldStyle;
      sheet.getRangeByIndex(6, col + 1).columnWidth = 20;
    }

    // Populate expense data
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i].data() as Map<String, dynamic>;

      sheet.getRangeByIndex(7 + i, 1).setText(expense['title'] ?? '--');
      sheet.getRangeByIndex(7 + i, 2).setText(expense['amount'] != null ? '${expense['amount'].toStringAsFixed(2)}' : '--');
      sheet.getRangeByIndex(7 + i, 3).setText(expense['transactionType'] ?? '--');
      sheet.getRangeByIndex(7 + i, 4).setText(expense['category'] ?? '--');
      sheet.getRangeByIndex(7 + i, 5).setText(expense.containsKey('date') && expense['date'] != '' ? expense['date'] : '--');
      sheet.getRangeByIndex(7 + i, 6).setText(expense.containsKey('time') && expense['time'] != '' ? expense['time'] : '--');

      if (expense.containsKey('imageUrl') && expense['imageUrl'] != '') {
        final imageBytesFuture = fetchImageBytes(expense['imageUrl']);
        imageBytesFuture.then((imageBytes) {
          if (imageBytes != null) {
            final rowIndex = 7 + i;
            final columnIndex = 7; // Image column
            sheet.pictures.addStream(rowIndex, columnIndex, imageBytes);
            sheet.getRangeByIndex(rowIndex, columnIndex).rowHeight = 100; // Adjust row height for the image
          }
        });
      }

      // Center-align data
      for (int j = 1; j <= 6; j++) {
        sheet.getRangeByIndex(7 + i, j).cellStyle.hAlign = xlsio.HAlignType.center;
      }
    }

    // Save the Excel file to bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    return bytes;
  }

  Future<Uint8List?> fetchImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }
  */

/*List<int> generateExpenseSummaryExcel(String userName, String userEmail, List<DocumentSnapshot> expenses) {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Set heading styles
    final headingStyle = workbook.styles.add('headingStyle');
    headingStyle.fontSize = 18;
    headingStyle.bold = true;
    headingStyle.hAlign = xlsio.HAlignType.center;

    // Set bold style for the table headers
    final boldStyle = workbook.styles.add('boldStyle');
    boldStyle.bold = true;
    boldStyle.hAlign = xlsio.HAlignType.center;

    // Set user details
    final detailsStyle = workbook.styles.add('detailsStyle');
    detailsStyle.hAlign = xlsio.HAlignType.center;

    sheet.getRangeByIndex(1, 1).setText('Expense Summary');
    sheet.getRangeByIndex(1, 1).cellStyle = headingStyle;

    sheet.getRangeByIndex(2, 1).setText('Name: $userName');
    sheet.getRangeByIndex(2, 1).cellStyle = detailsStyle;

    sheet.getRangeByIndex(3, 1).setText('Email: $userEmail');
    sheet.getRangeByIndex(3, 1).cellStyle = detailsStyle;

    sheet.getRangeByIndex(4, 1).setText(DateFormat('dd-MM-yyyy').format(DateTime.now()));
    sheet.getRangeByIndex(4, 1).cellStyle = detailsStyle;

    // Merge cells for user details to center align them
    sheet.getRangeByIndex(1, 1, 1, 6).merge();
    sheet.getRangeByIndex(2, 1, 2, 6).merge();
    sheet.getRangeByIndex(3, 1, 3, 6).merge();
    sheet.getRangeByIndex(4, 1, 4, 6).merge();

    // Set table headers
    sheet.getRangeByIndex(6, 1).setText('Title');
    sheet.getRangeByIndex(6, 1).cellStyle = boldStyle;

    sheet.getRangeByIndex(6, 2).setText('Amount');
    sheet.getRangeByIndex(6, 2).cellStyle = boldStyle;

    sheet.getRangeByIndex(6, 3).setText('Type');
    sheet.getRangeByIndex(6, 3).cellStyle = boldStyle;

    sheet.getRangeByIndex(6, 4).setText('Category');
    sheet.getRangeByIndex(6, 4).cellStyle = boldStyle;

    sheet.getRangeByIndex(6, 5).setText('Date');
    sheet.getRangeByIndex(6, 5).cellStyle = boldStyle;

    sheet.getRangeByIndex(6, 6).setText('Time');
    sheet.getRangeByIndex(6, 6).cellStyle = boldStyle;

    // Adjust column widths
    sheet.getRangeByIndex(6, 1).columnWidth = 20; // Title
    sheet.getRangeByIndex(6, 2).columnWidth = 15; // Amount
    sheet.getRangeByIndex(6, 3).columnWidth = 15; // Type
    sheet.getRangeByIndex(6, 4).columnWidth = 20; // Category
    sheet.getRangeByIndex(6, 5).columnWidth = 15; // Date
    sheet.getRangeByIndex(6, 6).columnWidth = 15; // Time

    // Add expense data
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i].data() as Map<String, dynamic>;
      sheet.getRangeByIndex(7 + i, 1).setText(expense['title']);
      sheet.getRangeByIndex(7 + i, 2).setText('${expense['amount'].toStringAsFixed(2)}');
      sheet.getRangeByIndex(7 + i, 3).setText(expense['transactionType']);
      sheet.getRangeByIndex(7 + i, 4).setText(expense['category']);
      // sheet.getRangeByIndex(7 + i, 5).setText(expense['date']);
      // sheet.getRangeByIndex(7 + i, 6).setText(expense['time']);
      sheet
          .getRangeByIndex(7 + i, 5)
          .setText(expense.containsKey('date') && expense['date'] != '' ? expense['date'] : '--');
      sheet
          .getRangeByIndex(7 + i, 6)
          .setText(expense.containsKey('time') && expense['time'] != '' ? expense['time'] : '--');

      // Center align data rows
      for (int j = 1; j <= 6; j++) {
        sheet.getRangeByIndex(7 + i, j).cellStyle.hAlign = xlsio.HAlignType.center;
      }
    }

    // Save the Excel file to bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    return bytes;
  }*/

// Future<void> _submitForm(BuildContext context) async {
//   // Validate the form
//   if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
//     return; // If the form is not valid, do nothing
//   }
//
//   // Get the values from the form fields
//   String title = _titleController.text;
//   double amount = double.parse(_amountController.text);
//   String date = _dateController.text;
//   String time = _timeController.text;
//   String remark = _remarkController.text;
//   String category = _selectedCategory ?? '';
//   // Create a new document in the 'expenses' collection for the current user
//   try {
//     await FirebaseFirestore.instance
//         .collection('Admin')
//         .doc(widget.userDoc.id)
//         .collection('expense')
//         .add({
//       'title': title,
//       'amount': amount,
//       'date': date,
//       'time': time,
//       'remark': remark,
//       'category': category,
//       'transactionType':
//           _transactionType == TransactionType.credit ? 'credit' : 'debit',
//       'createdAt':
//           FieldValue.serverTimestamp(), // Timestamp of when the data is added
//     });
//
//     // Show a success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Expense added successfully'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//
//     // Clear the form fields
//     _titleController.clear();
//     _amountController.clear();
//     _dateController.clear();
//     _timeController.clear();
//     _remarkController.clear();
//     _categoryController.clear();
//     setState(() {
//       _transactionType =
//           TransactionType.credit; // Reset transaction type to credit
//     });
//   } catch (error) {
//     // Show an error message if something goes wrong
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Failed to add expense: $error'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }

/*Widget _buildExpenseList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Admin').doc(widget.adminId).collection('expense').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themecolor),
            )),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Center(
                  child: Text(
                'No expenses found.',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
              )));
        }

        List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;

        /*if (_fromDateFilter.isNotEmpty) {
          DateTime fromDate = DateTime.parse(_fromDateFilter);
          sortedDocs = sortedDocs.where((doc) {
            DateTime docDate = DateTime.parse((doc.data() as Map<String, dynamic>)['date']);
            return docDate.isAfter(fromDate) || docDate.isAtSameMomentAs(fromDate);
          }).toList();
        }

        if (_toDateFilter.isNotEmpty) {
          DateTime toDate = DateTime.parse(_toDateFilter);
          sortedDocs = sortedDocs.where((doc) {
            DateTime docDate = DateTime.parse((doc.data() as Map<String, dynamic>)['date']);
            return docDate.isBefore(toDate) || docDate.isAtSameMomentAs(toDate);
          }).toList();
        }

        // Sorting logic
        sortedDocs.sort((a, b) {
          var aValue = (a.data() as Map<String, dynamic>)[_sortField];
          var bValue = (b.data() as Map<String, dynamic>)[_sortField];

          if (aValue is String && bValue is String) {
            return _isAscending
                ? aValue.toLowerCase().compareTo(bValue.toLowerCase())
                : bValue.toLowerCase().compareTo(aValue.toLowerCase());
          } else if (aValue is num && bValue is num) {
            return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
          } else if (aValue is Timestamp && bValue is Timestamp) {
            var aDate = aValue.toDate();
            var bDate = bValue.toDate();
            return _isAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          }
          return 0; // Default case, if the types don't match
        });

        // Sorting logic
        sortedDocs.sort((a, b) {
          var aValue = (a.data() as Map<String, dynamic>)[_sortField];
          var bValue = (b.data() as Map<String, dynamic>)[_sortField];

          if (aValue is String && bValue is String) {
            return _isAscending
                ? aValue.toLowerCase().compareTo(bValue.toLowerCase())
                : bValue.toLowerCase().compareTo(aValue.toLowerCase());
          } else if (aValue is num && bValue is num) {
            return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
          } else if (aValue is Timestamp && bValue is Timestamp) {
            var aDate = aValue.toDate();
            var bDate = bValue.toDate();
            return _isAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          }
          return 0; // Default case, if the types don't match
        });

        // Calculate the total amount
        double totalAmount = sortedDocs.fold(0.0, (sum, document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          double amount = data['amount'];
          String transactionType = data['transactionType'];
          if (transactionType == 'credit') {
            return sum + amount;
          } else if (transactionType == 'debit') {
            return sum - amount;
          } else {
            return sum; // In case of unknown transaction type, no change to sum
          }
        });*/

        if (_fromDateFilter.isNotEmpty) {
          DateTime fromDate = DateTime.parse(_fromDateFilter);
          sortedDocs = sortedDocs.where((doc) {
            String dateStr = (doc.data() as Map<String, dynamic>)['date'] ?? '';
            DateTime docDate;
            try {
              docDate = DateTime.parse(dateStr);
            } catch (e) {
              return false; // Skip documents with invalid date format
            }
            return docDate.isAfter(fromDate) || docDate.isAtSameMomentAs(fromDate);
          }).toList();
        }

        if (_toDateFilter.isNotEmpty) {
          DateTime toDate = DateTime.parse(_toDateFilter);
          sortedDocs = sortedDocs.where((doc) {
            String dateStr = (doc.data() as Map<String, dynamic>)['date'] ?? '';
            DateTime docDate;
            try {
              docDate = DateTime.parse(dateStr);
            } catch (e) {
              return false; // Skip documents with invalid date format
            }
            return docDate.isBefore(toDate) || docDate.isAtSameMomentAs(toDate);
          }).toList();
        }

        // Sorting logic
        sortedDocs.sort((a, b) {
          var aValue = (a.data() as Map<String, dynamic>)[_sortField];
          var bValue = (b.data() as Map<String, dynamic>)[_sortField];

          if (aValue is String && bValue is String) {
            return _isAscending
                ? aValue.toLowerCase().compareTo(bValue.toLowerCase())
                : bValue.toLowerCase().compareTo(aValue.toLowerCase());
          } else if (aValue is num && bValue is num) {
            return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
          } else if (aValue is Timestamp && bValue is Timestamp) {
            var aDate = aValue.toDate();
            var bDate = bValue.toDate();
            return _isAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          }
          return 0; // Default case, if the types don't match
        });

        // Calculate the total amount
        double totalAmount = sortedDocs.fold(0.0, (sum, document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          double amount = data['amount'];
          String transactionType = data['transactionType'];
          if (transactionType == 'credit') {
            return sum + amount;
          } else if (transactionType == 'debit') {
            return sum - amount;
          } else {
            return sum; // In case of unknown transaction type, no change to sum
          }
        });

        // Build the UI  // Total Amount Display
        return Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: 35,
                  width: double.infinity,
                  color: themecolor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: 65,
                      // padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black45,
                        //     spreadRadius: 0.1,
                        //     blurRadius: 5,
                        //   ),
                        // ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the children horizontally
                        crossAxisAlignment: CrossAxisAlignment.center, // Center the children vertically
                        children: [
                          Expanded(
                            // flex: 3, // Adjust flex values to control the width of elements
                            child: Text(
                              "Total Amount",
                              textAlign: TextAlign.center, // Center align the text
                              style: TextStyle(
                                color: themecolor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            // flex: 2, // Adjust flex values to control the width of elements
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                color: themecolor,
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    (totalAmount >= 0.0)
                                        ? '₹${totalAmount.toStringAsFixed(2)}'
                                        : '₹${totalAmount.abs().toString()} Dr',
                                    // ignore: deprecated_member_use
                                    textScaleFactor: 1.4,
                                    style: TextStyle(
                                      color: totalAmount >= 0.0 ? Colors.white : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedDocs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = sortedDocs[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                // Define hasRemark based on whether remark is present and not empty
                bool hasRemark = data.containsKey('remark') && data['remark'] != null && data['remark'].isNotEmpty;

                String formattedDate;
                try {
                  formattedDate = DateFormat('dd-MM').format(DateTime.parse(data['date']));
                } catch (e) {
                  formattedDate = "--";
                }

                return GestureDetector(
                  onTap: () => _editExpense(context, document),
                  child: Card(
                    color: Colors.grey[100],
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: ListTile(
                      tileColor: kwhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${formattedDate}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                  ),
                                ),
                                if (hasRemark) ...[
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.note, size: 16, color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          data['remark'],
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${data['time']}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${data['category']}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    '₹${double.tryParse(data['amount'].toString())?.toStringAsFixed(double.tryParse(data['amount'].toString())!.truncateToDouble() == double.tryParse(data['amount'].toString()) ? 0 : 2) ?? '0'}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: data['transactionType'] == 'credit' ? Color(0xFFDBE6CF) : Color(0xFFF7D3C6),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  child: Text(
                                    data['transactionType'] == 'credit' ? 'Cr' : 'Dr',
                                    style: TextStyle(
                                      color:
                                          data['transactionType'] == 'credit' ? Color(0xFF6F9C40) : Color(0xFFAE2F09),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }*/

/*@override
  Widget build(BuildContext context) {
    // _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _timeController.text = TimeOfDay.now().format(context);
    selectedCategory = _categories.isNotEmpty ? _categories[0] : null;

    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          // Show the exit confirmation dialog and wait for the user's response
          bool exit = await _showExitConfirmationDialog(context);
          // Return true to allow exiting if the user confirms, false otherwise
          return exit;
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: themecolor,
            title: const Text(
              'Expense',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite
                  // backgroundColor: Color(0xff0393f4),
                  ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: kwhite,
                ),
                onPressed: () => _showFilterDialog(context),
              ),
              IconButton(
                icon: Icon(
                  Icons.sort,
                  color: kwhite,
                ),
                onPressed: _showSortBottomSheet,
              ),
              IconButton(
                icon: Icon(
                  Icons.download,
                  color: kwhite,
                ),
                onPressed: () async {
                  await _showDownloadOptions(context);
                },
              ),
            ],
            iconTheme: IconThemeData(color: kwhite),
          ),
          body: SingleChildScrollView(
            // padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExpenseList(context),
                const SizedBox(height: 75),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: themecolor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAdminExpense(
                    adminId: widget.adminId,
                    userDoc: widget.userDoc,
                  ),
                ),
              );

              // showDialog(
              //   context: context,
              //   barrierDismissible: false,
              //   builder: (BuildContext context) {
              //     return AlertDialog(
              //       title: const Text('Add Transaction'),
              //       content: SingleChildScrollView(
              //         child: Form(
              //           key: _formKey,
              //           child: Column(
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               TextFormField(
              //                 controller: _titleController,
              //                 keyboardType: TextInputType.text,
              //                 decoration: const InputDecoration(
              //                   labelText: 'Title',
              //                   prefixIcon: Icon(Icons.title),
              //                 ),
              //                 validator: (value) =>
              //                     value!.isEmpty ? 'Enter the title' : null,
              //               ),
              //               TextFormField(
              //                 controller: _amountController,
              //                 keyboardType: TextInputType.number,
              //                 decoration: const InputDecoration(
              //                   labelText: 'Amount',
              //                   prefixIcon: Icon(Icons.currency_rupee),
              //                 ),
              //                 validator: (value) =>
              //                     value!.isEmpty ? 'Enter the amount' : null,
              //               ),
              //               DropdownButtonFormField<String>(
              //                 value: _selectedCategory,
              //                 items: _categories.map((String category) {
              //                   return DropdownMenuItem<String>(
              //                     value: category,
              //                     child: Text(category),
              //                   );
              //                 }).toList(),
              //                 onChanged: (newValue) {
              //                   _selectedCategory =
              //                       newValue; // Remove setState from here
              //                 },
              //                 decoration: const InputDecoration(
              //                   labelText: 'Category',
              //                   prefixIcon: Icon(Icons.category),
              //                 ),
              //                 validator: (value) {
              //                   if (value == null || value.isEmpty) {
              //                     return 'Please select a category';
              //                   }
              //                   return null;
              //                 },
              //               ),
              //               TextFormField(
              //                 controller: _dateController,
              //                 readOnly: true,
              //                 onTap: () async {
              //                   final DateTime? pickedDate =
              //                       await showDatePicker(
              //                     context: context,
              //                     initialDate: DateTime.now(),
              //                     firstDate: DateTime(2000),
              //                     lastDate: DateTime(2101),
              //                   );
              //                   if (pickedDate != null) {
              //                     setState(() {
              //                       _dateController.text =
              //                           DateFormat('yyyy-MM-dd')
              //                               .format(pickedDate);
              //                     });
              //                   }
              //                 },
              //                 decoration: const InputDecoration(
              //                   labelText: 'Date',
              //                   prefixIcon: Icon(Icons.calendar_today),
              //                 ),
              //               ),
              //               TextFormField(
              //                 controller: _timeController,
              //                 readOnly: true,
              //                 onTap: () async {
              //                   final TimeOfDay? pickedTime =
              //                       await showTimePicker(
              //                     context: context,
              //                     initialTime: TimeOfDay.now(),
              //                   );
              //                   if (pickedTime != null) {
              //                     setState(() {
              //                       _timeController.text =
              //                           pickedTime.format(context);
              //                     });
              //                   }
              //                 },
              //                 decoration: const InputDecoration(
              //                   labelText: 'Time',
              //                   prefixIcon: Icon(Icons.access_time),
              //                 ),
              //               ),
              //               DropdownButtonFormField<TransactionType>(
              //                 value: _transactionType,
              //                 onChanged: (value) {
              //                   setState(() {
              //                     _transactionType = value!;
              //                   });
              //                 },
              //                 items: TransactionType.values
              //                     .map((type) => DropdownMenuItem(
              //                           value: type,
              //                           child: Text(
              //                             type == TransactionType.credit
              //                                 ? 'Credit'
              //                                 : 'Debit',
              //                           ),
              //                         ))
              //                     .toList(),
              //                 decoration: const InputDecoration(
              //                   labelText: 'Type',
              //                   prefixIcon: Icon(Icons.credit_card),
              //                 ),
              //               ),
              //               TextFormField(
              //                 controller: _remarkController,
              //                 keyboardType: TextInputType.text,
              //                 decoration: const InputDecoration(
              //                   labelText: 'Remark',
              //                   prefixIcon: Icon(Icons.note),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       actions: [
              //         TextButton(
              //           onPressed: () {
              //             Navigator.of(context).pop();
              //           },
              //           child: const Text('Cancel'),
              //         ),
              //         ElevatedButton(
              //           onPressed: () {
              //             Navigator.of(context).pop();
              //             if (_formKey.currentState != null &&
              //                 _formKey.currentState!.validate()) {
              //               _submitForm(context);
              //               // Navigator.of(context).pop();
              //             }
              //           },
              //           child: const Text('Save'),
              //         ),
              //       ],
              //     );
              //   },
              // );
            },
            child: const Icon(
              Icons.add,
              color: kwhite,
            ),
          ),
        ));
  }*/
