import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewAllExpensesPage extends StatefulWidget {
  final DocumentSnapshot userDoc;

  const ViewAllExpensesPage({Key? key, required this.userDoc}) : super(key: key);

  @override
  _ViewAllExpensesPageState createState() => _ViewAllExpensesPageState();
}

class _ViewAllExpensesPageState extends State<ViewAllExpensesPage> {
  late DateTime _selectedDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fromDate = null;
    _toDate = null;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempFromDate = _fromDate;
        DateTime? tempToDate = _toDate;
        TextEditingController tempTitleController = TextEditingController(text: _titleController.text);

        return AlertDialog(
          title: Text('Filter Expenses'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tempTitleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
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
                    child: Text('From Date'),
                  ),
                  SizedBox(width: 16),
                  Text(tempFromDate != null ? DateFormat('dd-MM').format(tempFromDate!) : 'No Date'),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
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
                    child: Text('To Date'),
                  ),
                  SizedBox(width: 16),
                  Text(tempToDate != null ? DateFormat('dd-MM').format(tempToDate!) : 'No Date'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _titleController.text = tempTitleController.text;
                  _fromDate = tempFromDate;
                  _toDate = tempToDate;
                });
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Expenses',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Show date picker dialog
                  //     showDatePicker(
                  //       context: context,
                  //       initialDate: _selectedDate,
                  //       firstDate: DateTime(2000),
                  //       lastDate: DateTime.now(),
                  //     ).then((pickedDate) {
                  //       if (pickedDate != null) {
                  //         setState(() {
                  //           _selectedDate = pickedDate;
                  //         });
                  //       }
                  //     });
                  //   },
                  //   child: Text('Select Date'),
                  // ),
                  SizedBox(width: 16),
                  Visibility(
                    visible: false, // Hide this section
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Reset to show all expenses
                        });
                      },
                      child: Text('All'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Visibility(
                    visible: false, // Hide this section
                    child: Text(
                      'Selected Date:\n $formattedDate',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Admin')
                  .doc(widget.userDoc.id)
                  .collection('expense')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ));
                }

                final List<DocumentSnapshot> expenses = snapshot.data!.docs;

                print('Number of Expenses: ${expenses.length}'); // Debugging print statement

                // Filter expenses based on selection
                List<DocumentSnapshot> filteredExpenses = expenses.where((expense) {
                  dynamic dateValue = expense['date'];
                  DateTime expenseDate;

                  if (dateValue is Timestamp) {
                    expenseDate = dateValue.toDate();
                  } else if (dateValue is String) {
                    expenseDate = DateTime.parse(dateValue);
                  } else {
                    expenseDate = DateTime.now();
                  }

                  bool matchesFromDate =
                      _fromDate == null || expenseDate.isAfter(_fromDate!.subtract(Duration(days: 1)));
                  bool matchesToDate = _toDate == null || expenseDate.isBefore(_toDate!.add(Duration(days: 1)));

                  bool matchesTitle = _titleController.text.isEmpty ||
                      expense['title'].toString().toLowerCase().contains(_titleController.text.toLowerCase());

                  return matchesFromDate && matchesToDate && matchesTitle;
                }).toList();

                // Handle the case where there are no expenses
                if (filteredExpenses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No expenses found.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expenseData = filteredExpenses[index].data() as Map<String, dynamic>;
                    DateTime expenseDate;

                    dynamic dateValue = expenseData['date'];
                    if (dateValue is Timestamp) {
                      expenseDate = dateValue.toDate();
                    } else if (dateValue is String) {
                      expenseDate = DateTime.parse(dateValue);
                    } else {
                      expenseDate = DateTime.now();
                    }

                    String formattedExpenseDate = DateFormat('dd-MM').format(expenseDate);

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(expenseData['title']),
                                Text(formattedExpenseDate), // Display formatted date
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${expenseData['time']}'),
                                Text('${expenseData['category']}'),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${expenseData['amount']}'),
                                Container(
                                  decoration: BoxDecoration(
                                    color: expenseData['transactionType'] == 'credit'
                                        ? Color(0xFFDBE6CF)
                                        : Color(0xFFF7D3C6),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  child: Text(
                                    '${expenseData['transactionType']}',
                                    style: TextStyle(
                                      color: expenseData['transactionType'] == 'credit'
                                          ? Color(0xFF6F9C40)
                                          : Color(0xFFAE2F09),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
