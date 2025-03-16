import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import '../providers/user_provider.dart';  // Import UserProvider
import '../models/transaction.dart';
import 'update_fabric_screen.dart';

class FabricDetailScreen extends StatelessWidget {
  final String fabricId;

  FabricDetailScreen({required this.fabricId});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context); // Lấy quyền người dùng
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết mẫu vải')),
      body: FutureBuilder<Fabric?>(
        future: FabricService().getFabricById(fabricId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          Fabric fabric = snapshot.data!; // Mẫu vải

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

                // Kiểm tra phân quyền người dùng trước khi hiển thị nút sửa và xóa
                if (userProvider.isStaff || userProvider.isAdmin) ...[
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

                // Lịch sử giao dịch
                SizedBox(height: 16),
                Text('Lịch sử giao dịch:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                StreamBuilder<List<Transaction>>(
                  stream: FabricService().getTransactionsByFabricId(fabricId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final transactions = snapshot.data!;

                    if (transactions.isEmpty) {
                      return Center(child: Text('Chưa có giao dịch nào.'));
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (ctx, index) {
                          final transaction = transactions[index];
                          return Dismissible(
                            key: Key(transaction.id!),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              // Xóa giao dịch khi người dùng vuốt
                              await _deleteTransaction(transaction.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Giao dịch đã bị xóa")),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            child: ListTile(
                              leading: Icon(
                                transaction.transactionType == 'import'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: transaction.transactionType == 'import' ? Colors.green : Colors.red,
                              ),
                              title: Text('${transaction.transactionType == 'import' ? 'Nhập kho' : 'Xuất kho'}: ${transaction.quantity}'),
                              subtitle: Text(transaction.note.isNotEmpty ? transaction.note : 'Không có ghi chú'),
                              trailing: Text(DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate)),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🟢 Hàm xóa giao dịch
  Future<void> _deleteTransaction(String transactionId) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      debugPrint("❌ Lỗi khi xóa giao dịch: $e");
    }
  }
}
