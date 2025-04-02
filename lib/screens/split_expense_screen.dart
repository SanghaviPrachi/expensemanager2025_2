import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplitExpenseScreen extends StatefulWidget {
  @override
  _SplitExpenseScreenState createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        groups = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });
  }

  void _addGroup() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (_groupNameController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('groups').add({
        'name': _groupNameController.text,
        'members': [userId],
        'expenses': []
      });
      _groupNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Split Expenses')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addGroup,
                  child: Text('Add Group'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                var group = groups[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: ListTile(
                    title: Center(
                        child: Text(group['name'], style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailScreen(groupId: group['id'], groupName: group['name']),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupDetailScreen({required this.groupId, required this.groupName});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final TextEditingController _memberEmailController = TextEditingController();
  final TextEditingController _expenseTitleController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  List<String> members = [];
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  void _loadGroupDetails() {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        setState(() {
          members = List<String>.from(data?['members'] ?? []);
          expenses = List<Map<String, dynamic>>.from(data?['expenses'] ?? []);
        });
      }
    });
  }

  void _addMember() async {
    String email = _memberEmailController.text;
    if (email.isNotEmpty) {
      var userSnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
      if (userSnapshot.docs.isNotEmpty) {
        String memberId = userSnapshot.docs.first.id;
        await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
          'members': FieldValue.arrayUnion([memberId])
        });
        _memberEmailController.clear();
      }
    }
  }

  void _addExpense() async {
    double amount = double.tryParse(_expenseAmountController.text) ?? 0;
    String title = _expenseTitleController.text;
    if (amount > 0 && title.isNotEmpty && members.isNotEmpty) {
      double splitAmount = amount / members.length;
      List<Map<String, dynamic>> newExpenses = members.map((member) => {
        'title': title,
        'amount': splitAmount,
        'payer': FirebaseAuth.instance.currentUser!.email,
        'member': member
      }).toList();
      await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
        'expenses': FieldValue.arrayUnion(newExpenses)
      });
      _expenseTitleController.clear();
      _expenseAmountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _memberEmailController,
              decoration: InputDecoration(labelText: 'Enter member email', border: OutlineInputBorder()),
            ),
            ElevatedButton(onPressed: _addMember, child: Text('Add Member')),
            TextField(
              controller: _expenseTitleController,
              decoration: InputDecoration(labelText: 'Expense Title', border: OutlineInputBorder()),
            ),
            TextField(
              controller: _expenseAmountController,
              decoration: InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(onPressed: _addExpense, child: Text('Add Expense')),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var expense = expenses[index];
                  return ListTile(
                    title: Text(expense['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Amount: ₹${expense['amount']} - Paid by ${expense['payer']}'),
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