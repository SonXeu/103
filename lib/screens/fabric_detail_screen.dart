import 'package:flutter/material.dart';
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import 'update_fabric_screen.dart';

class FabricDetailScreen extends StatelessWidget {
  final String fabricId;

  FabricDetailScreen({required this.fabricId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết mẫu vải')),
      body: FutureBuilder<Fabric?>(
        future: FabricService().getFabricById(fabricId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          Fabric fabric = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(fabric.imageUrl, height: 200, fit: BoxFit.cover),
                SizedBox(height: 16),
                Text('Tên mẫu vải: ${fabric.name}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Loại: ${fabric.category}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Chất liệu: ${fabric.material}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Số lượng: ${fabric.quantity}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateFabricScreen(fabricId: fabricId)));
                  },
                  child: Text('Sửa mẫu vải'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Xóa mẫu vải?'),
                        content: Text('Bạn có chắc chắn muốn xóa mẫu vải này không?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Hủy')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Xóa')),
                        ],
                      ),
                    );

                    if (confirm) {
                      await FabricService().deleteFabric(fabricId);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Xóa mẫu vải'),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
