import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_expense_screen.dart';
import 'reports_screen.dart';
import 'split_expense_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalBalance = 0.0;
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .listen((snapshot) {
      double balance = 0.0;
      List<Map<String, dynamic>> expenseList = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        expenseList.add(data);

        if (data['type'] == 'income') {
          balance += data['amount'];
        } else {
          balance -= data['amount'];
        }
      }

      setState(() {
        totalBalance = balance;
        expenses = expenseList;
      });
    });
  }

  void _deleteExpense(String expenseId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spendsight'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsScreen()));
            },
          ),

        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Total Balance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "₹${totalBalance.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.add, "Add Expense", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddExpenseScreen()));
                }),
                _buildActionButton(Icons.pie_chart, "Reports", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReportsScreen()));
                }),
                _buildActionButton(Icons.group, "Split Expense", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SplitExpenseScreen()));
                }),
              ],
            ),
            SizedBox(height: 20),
            Text("Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var expense = expenses[index];
                  return Dismissible(
                    key: Key(expense['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteExpense(expense['id']);
                    },
                    child: _buildTransactionItem(
                        expense['title'],
                        "₹${expense['amount'].toString()}",
                        expense['type'] == 'income' ? Colors.green : Colors.red,
                        expense['id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          child: IconButton(icon: Icon(icon, size: 30, color: Colors.blue), onPressed: onTap),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 14))
      ],
    );
  }

  Widget _buildTransactionItem(String title, String amount, Color color, String expenseId) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: color),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Text(amount, style: TextStyle(fontSize: 16, color: color)),
      ),
    );
  }
}
