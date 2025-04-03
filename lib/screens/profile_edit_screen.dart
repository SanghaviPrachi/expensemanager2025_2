import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        nameController.text = userDoc.get('name') ?? 'N/A';
        phoneController.text = userDoc.get('phone') ?? 'N/A';
        emailController.text = userDoc.get('email') ?? user.email ?? 'N/A';
      } else {
        // If user data doesn't exist in Firestore, fall back to FirebaseAuth email
        emailController.text = user.email ?? 'N/A';
      }
    }
    setState(() => isLoading = false);
  }

  void _saveProfileData() async {
    await _firestore.collection('users').doc(userId).update({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: false, // Email shouldn't be editable
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfileData,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
