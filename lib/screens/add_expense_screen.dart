import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "Food";
  bool isIncome = false;
  bool showDescription = false;

  void _addExpense() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    double amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) return;

    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add({
      'title': titleController.text,
      'amount': amount,
      'category': selectedCategory,
      'description': showDescription ? descriptionController.text : null,
      'type': isIncome ? 'income' : 'expense',
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isIncome ? 'Add Income' : 'Add Expense')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(isIncome ? "Income" : "Expense"),
              value: isIncome,
              onChanged: (value) => setState(() => isIncome = value),
            ),
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: amountController, decoration: InputDecoration(labelText: 'Amount (₹)'), keyboardType: TextInputType.number),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  showDescription = newValue == "Other";
                });
              },
              items: ["Food", "Shopping", "Salary", "Other"].map((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
            ),
            if (showDescription) TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addExpense, child: Text(isIncome ? 'Add Income' : 'Add Expense')),
          ],
        ),
      ),
    );
  }
}
