import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/fabric.dart';
import '../services/fabric_service.dart';

class FabricReportScreen extends StatefulWidget {
  @override
  _FabricReportScreenState createState() => _FabricReportScreenState();
}

class _FabricReportScreenState extends State<FabricReportScreen> {
  final FabricService fabricService = FabricService();
  final ReportService reportService = ReportService();

  Future<void> _exportReport(bool isExcel) async {
    String filePath = isExcel ? await reportService.exportToExcel() : await reportService.exportToPDF();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Báo cáo đã lưu tại: $filePath")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thống kê mẫu vải')),
      body: StreamBuilder<List<Fabric>>(
        stream: fabricService.getFabrics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final fabrics = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: fabrics.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(fabrics[index].name),
                      subtitle: Text('Loại: ${fabrics[index].category}, Số lượng: ${fabrics[index].quantity}'),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _exportReport(true),
                    icon: Icon(Icons.table_chart),
                    label: Text('Xuất Excel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _exportReport(false),
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('Xuất PDF'),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
