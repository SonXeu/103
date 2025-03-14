import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import '../services/storage_service.dart';

class UpdateFabricScreen extends StatefulWidget {
  final String fabricId;

  UpdateFabricScreen({required this.fabricId});

  @override
  _UpdateFabricScreenState createState() => _UpdateFabricScreenState();
}

class _UpdateFabricScreenState extends State<UpdateFabricScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _materialController = TextEditingController();
  final _quantityController = TextEditingController();
  File? _imageFile;
  String? _imageUrl; // Lưu trữ URL ảnh hiện tại
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true; // Trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    _loadFabricData();
  }

  // 🟢 Tải dữ liệu mẫu vải từ Firestore
  Future<void> _loadFabricData() async {
    Fabric? fabric = await FabricService().getFabricById(widget.fabricId);
    if (fabric != null) {
      setState(() {
        _nameController.text = fabric.name;
        _categoryController.text = fabric.category;
        _materialController.text = fabric.material;
        _quantityController.text = fabric.quantity.toString();
        _imageUrl = fabric.imageUrl;
        _isLoading = false; // Dữ liệu đã tải xong
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không tìm thấy mẫu vải!")));
      Navigator.pop(context);
    }
  }

  // 📸 Mở thư viện ảnh để chọn ảnh mới
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 🟢 Cập nhật mẫu vải
  Future<void> _updateFabric() async {
    if (_nameController.text.isEmpty || _categoryController.text.isEmpty ||
        _materialController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")));
      return;
    }

    String imageUrl = _imageUrl ?? ''; // Giữ ảnh cũ nếu không thay đổi

    if (_imageFile != null) {
      // Nếu có ảnh mới, tải lên Firebase Storage
      imageUrl = await StorageService().uploadImage(_imageFile!);
      if (imageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải ảnh, thử lại!")));
        return;
      }
    }

    Fabric updatedFabric = Fabric(
      id: widget.fabricId,
      name: _nameController.text,
      category: _categoryController.text,
      material: _materialController.text,
      quantity: int.parse(_quantityController.text),
      imageUrl: imageUrl,
    );

    await FabricService().updateFabric(widget.fabricId, updatedFabric);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cập nhật thành công!")));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Cập nhật mẫu vải')),
        body: Center(child: CircularProgressIndicator()), // Hiển thị vòng tròn tải dữ liệu
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Cập nhật mẫu vải')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên mẫu vải'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Loại vải'),
            ),
            TextField(
              controller: _materialController,
              decoration: InputDecoration(labelText: 'Chất liệu'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Số lượng'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Chọn ảnh mới'),
            ),
            SizedBox(height: 10),
            _imageFile != null
                ? Image.file(_imageFile!, height: 150) // Hiển thị ảnh mới chọn
                : (_imageUrl != null && _imageUrl!.isNotEmpty
                ? Image.network(_imageUrl!, height: 150) // Hiển thị ảnh cũ nếu không đổi
                : Container()),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateFabric,
              child: Text('Lưu cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}
