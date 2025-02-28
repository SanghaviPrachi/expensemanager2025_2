import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  void logout(BuildContext context) async {
    await AuthService().logoutUser();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(onPressed: () => logout(context), icon: Icon(Icons.logout))
        ],
      ),
      body: Center(child: Text('Welcome to Expense Manager')),
    );
  }
}
