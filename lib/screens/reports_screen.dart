import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedFilter = "This Year";
  List<Map<String, dynamic>> expenses = [];
  Map<String, double> categoryData = {};

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    Map<String, double> categoryMap = {};
    List<Map<String, dynamic>> expenseList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      expenseList.add(data);

      if (categoryMap.containsKey(data['category'])) {
        categoryMap[data['category']] =
            categoryMap[data['category']]! + (data['amount'] as double);
      } else {
        categoryMap[data['category']] = (data['amount'] as double);
      }
    }

    setState(() {
      expenses = expenseList;
      categoryData = categoryMap;
    });
  }

  Widget _buildPieChart() {
    if (categoryData.isEmpty) {
      return Center(child: Text("No data available"));
    }

    List<Color> chartColors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
      Colors.cyan.shade400,
      Colors.amber.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
    ];

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: categoryData.entries.map((entry) {
            int index = categoryData.keys.toList().indexOf(entry.key);
            return PieChartSectionData(
              color: chartColors[index % chartColors.length], // Matching colors
              value: entry.value,
              title: entry.key, // Removed amount
              radius: 80,
              titleStyle: TextStyle(
                fontSize: entry.value < 500 ? 10 : 14, // Adjust font size dynamically
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Color> chartColors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
      Colors.cyan.shade400,
      Colors.amber.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Reports")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Dropdown
            DropdownButton<String>(
              value: selectedFilter,
              items: [
                "Today",
                "This Month",
                "Last 3 Months",
                "Last 6 Months",
                "This Year",
              ].map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedFilter = newValue!;
                  _fetchExpenses();
                });
              },
            ),
            SizedBox(height: 20),

            // Pie Chart
            _buildPieChart(),

            SizedBox(height: 20),
            Text("Category-wise Spending", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Expense List with colors matching the chart
            Expanded(
              child: ListView.builder(
                itemCount: categoryData.length,
                itemBuilder: (context, index) {
                  String category = categoryData.keys.elementAt(index);
                  double amount = categoryData[category]!;
                  return ListTile(
                    leading: Icon(Icons.circle, color: chartColors[index % chartColors.length]), // Colors match
                    title: Text(category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    trailing: Text("₹${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
