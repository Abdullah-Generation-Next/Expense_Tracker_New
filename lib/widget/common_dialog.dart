import 'package:etmm/const/const.dart';
import 'package:flutter/material.dart';

class CommonFilterDialog extends StatefulWidget {
  final String initialTitle;
  final String initialMonth;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onMonthChanged;

  CommonFilterDialog({
    required this.initialTitle,
    required this.initialMonth,
    required this.onTitleChanged,
    required this.onMonthChanged,
  });

  @override
  _CommonFilterDialogState createState() => _CommonFilterDialogState();
}

class _CommonFilterDialogState extends State<CommonFilterDialog> {
  late TextEditingController titleController;
  late String selectedMonth;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    selectedMonth = widget.initialMonth;
  }

  List<String> months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filter Expenses'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TextFormField(
          //   controller: titleController,
          //   decoration: const InputDecoration(
          //     labelText: 'Title',
          //   ),
          //   onChanged: (value) {
          //     widget.onTitleChanged(value);
          //   },
          // ),
          SizedBox(height: 16), // Add some space between the fields
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Month',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,
                isExpanded: true,
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue!;
                  });
                  // widget.onMonthChanged(newValue!);
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                // ignore: deprecated_member_use
                backgroundColor: MaterialStatePropertyAll(themecolor),
                // ignore: deprecated_member_use
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              onPressed: () {
                setState(() {
                  titleController.text = '';
                  selectedMonth = 'All';
                });
                widget.onTitleChanged('');
                widget.onMonthChanged('All');
                Navigator.of(context).pop();
              },
              child: const Text(
                'Reset',
                style: TextStyle(fontSize: 15),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                // ignore: deprecated_member_use
                backgroundColor: MaterialStatePropertyAll(themecolor),
                // ignore: deprecated_member_use
                foregroundColor: MaterialStatePropertyAll(Colors.white),
              ),
              onPressed: () {
                widget.onTitleChanged(titleController.text);
                widget.onMonthChanged(selectedMonth);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
