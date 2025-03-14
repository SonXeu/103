
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🟢 Đăng ký người dùng với email và mật khẩu
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("✅ Đăng ký thành công: ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuthException khi đăng ký: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("❌ Lỗi không xác định khi đăng ký: $e");
      return null;
    }
  }

  // 🔵 Đăng nhập người dùng với email và mật khẩu
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("✅ Đăng nhập thành công: ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuthException khi đăng nhập: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("❌ Lỗi không xác định khi đăng nhập: $e");
      return null;
    }
  }

  // 🟠 Đăng xuất người dùng
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint("✅ Đăng xuất thành công");
    } catch (e) {
      debugPrint("❌ Lỗi khi đăng xuất: $e");
    }
  }

  // 🔵 Lấy thông tin người dùng hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  // 🟣 Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("✅ Email đặt lại mật khẩu đã được gửi đến: $email");
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuthException khi đặt lại mật khẩu: ${e.code} - ${e.message}");
    } catch (e) {
      debugPrint("❌ Lỗi không xác định khi đặt lại mật khẩu: $e");
    }
  }
// 🟢 Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("⚠️ Người dùng đã hủy đăng nhập Google");
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint("✅ Đăng nhập Google thành công: ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuthException khi đăng nhập Google: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("❌ Lỗi không xác định khi đăng nhập Google: $e");
      return null;
    }
  }
}

