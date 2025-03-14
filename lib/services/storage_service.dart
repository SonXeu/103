import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}_${imageFile.hashCode}";
      Reference ref = _storage.ref().child("fabric_images/$fileName");
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();
      debugPrint('✅ Ảnh đã tải lên thành công: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException khi tải ảnh lên: ${e.code} - ${e.message}');
      return '';
    } catch (e) {
      debugPrint('❌ Lỗi không xác định khi tải ảnh lên Firebase Storage: $e');
      return '';
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
        await _storage.refFromURL(imageUrl).delete();
        debugPrint('✅ Ảnh đã được xóa khỏi Firebase Storage.');
      } else {
        debugPrint('⚠ URL không hợp lệ, không thể xóa ảnh.');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi xóa ảnh khỏi Firebase Storage: $e');
    }
  }
}
