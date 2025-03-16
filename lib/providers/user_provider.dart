import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  String _role = 'viewer'; // Mặc định là viewer
  String get role => _role;

  // Hàm lấy role người dùng
  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _role = doc.data()?['role'] ?? 'viewer';
      notifyListeners(); // Cập nhật các widget đang lắng nghe
    }
  }

  // Các phương thức kiểm tra quyền của người dùng
  bool get isAdmin => _role == 'admin';
  bool get isStaff => _role == 'staff' || isAdmin;
  bool get isViewer => _role == 'viewer';
}
