import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:provider/provider.dart';  // Import provider
import 'screens/auth_screen.dart';
import 'screens/fabric_list_screen.dart'; // Màn hình danh sách mẫu vải
import 'providers/user_provider.dart'; // Import UserProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..fetchUserRole()), // Đảm bảo gọi `fetchUserRole` khi khởi động
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      title: 'Fabric Manager',
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý mẫu vải"),
          actions: [
            // Nút thay đổi chế độ sáng/tối
            IconButton(
              icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                // Thay đổi chế độ sáng/tối
                final theme = Theme.of(context).brightness == Brightness.dark ? ThemeData.light() : ThemeData.dark();
                MyApp(theme: theme); // Thực hiện thay đổi theme
              },
            ),
          ],
        ),
        body: const FabricListScreen(), // Hiển thị màn hình danh sách mẫu vải
      ),
    );
  }
}
