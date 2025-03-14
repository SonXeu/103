import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final User? user;

  HomeScreen({required this.user});

  // Hàm cập nhật email của người dùng
  Future<void> _updateUserEmail(String newEmail) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'email': newEmail,
      });
    } catch (e) {
      print('Error updating email: $e');
    }
  }

  // Hàm xóa người dùng và dữ liệu trong Firestore
  Future<void> _deleteUser() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).delete();
      await user?.delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.hasData) {
              var userData = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${userData['email']}', style: TextStyle(fontSize: 24)),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                      );
                    },
                    child: Text('Sign Out'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Mở cửa sổ nhập email mới và cập nhật vào Firestore
                      String newEmail = 'newemail@example.com'; // Nhập email mới
                      await _updateUserEmail(newEmail);
                    },
                    child: Text('Update Email'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _deleteUser();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                      );
                    },
                    child: Text('Delete Account'),
                  ),
                ],
              );
            } else {
              return Text('User data not available');
            }
          },
        ),
      ),
    );
  }
}
