import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  final Function(String, double, Color, bool, String) onExpenseAdded;

  AddExpenseScreen({required this.onExpenseAdded});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = "Food";
  bool showDescription = false;
  bool isIncome = false; // ✅ Toggle for Income/Expense

  void addExpense() {
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    double amount = double.tryParse(amountController.text) ?? 0.0;
    Color color = isIncome ? Colors.green : Colors.red;
    String title = showDescription ? descriptionController.text : titleController.text;

    widget.onExpenseAdded(title, amount, color, isIncome, selectedCategory);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isIncome ? 'Add Income' : 'Add Expense')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Expense/Income
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Expense"),
                Switch(
                  value: isIncome,
                  onChanged: (value) {
                    setState(() {
                      isIncome = value;
                    });
                  },
                ),
                Text("Income"),
              ],
            ),

            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: isIncome ? 'Income Title' : 'Expense Title'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount (₹)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  showDescription = newValue == "Other"; // ✅ Show text field only if "Other" is selected
                });
              },
              items: ["Food", "Shopping", "Salary", "Other"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (showDescription)
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addExpense,
              child: Text(isIncome ? 'Add Income' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
