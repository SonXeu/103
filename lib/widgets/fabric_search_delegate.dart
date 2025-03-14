import 'package:flutter/material.dart';
import '../models/fabric.dart';
import '../services/fabric_service.dart';  // Dịch vụ mẫu vải

class FabricSearchDelegate extends SearchDelegate<String> {
  final FabricService fabricService = FabricService();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Fabric>>(
      future: fabricService.getFabrics().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không tìm thấy mẫu vải.'));
        }

        final fabrics = snapshot.data!
            .where((fabric) => fabric.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: fabrics.length,
          itemBuilder: (ctx, index) {
            var fabric = fabrics[index];
            return ListTile(
              title: Text(fabric.name),
              subtitle: Text('Loại: ${fabric.category}, Số lượng: ${fabric.quantity}'),
              leading: Image.network(fabric.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FabricDetailScreen(fabricId: fabric.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Không hiển thị gợi ý, chỉ cần hiển thị kết quả tìm kiếm.
  }
}
