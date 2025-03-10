import 'package:flutter/material.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> expenses = [];
  double totalBalance = 50000;

  void addExpense(String title, double amount, Color color, bool isIncome, String category) {
    setState(() {
      expenses.insert(0, {
        "title": title,
        "amount": isIncome ? "+₹$amount" : "-₹$amount",
        "color": isIncome ? Colors.green : Colors.red,
        "isIncome": isIncome,
        "category": category,
      });

      totalBalance += isIncome ? amount : -amount;
    });
  }

  void deleteExpense(int index) {
    setState(() {
      double amount = double.parse(expenses[index]["amount"].replaceAll(RegExp(r'[^0-9.-]'), ''));
      bool isIncome = expenses[index]["isIncome"];

      totalBalance -= isIncome ? amount : -amount;
      expenses.removeAt(index);
    });
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
              // Navigate to Settings
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Balance",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("₹${totalBalance.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: totalBalance >= 0 ? Colors.green : Colors.red)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.add, "Add Expense", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenseScreen(onExpenseAdded: addExpense),
                    ),
                  );
                }),
                _buildActionButton(Icons.pie_chart, "Reports", () {
                  // Navigate to Reports
                }),
                _buildActionButton(Icons.notifications, "Reminders", () {
                  // Navigate to Notifications
                }),
              ],
            ),
            SizedBox(height: 20),

            // Recent Transactions
            Text("Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: expenses.isEmpty
                  ? Center(child: Text("No expenses yet!"))
                  : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(expenses[index]["title"]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      deleteExpense(index);
                    },
                    child: _buildTransactionItem(
                      expenses[index]["title"],
                      expenses[index]["amount"],
                      expenses[index]["color"],
                      expenses[index]["category"],
                    ),
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
          child: IconButton(
            icon: Icon(icon, size: 30, color: Colors.blue),
            onPressed: onTap,
          ),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 14))
      ],
    );
  }

  Widget _buildTransactionItem(String title, String amount, Color color, String category) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: color),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(category),
        trailing: Text(amount, style: TextStyle(fontSize: 16, color: color)),
      ),
    );
  }
}
