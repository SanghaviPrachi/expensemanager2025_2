import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplitExpenseScreen extends StatefulWidget {
  @override
  _SplitExpenseScreenState createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  void _addGroup() {
    if (_groupNameController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('groups').add({
        'name': _groupNameController.text,
        'members': [],
      });
      _groupNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Expense', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addGroup,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('groups').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(doc['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupDetailScreen(groupId: doc.id, groupName: doc['name']),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
  List<dynamic> members = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots().listen((doc) {
      setState(() {
        members = doc['members'] ?? [];
      });
    });
  }

  void _inviteMember() {
    if (_memberEmailController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
        'members': FieldValue.arrayUnion([_memberEmailController.text]),
      });
      FirebaseFirestore.instance.collection('users').doc(_memberEmailController.text).update({
        'groups': FieldValue.arrayUnion([widget.groupId])
      });
      _sendEmailInvitation(_memberEmailController.text);
      _memberEmailController.clear();
    }
  }

  void _sendEmailInvitation(String email) {
    // Implement email sending logic
    print('Sending invitation to $email');
  }

  void _addExpense() {
    if (_expenseTitleController.text.isNotEmpty && _expenseAmountController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('expenses').add({
        'title': _expenseTitleController.text,
        'amount': double.parse(_expenseAmountController.text),
        'currency': 'INR',
        'splitAmong': members,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Members:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(members[index]),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberEmailController,
                    decoration: InputDecoration(labelText: 'Invite Member Email'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: _inviteMember,
                ),
              ],
            ),
            TextField(
              controller: _expenseTitleController,
              decoration: InputDecoration(labelText: 'Expense Title'),
            ),
            TextField(
              controller: _expenseAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount (INR)'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('expenses').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((doc) {
                      return ListTile(
                        title: Text(doc['title']),
                        subtitle: Text('Amount: ₹${doc['amount']} INR'),
                      );
                    }).toList(),
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
