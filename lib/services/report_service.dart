import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/fabric.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🟢 Lấy dữ liệu mẫu vải từ Firestore
  Future<List<Fabric>> fetchFabrics() async {
    QuerySnapshot snapshot = await _firestore.collection('fabrics').get();
    return snapshot.docs.map((doc) => Fabric.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  // 🟢 Xuất báo cáo ra file Excel
  Future<String> exportToExcel() async {
    List<Fabric> fabrics = await fetchFabrics();
    var excel = Excel.createExcel();
    Sheet sheet = excel['Báo cáo tồn kho'];

    // Thêm tiêu đề cột
    sheet.appendRow(['Tên mẫu vải', 'Loại', 'Chất liệu', 'Số lượng']);

    // Thêm dữ liệu mẫu vải
    for (var fabric in fabrics) {
      sheet.appendRow([fabric.name, fabric.category, fabric.material, fabric.quantity.toString()]);
    }

    // Lưu file
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory!.path}/bao_cao_ton_kho.xlsx';
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    return filePath;
  }

  // 🟢 Xuất báo cáo ra file PDF
  Future<String> exportToPDF() async {
    List<Fabric> fabrics = await fetchFabrics();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Báo cáo tồn kho', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Tên mẫu vải', 'Loại', 'Chất liệu', 'Số lượng'],
                data: fabrics.map((fabric) => [fabric.name, fabric.category, fabric.material, fabric.quantity.toString()]).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Lưu file PDF
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory!.path}/bao_cao_ton_kho.pdf';
    File file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}
