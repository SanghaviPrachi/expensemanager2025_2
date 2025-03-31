import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
              color: chartColors[index % chartColors.length],
              value: entry.value,
              title: entry.key,
              radius: 80,
              titleStyle: TextStyle(
                fontSize: entry.value < 500 ? 10 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _generateAndSharePdf() async {
    try {
      final pdf = pw.Document();

      // Load font correctly
      final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Expense Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf),
                ),
                pw.SizedBox(height: 20),
                ...categoryData.entries.map(
                      (entry) => pw.Text(
                    "${entry.key}: ₹${entry.value.toStringAsFixed(2)}",
                    style: pw.TextStyle(font: ttf),
                  ),
                ),
              ],
            );
          },
        ),
      );

      Uint8List bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/report.pdf');
      await file.writeAsBytes(bytes);

      Share.shareXFiles([XFile(file.path)], text: "Here is your expense report!");
    } catch (e) {
      print("Error generating PDF: $e");
    }
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
            _buildPieChart(),
            SizedBox(height: 20),
            Text("Category-wise Spending", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: categoryData.length,
                itemBuilder: (context, index) {
                  String category = categoryData.keys.elementAt(index);
                  double amount = categoryData[category]!;
                  return ListTile(
                    leading: Icon(Icons.circle, color: chartColors[index % chartColors.length]),
                    title: Text(category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    trailing: Text("₹${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _generateAndSharePdf,
              child: Text("Generate & Share PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
