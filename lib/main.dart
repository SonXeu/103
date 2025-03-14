import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'screens/fabric_list_screen.dart'; // Import màn hình danh sách mẫu vải

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter đã khởi tạo

  await initializeFirebase(); // Gọi hàm khởi tạo Firebase trước khi chạy app

  runApp(MyApp());
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(); // Khởi tạo Firebase
    debugPrint("🔥 Firebase khởi tạo thành công!");
  } catch (e) {
    debugPrint("❌ Lỗi khi khởi tạo Firebase: $e");
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // Trạng thái giao diện tối

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      title: 'Fabric Manager',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý mẫu vải"),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        body: const FabricListScreen(), // Hiển thị màn hình danh sách mẫu vải
      ),
    );
  }
}
