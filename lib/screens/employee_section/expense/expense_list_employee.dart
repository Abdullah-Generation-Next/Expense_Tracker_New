import 'dart:io';
// import 'dart:typed_data';
import 'package:etmm/const/const.dart';
import 'package:etmm/screens/employee_section/expense/add_expense_employee.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../../../getx_controller/load_excel_controller.dart';
import '../../../widget/pdf_viewer.dart';

enum TransactionType { credit, debit }

class ExpenseListEmployee extends StatefulWidget {
  final DocumentSnapshot userDoc;
  final DocumentSnapshot? DocumentData;
  final bool fromAdmin;

  const ExpenseListEmployee({Key? key, required this.userDoc, this.DocumentData, this.fromAdmin = false})
      : super(key: key);

  @override
  _ExpenseListEmployeeState createState() => _ExpenseListEmployeeState();
}

class _ExpenseListEmployeeState extends State<ExpenseListEmployee> {
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  String? selectedCategory;
  final List<String> _categories = ['Technology', 'Health', 'Finance', 'Education', 'Entertainment'];
  String? selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController titleController = TextEditingController();

  LoadExcelController controller = Get.put(LoadExcelController());
  DeleteController deleteController = Get.put(DeleteController());

  @override
  void initState() {
    super.initState();
    _fromDate = null;
    _toDate = null;
    selectedStatus = null;
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
        .collection('Users')
        .doc(widget.userDoc.id)
        .collection('expenses')
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
          .collection('Users')
          .doc(widget.userDoc.id)
          .collection('expenses')
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

  /*String _getUsernameFromEmail(String email) {
    return email.split('@').first;
  }*/

  String _sortField = 'title';
  bool _isAscending = true;

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempFromDate = _fromDate;
        DateTime? tempToDate = _toDate;
        TextEditingController tempTitleController = TextEditingController(text: _titleController.text);
        String? tempStatus = selectedStatus;

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Expenses'),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: tempFromDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      ).then((pickedDate) {
                        if (pickedDate != null) {
                          setState(() {
                            tempFromDate = pickedDate;
                          });
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('From Date'),
                        ),
                        // SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            tempFromDate != null ? DateFormat('dd-MM-yyyy').format(tempFromDate!) : 'Select Date',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: tempToDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      ).then((pickedDate) {
                        if (pickedDate != null) {
                          setState(() {
                            tempToDate = pickedDate;
                          });
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('To Date'),
                        ),
                        // SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            tempToDate != null ? DateFormat('dd-MM-yyyy').format(tempToDate!) : 'Select Date',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempStatus,
                    decoration: InputDecoration(labelText: 'Status'),
                    items: ['Pending', 'Approved', 'Rejected'].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                ],
              );
            },
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
                      _titleController.clear();
                      _fromDate = null;
                      _toDate = null;
                      selectedStatus = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Reset', style: TextStyle(fontSize: 15)),
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
                      _titleController.text = tempTitleController.text;
                      _fromDate = tempFromDate;
                      _toDate = tempToDate;
                      selectedStatus = tempStatus;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ],
        );
      },
    );
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
                // ListTile(
                //   title: Text('Date'),
                //   trailing: _sortField == 'date' ? Icon(Icons.check) : null,
                //   onTap: () {
                //     setState(() {
                //       _sortField = 'date';
                //       _isAscending = true; // Default to ascending for date
                //     });
                //     setModalState(() {});
                //     Navigator.pop(context);
                //   },
                // ),
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

  Future<void> deleteExpense(BuildContext context, String employeeId, String documentId) async {
    deleteController.showLoader.value = true;
    try {
      // Fetch the expense document to get the imageUrl
      final expenseDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(employeeId)
          .collection('expenses')
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
            .collection('Users')
            .doc(employeeId)
            .collection('expenses')
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

  Future<double> _getTotalAmount(String status) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userDoc.id)
        .collection('expenses')
        .where('status', isEqualTo: status)
        .get();

    double totalAmount = 0.0;
    for (var doc in querySnapshot.docs) {
      totalAmount += doc['amount'];
    }
    return totalAmount;
  }

  void _showEditDialog(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

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
            children: [
              Text(
                'Expense Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to left
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Title:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Text(
                      '${data['title']}'
                      // "Hello world how are you is every thing all right i cant find you "
                      ,
                      textAlign: TextAlign.end,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                            // '₹${data['amount'].toStringAsFixed(2)}'
                            data['amount'] % 1 == 0
                                ? '₹${data['amount'].toStringAsFixed(0)}'
                                : '₹${data['amount'].toStringAsFixed(2)}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FittedBox(fit: BoxFit.contain, child: Text('${formatDate(data['date'])}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Type:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FittedBox(fit: BoxFit.contain, child: Text('${data['transactionType']}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${data['time']}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${data['category']}'),
                  ],
                ),
                if (data['remark']?.isNotEmpty ?? false)
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
                            width: 10,
                          ),
                          Expanded(
                              child: Text(
                            '${data['remark']}'
                            // "Hello world how are you is every thing all right i cant find you "
                            ,
                            textAlign: TextAlign.end,
                          )),
                        ],
                      ),
                    ],
                  ),
                if (data['imageUrl']?.isNotEmpty ?? false)
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
                                              imageProvider: data['imageUrl'] != null || data['imageUrl'] != ""
                                                  ? NetworkImage(data['imageUrl']) as ImageProvider<Object>?
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
                                                  color: Colors.white,
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
                                data['imageUrl'],
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
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            // Delete button on the left (no icon)
            // widget.fromAdmin == true
            loadController.showDeleteButton == "Yes"
                ? TextButton(
                    onPressed: () {
                      // Delete expense from Firestore
                      Navigator.of(context).pop();
                      deleteExpense(context, widget.userDoc.id, document.id);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  )
                : SizedBox.shrink(),
            // Edit button on the right (no icon)
            // SizedBox(
            //   width: 80,
            // ),
            TextButton(
              onPressed: () {
                // Close the dialog before navigating
                Navigator.of(context).pop();

                // Navigate to AddExpense page for editing
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEmployeeExpense(userId: widget.userDoc.id, userDoc: widget.userDoc, DocumentData: document),
                  ),
                );
              },
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Users').doc(widget.userDoc.id).collection('expenses').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
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
              height: MediaQuery.of(context).size.height * 0.65,
              child: Center(
                  child: Text(
                'No expenses found.',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
              )));
        }

        // Filter expenses based on current filter criteria
        List<DocumentSnapshot> filteredExpenses = snapshot.data!.docs.where((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          // Check date range filter
          if (_fromDate != null && _toDate != null) {
            try {
              DateTime expenseDate = DateTime.parse(data['date']);
              if (expenseDate.isBefore(_fromDate!) || expenseDate.isAfter(_toDate!)) {
                return false;
              }
            } catch (e) {
              // Handle any parsing errors
              return false;
            }
          }

          // Check status filter
          if (selectedStatus != null &&
              selectedStatus!.isNotEmpty &&
              data.containsKey('status') &&
              data['status'] != selectedStatus) {
            return false;
          }

          return true; // Include in the filtered list
        }).toList();

        if (filteredExpenses.isEmpty) {
          return Center(child: Text('No expenses found for the current filters.'));
        }

        // Sorting logic
        filteredExpenses.sort((a, b) {
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
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filteredExpenses.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = filteredExpenses[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String expenseStatus = data.containsKey('status') ? data['status'] : 'Pending';

            // Format date here
            DateTime? date;

            // try {
            //   date = DateTime.parse(data['date']);
            // } catch (e) {
            //   // Handle the exception (e.g., print an error message)
            //   print("Error parsing date: ${e.toString()}");
            // }

            String formattedDate = '--';
            try {
              if (data.containsKey('date') && data['date'] != null) {
                date = DateTime.parse(data['date']);
                formattedDate = DateFormat('dd-MM-yyyy').format(date);
              }
            } catch (e) {
              // Handle the exception (e.g., print an error message)
              print("Error parsing date: ${e.toString()}");
            }

            // String formattedDate = date != null ? DateFormat('dd-MM').format(date) : 'Invalid Date';

            // Check for remark
            String? remark = data['remark'];
            bool hasRemark = remark != null && remark.isNotEmpty;

            // Check for image
            String? imageUrl = data['image'];
            bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

            return GestureDetector(
              onTap: () => _showEditDialog(document),
              child: Card(
                color: kwhite,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0.0),
                elevation: 3.0,
                child: ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                              ),
                            ),
                            if (hasRemark) ...[
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Icon(Icons.note, size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      remark,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
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
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                // '₹${data['amount']}',
                                (data['amount'] % 1 == 0)
                                    ? '₹${data['amount'].toStringAsFixed(0)}'
                                    : '₹${data['amount'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              data['transactionType'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                            if (hasImage) ...[
                              SizedBox(height: 8.0),
                              Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data['time'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(height: 8.0),
                            widget.fromAdmin == false
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: expenseStatus == 'Approved'
                                          ? Color(0xFFDBE6CF)
                                          : expenseStatus == 'Rejected'
                                              ? Color(0xFFF7D3C6)
                                              : Color(0xaaffffcd),
                                      // color: expenseStatus == 'Approved' ? Color(0xFFDBE6CF) : Color(0xFFF7D3C6),
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      border: Border.all(
                                          color: expenseStatus == 'Pending' ? Color(0xffffecb5) : Colors.transparent,
                                          width: 1),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        expenseStatus,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          color: expenseStatus == 'Approved'
                                              ? Color(0xFF6F9C40)
                                              : expenseStatus == 'Rejected'
                                                  ? Color(0xFFAE2F09)
                                                  : Color(0xff664d03),
                                        ),
                                      ),
                                    ),
                                  )
                                : expenseStatus == 'Pending'
                                    ? Column(
                                        children: [
                                          TextButton(
                                            onPressed: () => _updateExpenseStatus(document.id, 'Approved'),
                                            child: Row(
                                              children: [
                                                Icon(Icons.check, color: Colors.green, size: 15),
                                                SizedBox(width: 2.5),
                                                Text('Accept', style: TextStyle(color: Colors.green)),
                                              ],
                                            ),
                                            style: TextButton.styleFrom(
                                              side: BorderSide(color: Colors.green),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          TextButton(
                                            onPressed: () => _updateExpenseStatus(document.id, 'Rejected'),
                                            child: Row(
                                              children: [
                                                Icon(Icons.close, color: Colors.red, size: 15),
                                                SizedBox(width: 2.5),
                                                Text('Reject', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                            style: TextButton.styleFrom(
                                              side: BorderSide(color: Colors.red),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: expenseStatus == 'Approved' ? Color(0xFFDBE6CF) : Color(0xFFF7D3C6),
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            expenseStatus,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                              color: expenseStatus == 'Approved'
                                                  ? Color(0xFF6F9C40)
                                                  : expenseStatus == 'Rejected'
                                                      ? Color(0xFFAE2F09)
                                                      : null,
                                            ),
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
      },
    );
  }

  LoadAllFieldsController loadController = Get.put(LoadAllFieldsController());

  @override
  Widget build(BuildContext context) {
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _timeController.text = TimeOfDay.now().format(context);
    selectedCategory = _categories.isNotEmpty ? _categories[0] : null;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themecolor,
        title: const Text(
          'Expense',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: kwhite,
            ),
            onPressed: _showFilterDialog,
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
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: kwhite),
      ),
      body: Stack(
        children: [
          Container(
            height: 50,
            color: themecolor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          tileColor: kwhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Center(
                            child: Text(
                              'Approve',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          subtitle: FutureBuilder<double>(
                            future: _getTotalAmount('Approved'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                                ));
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }
                              double approvedTotal = snapshot.data ?? 0.0;
                              return Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    '₹${approvedTotal.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          tileColor: kwhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Center(
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          subtitle: FutureBuilder<double>(
                            future: _getTotalAmount('Rejected'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(themecolor),
                                ));
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }
                              double rejectedTotal = snapshot.data ?? 0.0;
                              return Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    '₹${rejectedTotal.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 16.0),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      child: Column(
                        children: [
                          _buildExpenseList(context),
                          // _buildExpenseList(context),
                          // _buildExpenseList(context),
                          SizedBox(
                            height: 75,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 40.0),
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
      ),
      floatingActionButton: widget.fromAdmin == true
          ? SizedBox()
          : FloatingActionButton(
              backgroundColor: themecolor,
              onPressed: () {
                _titleController.clear();
                _amountController.clear();
                _remarkController.clear();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEmployeeExpense(
                      userDoc: widget.userDoc,
                      userId: widget.userDoc.id,
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: kwhite,
              ),
            ),
    );
  }

  Future<void> _updateExpenseStatus(String expenseId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userDoc.id)
          .collection('expenses')
          .doc(expenseId)
          .update({'status': status});
    } catch (e) {
      print('Error updating expense status: $e');
    }
  }
}

/*Future<void> shareExpenseSummaryPDF(pw.Document pdf) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/expense_summary.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareFiles([file.path], mimeTypes: ['application/pdf']);
  }*/

/*  Future<void> shareExcelFile(List<int> excelFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ExpenseSummary.xlsx');
    await file.writeAsBytes(excelFile);

    // Share the file using a sharing plugin
    await Share.shareFiles([file.path], text: 'Expense Summary');
  }*/

/*
  Future<void> shareOrOpenExpenseSummaryPdf() async {

    final userDocData = widget.userDoc.data() as Map<String, dynamic>;

    final userEmail = userDocData['email'];
    final userName = _getUsernameFromEmail(userEmail);

    final expenses = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userDoc.id)
        .collection('expenses')
        .get()
        .then((snapshot) => snapshot.docs);

    final pdf = generateExpenseSummaryPDF(userName, userEmail, expenses);

    // final pdfBytes = await generateExpenseSummaryPDF(userName, userEmail, expenses);

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/ExpenseSummary.pdf';
    // final file = File(filePath);
    // await file.writeAsBytes(pdfBytes);

    // await shareExpenseSummaryPDF(pdf);

    controller.loadingDialog.value = false;
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
                Navigator.of(context).pop();
                await shareExpenseSummaryPDF(pdf);
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }
  */

/*
  Future<List<int>> generateExpenseSummaryExcel(
      String userName, String userEmail, List<DocumentSnapshot> expenses) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    final headingStyle = workbook.styles.add('headingStyle');
    headingStyle.fontSize = 18;
    headingStyle.bold = true;
    headingStyle.hAlign = xlsio.HAlignType.center;

    final boldStyle = workbook.styles.add('boldStyle');
    boldStyle.bold = true;
    boldStyle.hAlign = xlsio.HAlignType.center;

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

    sheet.getRangeByIndex(1, 1, 1, 6).merge();
    sheet.getRangeByIndex(2, 1, 2, 6).merge();
    sheet.getRangeByIndex(3, 1, 3, 6).merge();
    sheet.getRangeByIndex(4, 1, 4, 6).merge();

    const headers = ['Title', 'Amount', 'Type', 'Category', 'Date', 'Time', 'Image'];
    for (int col = 0; col < headers.length; col++) {
      sheet.getRangeByIndex(6, col + 1).setText(headers[col]);
      sheet.getRangeByIndex(6, col + 1).cellStyle = boldStyle;
      sheet.getRangeByIndex(6, col + 1).columnWidth = 20;
    }

    /*for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i].data() as Map<String, dynamic>;
      final rowIndex = 7 + i;

      sheet.getRangeByIndex(rowIndex, 1).setText(expense['title'] ?? '--');
      sheet.getRangeByIndex(rowIndex, 2).setText(expense['amount'] != null
          ? '${expense['amount'].toStringAsFixed(2)}'
          : '--');
      sheet.getRangeByIndex(rowIndex, 3).setText(expense['transactionType'] ?? '--');
      sheet.getRangeByIndex(rowIndex, 4).setText(expense['category'] ?? '--');
      sheet.getRangeByIndex(rowIndex, 5).setText(expense['date'] ?? '--');
      sheet.getRangeByIndex(rowIndex, 6).setText(expense['time'] ?? '--');

      if (expense.containsKey('imageUrl') && expense['imageUrl'] != '') {
        final imageUrl = expense['imageUrl'];
        final imageBytes = await fetchImageBytes(imageUrl);
        if (imageBytes != null) {
          sheet.pictures.addStream(rowIndex, 7, imageBytes);
          sheet.getRangeByIndex(rowIndex, 7).rowHeight = 100;
          sheet.getRangeByIndex(rowIndex, 7).columnWidth = 25;
        } else {
          sheet.getRangeByIndex(rowIndex, 7).setText('Failed to load image');
        }
      } else {
        sheet.getRangeByIndex(rowIndex, 7).setText('No image');
      }
    }*/

    for (int i = 0; i < expenses.length; i++) {
      try {
        final expense = expenses[i].data() as Map<String, dynamic>;
        final rowIndex = 7 + i;

        // Safely extract fields
        final title = expense['title']?.toString() ?? '--';
        final amount = expense['amount'] != null ? '${expense['amount']}' : '--';
        final transactionType = expense['transactionType']?.toString() ?? '--';
        final category = expense['category']?.toString() ?? '--';
        final date = expense['date']?.toString() ?? '--';
        final time = expense['time']?.toString() ?? '--';
        final imageUrl = expense['imageUrl']?.toString() ?? '';

        // Populate text data
        sheet.getRangeByIndex(rowIndex, 1).setText(title);
        sheet.getRangeByIndex(rowIndex, 2).setText(amount);
        sheet.getRangeByIndex(rowIndex, 3).setText(transactionType);
        sheet.getRangeByIndex(rowIndex, 4).setText(category);
        sheet.getRangeByIndex(rowIndex, 5).setText(date);
        sheet.getRangeByIndex(rowIndex, 6).setText(time);

        // Handle image
        if (imageUrl.isNotEmpty) {
          final imageBytes = await fetchImageBytes(imageUrl);

          if (imageBytes != null) {
            // Decode and resize the image to fit the cell
            final originalImage = img.decodeImage(imageBytes);
            final resizedImage = img.copyResize(originalImage!, width: 80, height: 80); // Adjust dimensions

            // Add image to Excel
            sheet.pictures.addStream(rowIndex, 7, img.encodePng(resizedImage));

            // Set cell size to fit the resized image
            sheet.getRangeByIndex(rowIndex, 7).rowHeight = 60; // Adjust based on image height
            sheet.getRangeByIndex(rowIndex, 7).columnWidth = 10; // Adjust based on image width
          } else {
            sheet.getRangeByIndex(rowIndex, 7).setText('Invalid image');
          }
        } else {
          sheet.getRangeByIndex(rowIndex, 7).setText('No image');
        }

        // Align cells
        for (int j = 1; j <= 6; j++) {
          sheet.getRangeByIndex(rowIndex, j).cellStyle.hAlign = xlsio.HAlignType.center;
        }
      } catch (e) {
        print('Error processing row $i: $e');
        final rowIndex = 7 + i;
        sheet.getRangeByIndex(rowIndex, 1).setText('Error processing row');
        sheet.getRangeByIndex(rowIndex, 7).setText('--');
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    return bytes;
  }
  */

/*
  Future<List<int>> generateExpenseSummaryExcel(String userName, String userEmail, List<DocumentSnapshot> expenses) async {
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

    // Populate expense data
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i].data() as Map<String, dynamic>;
      final rowIndex = 7 + i;

      /*sheet.getRangeByIndex(rowIndex, 1).setText(expense['title'] ?? '--');
      sheet.getRangeByIndex(rowIndex, 2).setText(expense['amount'] != null ? '${expense['amount'].toStringAsFixed(2)}' : '--');
      sheet.getRangeByIndex(rowIndex, 3).setText(expense['transactionType'] ?? '--');
      sheet.getRangeByIndex(rowIndex, 4).setText(expense['category'] ?? '--');
      sheet.getRangeByIndex(rowIndex, 5).setText(expense.containsKey('date') && expense['date'] != '--' ? expense['date'] : '--');
      sheet.getRangeByIndex(rowIndex, 6).setText(expense.containsKey('time') && expense['time'] != '' ? expense['time'] : '--');
      // sheet.getRangeByIndex(rowIndex, 7).setText(expense.containsKey('imageUrl') && expense['imageUrl'] != '' ? expense['imageUrl'] : '--');

      if (expense.containsKey('imageUrl') && expense['imageUrl'] != '') {
        final imageUrl = expense['imageUrl'];
        final linkFormula = 'HYPERLINK("$imageUrl", "Click to view image")';
        sheet.getRangeByIndex(rowIndex, 7).setFormula(linkFormula);
      } else {
        sheet.getRangeByIndex(rowIndex, 7).setText('No image');
      }*/

      sheet.getRangeByIndex(rowIndex, 1).setText(expense['title']?.isNotEmpty == true ? expense['title'] : '--');
      sheet.getRangeByIndex(rowIndex, 2).setText(expense['amount'] != null && expense['amount'].toString().isNotEmpty
          ? '${expense['amount'].toStringAsFixed(2)}'
          : '--');
      sheet.getRangeByIndex(rowIndex, 3).setText(expense['transactionType']?.isNotEmpty == true ? expense['transactionType'] : '--');
      sheet.getRangeByIndex(rowIndex, 4).setText(expense['category']?.isNotEmpty == true ? expense['category'] : '--');
      sheet.getRangeByIndex(rowIndex, 5).setText(expense['date']?.isNotEmpty == true ? expense['date'] : '--');
      sheet.getRangeByIndex(rowIndex, 6).setText(expense['time']?.isNotEmpty == true ? expense['time'] : '--');
      // sheet.getRangeByIndex(rowIndex, 7).setText(expense['imageUrl']?.isNotEmpty == true ? expense['imageUrl'] : '--');

      if (expense.containsKey('imageUrl') && expense['imageUrl']?.isNotEmpty == true) {
        final imageUrl = expense['imageUrl'];
        final linkFormula = 'HYPERLINK("$imageUrl", "Click to view image")';
        sheet.getRangeByIndex(rowIndex, 7).setFormula(linkFormula);

        final imageUrlStyle = workbook.styles.add('imageUrlStyle_$rowIndex');
        imageUrlStyle.fontColor = '#0000FF';
        imageUrlStyle.underline = true;
        sheet.getRangeByIndex(rowIndex, 7).cellStyle = imageUrlStyle;
      } else {
        sheet.getRangeByIndex(rowIndex, 7).setText('No image');
      }

      for (int j = 1; j <= 6; j++) {
        sheet.getRangeByIndex(rowIndex, j).cellStyle.hAlign = xlsio.HAlignType.center;
      }
    }

    // Save the Excel file to bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    return bytes;
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

      if (expense.containsKey('imageUrl') && (expense['imageUrl'] != '' || expense['imageUrl'] != null)) {
        final imageBytesFuture = fetchImageBytes(expense['imageUrl']);
        imageBytesFuture.then((imageBytes) {
          if (imageBytes != null) {
            final rowIndex = 7 + i;
            final columnIndex = 7; // Image column
            sheet.pictures.addStream(rowIndex, columnIndex, imageBytes);
            sheet.getRangeByIndex(rowIndex, columnIndex).rowHeight = 100;
          }
        });
      }

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

/*final imageUrl = expense['imageUrl'];
  if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
    try {
      final imageBytes = await fetchImageBytes(imageUrl);
      if (imageBytes != null) {
        sheet.pictures.addStream(rowIndex, 7, imageBytes);
        sheet.getRangeByIndex(rowIndex, 7).rowHeight = 5;
      } else {
        print('No valid image data for row $rowIndex');
      }
    } catch (e) {
      print('Error fetching image for row $rowIndex: $e');
    }
  } else {
    print('No valid imageUrl for row $rowIndex');
  }

  Center-align data rows*/
