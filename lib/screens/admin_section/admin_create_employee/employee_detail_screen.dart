import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etmm/const/const.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final DocumentSnapshot userDoc;
  const EmployeeDetailsScreen({Key? key, required this.userDoc}) : super(key: key);

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  bool showAll = false;

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

  void _showRemarkDialog(BuildContext context, String remark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remark'),
          content: Text(remark),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void toggleFilter() {
    setState(() {
      showAll = !showAll;
    });
  }

  @override
  Widget build(BuildContext context) {
    String username = widget.userDoc['username'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themecolor,
        title: Text(
          'Expenses of $username',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kwhite),
        ),
        iconTheme: IconThemeData(color: kwhite),
        actions: [
          IconButton(
            tooltip: showAll ? "Show Pending Only" : "Show All",
            onPressed: toggleFilter,
            // icon: Icon(showAll ? Icons.playlist_add_check : Icons.playlist_remove),
            icon: showAll
                ? FaIcon(Icons.playlist_add_check, size: 30)
                : FaIcon(
                    FontAwesomeIcons.hourglassHalf,
                    size: 20,
                  ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userDoc.id)
            .collection('expenses')
            .where('status', isEqualTo: showAll ? null : 'Pending')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themecolor),
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              'No expenses found.',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
            ));
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          final filteredDocuments =
              showAll ? documents : documents.where((doc) => (doc['status'] as String?) == 'Pending').toList();

          filteredDocuments.sort((a, b) {
            final statusA = a['status'] as String?;
            final statusB = b['status'] as String?;
            if (statusA == 'Pending' && statusB != 'Pending') {
              return -1;
            } else if (statusA != 'Pending' && statusB == 'Pending') {
              return 1;
            } else {
              return 0;
            }
          });

          // Calculate total credit and debit amounts
          double totalCredit = 0.0;
          double totalDebit = 0.0;
          // documents.forEach((doc) {
          //   double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
          //   String transactionType = doc['transactionType'].toString().toLowerCase();
          //   if (transactionType == 'credit') {
          //     totalCredit += amount;
          //   } else if (transactionType == 'debit') {
          //     totalDebit += amount;
          //   }
          // });

          filteredDocuments.forEach((doc) {
            double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
            String transactionType = doc['transactionType'].toString().toLowerCase();
            if (transactionType == 'credit') {
              totalCredit += amount;
            } else if (transactionType == 'debit') {
              totalDebit += amount;
            }
          });

          // Calculate final amount (total credit - total debit)
          double finalAmount = totalCredit - totalDebit;

          return Column(
            children: [
              Stack(children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  color: themecolor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: Card(
                    color: kwhite,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
                    ),
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), // Match the Card's shape
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            spreadRadius: 0.2,
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  "Total Amount",
                                  // ignore: deprecated_member_use
                                  textScaleFactor: 1.4,
                                  style: TextStyle(
                                    color: themecolor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              // height: double.infinity,
                              // width: 150,
                              padding: EdgeInsets.symmetric(horizontal: 5),
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
                                    // (finalAmount >= 0.0)
                                    //     ? '₹${finalAmount.toStringAsFixed(2)}'
                                    //     : '₹${finalAmount.abs().toString()} Dr',
                                    finalAmount >= 0.0
                                        ? (finalAmount % 1 == 0
                                            ? '₹${finalAmount.toStringAsFixed(0)}'
                                            : '₹${finalAmount.toStringAsFixed(2)}')
                                        : '₹${finalAmount.abs() % 1 == 0 ? finalAmount.abs().toStringAsFixed(0) : finalAmount.abs().toStringAsFixed(2)} Dr',
                                    // ignore: deprecated_member_use
                                    textScaleFactor: 1.4,
                                    style: TextStyle(
                                      color: finalAmount >= 0.0 ? Colors.white : Colors.white,
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
              ]),
              Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  padding: EdgeInsets.only(bottom: 50),
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = documents[index];
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    String expenseStatus = data.containsKey('status') ? data['status'] : 'Pending';
                    String remark = data.containsKey('remark') ? data['remark'] : '';
                    return GestureDetector(
                      onTap: () {},
                      child: Card(
                        color: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        child: ListTile(
                          tileColor: kwhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        data['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        '${data['date'] == '' ? "--" : DateFormat('dd-MM-yyyy').format(DateTime.parse(data['date']))}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                // flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${data['time']}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '${data['category']}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                // flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        // '₹${data['amount']}',
                                        '₹${double.tryParse(data['amount'].toString())?.toStringAsFixed(double.tryParse(data['amount'].toString())!.truncateToDouble() == double.tryParse(data['amount'].toString()) ? 0 : 2) ?? '0'}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: data['transactionType'] == 'Credit'
                                            ? const Color(0xFFDBE6CF)
                                            : const Color(0xFFF7D3C6),
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      child: Text(
                                        data['transactionType'] == 'Credit' ? 'Cr' : 'Dr',
                                        style: TextStyle(
                                          color: data['transactionType'] == 'Credit'
                                              ? const Color(0xFF6F9C40)
                                              : const Color(0xFFAE2F09),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (remark.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  height: 15,
                                  width: 15,
                                  child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(Icons.comment, size: 20),
                                    color: Colors.grey,
                                    onPressed: () => _showRemarkDialog(context, remark),
                                  ),
                                ),
                              Spacer(),
                              if (expenseStatus == 'Pending') ...[
                                TextButton(
                                  onPressed: () => _updateExpenseStatus(document.id, 'Approved'),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.green),
                                      SizedBox(width: 5),
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
                                      Icon(Icons.close, color: Colors.red),
                                      SizedBox(width: 5),
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
                              ] else ...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: expenseStatus == 'Approved' ? Colors.green.shade400 : Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    expenseStatus == 'Approved' ? 'Accepted' : 'Rejected',
                                    style: TextStyle(
                                      // color: expenseStatus == 'Approved' ? Colors.green : Colors.red,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      /*appBar: AppBar(
        backgroundColor: themecolor,
        title: Text(
          'Expenses of $username',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kwhite),
        ),
        iconTheme: IconThemeData(color: kwhite),
        actions: [
          IconButton(
            tooltip: showAll ? "Show Pending Only" : "Show All",
            onPressed: toggleFilter,
            icon: Icon(showAll ? Icons.playlist_add_check : Icons.playlist_remove),
          ),
        ],
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('Users').doc(widget.userDoc.id).collection('expenses').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          final pendingDocuments = documents.where((doc) => doc['status'] == 'Pending').toList();
          final approvedDocuments = documents.where((doc) => doc['status'] == 'Approved').toList();

          // Calculate total credit and debit amounts
          double totalCredit = 0.0;
          double totalDebit = 0.0;

          // Calculate the totals from all documents
          documents.forEach((doc) {
            double amount = double.tryParse(doc['amount'].toString()) ?? 0.0;
            String transactionType = doc['transactionType'].toString().toLowerCase();
            if (transactionType == 'credit') {
              totalCredit += amount;
            } else if (transactionType == 'debit') {
              totalDebit += amount;
            }
          });

          // Calculate final amount (total credit - total debit)
          double finalAmount = totalCredit - totalDebit;

          return Column(
            children: [
              // Display total amount
              Stack(
                children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    color: themecolor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: Card(
                      color: kwhite,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              spreadRadius: 0.2,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "Total Amount",
                                    textScaleFactor: 1.4,
                                    style: TextStyle(
                                      color: themecolor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
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
                                      finalAmount >= 0.0
                                          ? (finalAmount % 1 == 0
                                              ? '₹${finalAmount.toStringAsFixed(0)}'
                                              : '₹${finalAmount.toStringAsFixed(2)}')
                                          : '₹${finalAmount.abs() % 1 == 0 ? finalAmount.abs().toStringAsFixed(0) : finalAmount.abs().toStringAsFixed(2)} Dr',
                                      textScaleFactor: 1.4,
                                      style: TextStyle(
                                        color: Colors.white,
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
              // Display pending and approved expenses
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: 50),
                  children: [
                    if (pendingDocuments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No pending expense found.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    else
                      ...pendingDocuments.map((document) {
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        return buildExpenseTile(context, document, data);
                      }).toList(),
                    if (approvedDocuments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No approved expense found.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    else
                      ...approvedDocuments.map((document) {
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        return buildExpenseTile(context, document, data);
                      }).toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),*/
    );
  }

  /*Widget buildExpenseTile(BuildContext context, DocumentSnapshot document, Map<String, dynamic> data) {
    String expenseStatus = data.containsKey('status') ? data['status'] : 'Pending';
    String remark = data.containsKey('remark') ? data['remark'] : '';

    return GestureDetector(
      onTap: () {},
      child: Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        child: ListTile(
          tileColor: kwhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        data['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${data['date'] == '' ? "--" : DateFormat('dd-MM-yyyy').format(DateTime.parse(data['date']))} dd',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${data['time']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${data['category']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
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
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: data['transactionType'] == 'credit' ? const Color(0xFFDBE6CF) : const Color(0xFFF7D3C6),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Text(
                        data['transactionType'] == 'credit' ? 'Cr' : 'Dr',
                        style: TextStyle(
                          color:
                              data['transactionType'] == 'credit' ? const Color(0xFF6F9C40) : const Color(0xFFAE2F09),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (remark.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 5),
                  height: 15,
                  width: 15,
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.comment, size: 20),
                    color: Colors.grey,
                    onPressed: () => _showRemarkDialog(context, remark),
                  ),
                ),
              Spacer(),
              if (expenseStatus == 'Pending') ...[
                TextButton(
                  onPressed: () => _updateExpenseStatus(document.id, 'Approved'),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 5),
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
                      Icon(Icons.close, color: Colors.red),
                      SizedBox(width: 5),
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
              ] else ...[
                Text(
                  expenseStatus == 'Approved' ? 'Accepted' : 'Rejected',
                  style: TextStyle(
                    color: expenseStatus == 'Approved' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }*/
}
