import 'package:flutter/material.dart';
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import 'fabric_detail_screen.dart';
import 'add_fabric_screen.dart';

class FabricListScreen extends StatefulWidget {
  @override
  _FabricListScreenState createState() => _FabricListScreenState();
}

class _FabricListScreenState extends State<FabricListScreen> {
  final FabricService fabricService = FabricService();
  String selectedCategory = 'Tất cả';

  @override
  Widget build(BuildContext context) {
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FabricDetailScreen(fabricId: fabrics[index].id!),
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
                      await fabricService.deleteFabric(fabrics[index].id!);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddFabricScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
