import 'package:flutter/material.dart';
import '../services/fabric_service.dart';
import '../models/fabric.dart';

class FabricReportScreen extends StatelessWidget {
  final FabricService fabricService = FabricService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thống kê mẫu vải')),
      body: StreamBuilder<List<Fabric>>(
        stream: fabricService.getFabrics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final Map<String, int> fabricCounts = {};
          for (var fabric in snapshot.data!) {
            fabricCounts[fabric.category] = (fabricCounts[fabric.category] ?? 0) + fabric.quantity;
          }

          return ListView(
            children: fabricCounts.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text('Tổng số lượng: ${entry.value}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
