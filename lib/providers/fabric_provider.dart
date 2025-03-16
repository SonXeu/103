import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fabric.dart';
import '../models/transaction.dart';

class FabricProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Fabric> _fabrics = [];
  List<Fabric> get fabrics => _fabrics;
  List<Map<String, dynamic>> _editHistory = [];
  List<Map<String, dynamic>> get editHistory => _editHistory;

  // 🟢 Lấy danh sách vải từ Firestore
  Future<void> fetchFabrics() async {
    QuerySnapshot snapshot = await _firestore.collection('fabrics').get();
    _fabrics = snapshot.docs.map((doc) => Fabric.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    notifyListeners();
  }

  // 🟢 Thêm mẫu vải
  Future<void> addFabric(Fabric fabric) async {
    await _firestore.collection('fabrics').add(fabric.toFirestore());
    await fetchFabrics();
  }

  // 🟢 Cập nhật mẫu vải (bao gồm lịch sử chỉnh sửa)
  Future<void> updateFabric(String fabricId, Fabric oldFabric, Fabric updatedFabric, String editedBy) async {
    Map<String, dynamic> changes = {};
    if (oldFabric.name != updatedFabric.name) changes['Tên'] = updatedFabric.name;
    if (oldFabric.category != updatedFabric.category) changes['Loại'] = updatedFabric.category;
    if (oldFabric.material != updatedFabric.material) changes['Chất liệu'] = updatedFabric.material;
    if (oldFabric.quantity != updatedFabric.quantity) changes['Số lượng'] = updatedFabric.quantity;
    if (oldFabric.imageUrls.toString() != updatedFabric.imageUrls.toString()) changes['Hình ảnh'] = updatedFabric.imageUrls;

    if (changes.isNotEmpty) {
      await _firestore.collection('fabrics').doc(fabricId).update(updatedFabric.toFirestore());
      await _firestore.collection('edit_history').add({
        'fabricId': fabricId,
        'editedBy': editedBy,
        'changes': changes,
        'editedAt': Timestamp.now(),
      });
      fetchEditHistory(fabricId);
    }
  }

  // 🟢 Xóa mẫu vải
  Future<void> deleteFabric(String fabricId) async {
    await _firestore.collection('fabrics').doc(fabricId).delete();
    _fabrics.removeWhere((fabric) => fabric.id == fabricId);
    notifyListeners();
  }

  // 🟢 Lấy lịch sử chỉnh sửa của một mẫu vải
  Future<void> fetchEditHistory(String fabricId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('edit_history')
        .where('fabricId', isEqualTo: fabricId)
        .orderBy('editedAt', descending: true)
        .get();

    _editHistory = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }
}
