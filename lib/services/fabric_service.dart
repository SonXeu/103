import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/fabric.dart';
import '../models/transaction.dart';

class FabricService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🟢 Lấy dữ liệu mẫu vải theo ID
  Future<Fabric?> getFabricById(String fabricId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('fabrics').doc(fabricId).get();
      if (doc.exists && doc.data() != null) {
        return Fabric.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        debugPrint("⚠️ Không tìm thấy mẫu vải với ID: $fabricId");
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy mẫu vải: $e");
    }
    return null;
  }

  // 🟢 Lấy tất cả mẫu vải
  Stream<List<Fabric>> getFabrics() {
    return _firestore.collection('fabrics').snapshots().map(
          (snapshot) {
        List<Fabric> fabrics = [];
        snapshot.docs.forEach((doc) {
          fabrics.add(Fabric.fromFirestore(doc.data() as Map<String, dynamic>, doc.id));
        });

        // Kiểm tra cảnh báo tồn kho thấp
        for (var fabric in fabrics) {
          if (fabric.quantity < 10) {
            // Cảnh báo tồn kho thấp
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${fabric.name} sắp hết hàng!')),
              );
            });
          }
        }
        return fabrics;
      },
    );
  }

  // 🟢 Thêm giao dịch
  Future<void> addTransaction(Transaction transaction, BuildContext context) async {
    try {
      await _firestore.collection('transactions').add(transaction.toFirestore());

      // Thông báo khi có giao dịch mới
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giao dịch ${transaction.transactionType} thành công!'),
          backgroundColor: transaction.transactionType == 'import' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      debugPrint("❌ Lỗi khi thêm giao dịch: $e");
    }
  }

  // 🟢 Xóa mẫu vải
  Future<void> deleteFabric(String fabricId) async {
    try {
      await _firestore.collection('fabrics').doc(fabricId).delete();
      debugPrint("✅ Mẫu vải đã được xóa thành công!");
    } catch (e) {
      debugPrint("❌ Lỗi khi xóa mẫu vải: $e");
    }
  }

}

