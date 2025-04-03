import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void _deleteGroup(String groupId) {
    FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Split Expense')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addGroup,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        color: Colors.grey[300],
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (direction) {
                        _deleteGroup(doc.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Group Deleted")));
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(doc['name']),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupDetailScreen(groupId: doc.id, groupName: doc['name']),
                            ),
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
  String? _paidBy;
  List<String> members = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  void _fetchGroupDetails() {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;

        setState(() {
          members = (data['members'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          if (_paidBy == null && members.isNotEmpty) {
            _paidBy = members.first;
          }
        });
      }
    });
  }

  void _updateSplit() async {
    var expenses = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('expenses').get();

    for (var expense in expenses.docs) {
      double totalAmount = expense['amount'];
      double individualShare = members.isNotEmpty ? totalAmount / members.length : 0.0;

      await expense.reference.update({'individualShare': individualShare});
    }
  }

  void _inviteMember() {
    if (_memberEmailController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
        'members': FieldValue.arrayUnion([_memberEmailController.text]),
      }).then((_) {
        _updateSplit();
      });
      _memberEmailController.clear();
    }
  }

  void _removeMember(String member) {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
      'members': FieldValue.arrayRemove([member]),
    }).then((_) {
      _updateSplit();
    });
  }

  void _addExpense() {
    if (_expenseTitleController.text.isNotEmpty &&
        _expenseAmountController.text.isNotEmpty &&
        _paidBy != null) {
      double totalAmount = double.tryParse(_expenseAmountController.text) ?? 0.0;
      double individualShare = members.isNotEmpty ? totalAmount / members.length : 0.0;

      FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('expenses').add({
        'title': _expenseTitleController.text,
        'amount': totalAmount,
        'splitAmong': members,
        'individualShare': individualShare,
        'paidBy': _paidBy,
      });

      _expenseTitleController.clear();
      _expenseAmountController.clear();
    }
  }

  void _deleteExpense(String expenseId) {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('expenses').doc(expenseId).delete().then((_) {
      _updateSplit();
    });
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
                  return Dismissible(
                    key: Key(members[index]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      color: Colors.grey[300],
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                    onDismissed: (direction) {
                      _removeMember(members[index]);
                    },
                    child: ListTile(
                      title: Text(members[index]),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _memberEmailController,
              decoration: InputDecoration(labelText: 'Invite Member Email'),
            ),
            IconButton(icon: Icon(Icons.person_add), onPressed: _inviteMember),
            DropdownButton<String>(
              value: _paidBy,
              onChanged: (String? newValue) {
                setState(() {
                  _paidBy = newValue;
                });
              },
              items: members.map<DropdownMenuItem<String>>((member) {
                return DropdownMenuItem<String>(
                  value: member,
                  child: Text(member),
                );
              }).toList(),
              hint: Text('Select who paid'),
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
            ElevatedButton(onPressed: _addExpense, child: Text('Add Expense')),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('expenses').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  var expenses = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      var expense = expenses[index];
                      var data = expense.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['title'] ?? 'Unknown Expense'),
                        subtitle: Text('₹${data['amount']} | Each Share: ₹${data['individualShare']}'),
                        trailing: Text('Paid by: ${data['paidBy']}'),
                      );
                    },
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
