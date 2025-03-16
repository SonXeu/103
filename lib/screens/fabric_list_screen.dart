import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import 'fabric_detail_screen.dart';
import 'add_fabric_screen.dart';
import '../providers/user_provider.dart'; // Import UserProvider

class FabricListScreen extends StatefulWidget {
  @override
  _FabricListScreenState createState() => _FabricListScreenState();
}

class _FabricListScreenState extends State<FabricListScreen> {
  final FabricService fabricService = FabricService();
  String selectedCategory = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context); // Lấy quyền người dùng

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách mẫu vải'),
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            items: ['Tất cả', 'Cotton', 'Lụa', 'Polyester']
                .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Fabric>>(
        stream: fabricService.getFabrics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          List<Fabric> fabrics = snapshot.data!;
          if (selectedCategory != 'Tất cả') {
            fabrics = fabrics.where((fabric) => fabric.category == selectedCategory).toList();
          }

          // Kiểm tra cảnh báo tồn kho thấp
          for (var fabric in fabrics) {
            if (fabric.quantity < 10) {  // Ngưỡng tồn kho thấp (ví dụ < 10)
              // Thông báo cho người dùng khi tồn kho thấp
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cảnh báo: ${fabric.name} sắp hết hàng!'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }
          }

          return ListView.builder(
            itemCount: fabrics.length,
            itemBuilder: (ctx, index) {
              return ListTile(
                title: Text(
                  fabrics[index].name,
                  style: TextStyle(
                    color: fabrics[index].quantity < 10 ? Colors.red : Colors.black,
                  ),
                ),
                subtitle: Text('Loại: ${fabrics[index].category}, Số lượng: ${fabrics[index].quantity}'),
                tileColor: fabrics[index].quantity < 10 ? Colors.red[100] : null, // Đánh dấu nếu tồn kho thấp
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FabricDetailScreen(fabricId: fabrics[index].id!),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: userProvider.isStaff
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddFabricScreen()));
        },
        child: Icon(Icons.add),
      )
          : null, // Chỉ hiển thị nút thêm mẫu vải nếu là Staff hoặc Admin
    );
  }
}
