import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ExpenseListEmpOld extends StatefulWidget {
  final DocumentSnapshot userDoc;

  const ExpenseListEmpOld({Key? key, required this.userDoc}) : super(key: key);

  @override
  _ExpenseListEmpOldState createState() => _ExpenseListEmpOldState();
}

class _ExpenseListEmpOldState extends State<ExpenseListEmpOld> {
  late DateTime _selectedDate;
  String? selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _titleController = TextEditingController();
  // String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fromDate = null;
    _toDate = null;
    selectedStatus = null; // Initialize selectedStatus to null
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempFromDate = _fromDate;
        DateTime? tempToDate = _toDate;
        TextEditingController tempTitleController = TextEditingController(text: _titleController.text);
        String? tempStatus = selectedStatus; // Use selectedStatus instead of _selectedStatus

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
                  Text(tempFromDate != null ? DateFormat('dd-MM-yyyy').format(tempFromDate!) : 'No Date'),
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
                  Text(tempToDate != null ? DateFormat('dd-MM-yyyy').format(tempToDate!) : 'No Date'),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tempStatus, // Use tempStatus instead of selectedStatus
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Pending', 'Approved', 'Rejected'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tempStatus = value; // Update tempStatus when the dropdown changes
                  });
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _titleController.text = tempTitleController.text;
                  _fromDate = tempFromDate;
                  _toDate = tempToDate;
                  selectedStatus = tempStatus; // Use tempStatus instead of _selectedStatus
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
                  .collection('Users')
                  .doc(widget.userDoc.id)
                  .collection('expenses')
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

                  bool matchesStatus =
                      selectedStatus == null || expense['status'] == selectedStatus; // Use selectedStatus

                  return matchesFromDate && matchesToDate && matchesStatus;
                }).toList();

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
                                Text(expenseData['title'] ?? ''),
                                Text(formattedExpenseDate),
                                Text(expenseData['category'] ?? ''),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(' ₹${expenseData['amount']}'),
                                Text('${expenseData['transactionType']}'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${expenseData['time']}'),
                                Container(
                                  decoration: BoxDecoration(
                                    color: expenseData['status'] == 'Approved' ? Color(0xFFDBE6CF) : Color(0xFFF7D3C6),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text(
                                    expenseData['status'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: expenseData['status'] == 'Approved'
                                          ? FontWeight.bold
                                          : expenseData['status'] == 'Rejected'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color: expenseData['status'] == 'Approved'
                                          ? Color(0xFF6F9C40)
                                          : expenseData['status'] == 'Rejected'
                                              ? Color(0xFFAE2F09)
                                              : null,
                                    ),
                                  ),
                                )
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
