import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../providers/user_provider.dart'; // Import UserProvider

class HomeScreen extends StatelessWidget {
  final User? user;

  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Role: ${userProvider.role}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            if (userProvider.isAdmin)
              ElevatedButton(
                onPressed: () {
                  // Admin chỉ có thể thực hiện hành động này
                  print('Admin action');
                },
                child: Text('Admin Action'),
              ),
            if (userProvider.isStaff)
              ElevatedButton(
                onPressed: () {
                  // Staff chỉ có thể thực hiện hành động này
                  print('Staff action');
                },
                child: Text('Staff Action'),
              ),
            if (userProvider.isViewer)
              ElevatedButton(
                onPressed: () {
                  // Viewer chỉ có thể xem thông tin
                  print('Viewer action');
                },
                child: Text('Viewer Action'),
              ),
          ],
        ),
      ),
    );
  }
}
