import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountInfoScreen extends StatefulWidget {
  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  String name = "Loading...";
  String accountCreationDate = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchAccountInfo();
  }

  void _fetchAccountInfo() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      setState(() {
        name = userData?['name'] ?? 'Unknown';

        // Handle missing created_at field safely
        Timestamp? createdAtTimestamp = userData?['created_at'];
        if (createdAtTimestamp != null) {
          accountCreationDate = createdAtTimestamp.toDate().toString();
        } else {
          accountCreationDate = 'N/A';
        }
      });
    } else {
      setState(() {
        name = "No Data Found";
        accountCreationDate = "N/A";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account Information")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Holder: $name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Account Created: $accountCreationDate",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
