import 'package:flutter/material.dart';
import '../models/fabric.dart';
import '../screens/fabric_detail_screen.dart';
import '../services/fabric_service.dart';

class FabricItem extends StatelessWidget {
  final Fabric fabric;

  FabricItem({required this.fabric});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: Image.network(
          fabric.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          fabric.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Loại: ${fabric.category}\nSố lượng: ${fabric.quantity}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FabricDetailScreen(fabricId: fabric.id!),
            ),
          );
        },
        trailing: IconButton(
          icon: Icon(Icons.delete),
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
              await FabricService().deleteFabric(fabric.id!);
            }
          },
        ),
      ),
    );
  }
}
