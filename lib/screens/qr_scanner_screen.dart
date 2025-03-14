import 'package:flutter/material.dart';
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import '../screens/fabric_detail_screen.dart';
import '../screens/qr_scanner_screen.dart';

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
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: _scanQRCode, // Gọi hàm quét mã QR
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
              );
            },
          );
        },
      ),
    );
  }

  // 🟢 Tìm mẫu vải sau khi quét QR Code
  Future<void> _scanQRCode() async {
    final qrCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );

    if (qrCode != null && qrCode.isNotEmpty) {
      Fabric? fabric = await fabricService.getFabricById(qrCode);
      if (fabric != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FabricDetailScreen(fabricId: qrCode)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không tìm thấy mẫu vải với mã QR này!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không quét được mã QR, vui lòng thử lại!")),
      );
    }
  }
}
