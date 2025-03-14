import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import '../services/storage_service.dart';

class AddFabricScreen extends StatefulWidget {
  @override
  _AddFabricScreenState createState() => _AddFabricScreenState();
}

class _AddFabricScreenState extends State<AddFabricScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _materialController = TextEditingController();
  final _quantityController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveFabric() async {
    if (_nameController.text.isEmpty || _categoryController.text.isEmpty ||
        _materialController.text.isEmpty || _quantityController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    String imageUrl = await StorageService().uploadImage(_imageFile!);
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải ảnh lên Firebase, vui lòng thử lại!")),
      );
      return;
    }

    Fabric fabric = Fabric(
      name: _nameController.text,
      category: _categoryController.text,
      material: _materialController.text,
      quantity: int.parse(_quantityController.text),
      imageUrl: imageUrl,
    );

    await FabricService().addFabric(fabric);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm mẫu vải')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Tên mẫu vải')),
            TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'Loại vải')),
            TextField(controller: _materialController, decoration: InputDecoration(labelText: 'Chất liệu')),
            TextField(controller: _quantityController, decoration: InputDecoration(labelText: 'Số lượng'), keyboardType: TextInputType.number),
            ElevatedButton(onPressed: _pickImage, child: Text('Chọn ảnh mẫu vải')),
            _imageFile != null ? Image.file(_imageFile!, height: 100) : Container(),
            ElevatedButton(onPressed: _saveFabric, child: Text('Lưu mẫu vải')),
          ],
        ),
      ),
    );
  }
}
