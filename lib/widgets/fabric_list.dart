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
              return FabricItem(fabric: fabrics[index]);
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
