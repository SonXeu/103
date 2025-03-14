import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fabric.dart';
import '../services/storage_service.dart';

class FabricService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

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

  // 🔴 Xóa mẫu vải (kèm theo ảnh nếu có)
  Future<void> deleteFabric(String fabricId) async {
    try {
      Fabric? fabric = await getFabricById(fabricId);
      if (fabric != null) {
        if (fabric.imageUrl.isNotEmpty) {
          try {
            await _storageService.deleteImage(fabric.imageUrl);
            debugPrint("✅ Ảnh đã được xóa: ${fabric.imageUrl}");
          } catch (e) {
            debugPrint('⚠️ Lỗi khi xóa ảnh: $e');
          }
        }
        await _firestore.collection('fabrics').doc(fabricId).delete();
        debugPrint("✅ Mẫu vải đã được xóa thành công!");
      } else {
        debugPrint("⚠️ Không thể xóa, mẫu vải không tồn tại.");
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi xóa mẫu vải: $e");
    }
  }
}
