import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/fabric.dart';
import '../services/fabric_service.dart';
import '../services/storage_service.dart';

class AddFabricScreen extends StatefulWidget {
  const AddFabricScreen({Key? key}) : super(key: key);

  @override
  State<AddFabricScreen> createState() => _AddFabricScreenState();
}

class _AddFabricScreenState extends State<AddFabricScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _materialController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  bool _isValidQuantity(String quantity) {
    return int.tryParse(quantity) != null && int.parse(quantity) > 0;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _saveFabric() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _materialController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _pickedImage == null) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    if (!_isValidQuantity(_quantityController.text)) {
      _showSnackBar("Số lượng phải là một số hợp lệ");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      File imageFile = File(_pickedImage!.path);
      String imageUrl = await StorageService().uploadImage(imageFile);
      if (imageUrl.isEmpty) {
        _showSnackBar("Lỗi tải ảnh, thử lại!");
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
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("Đã xảy ra lỗi: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm mẫu vải')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên mẫu vải'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Loại vải'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _materialController,
                    decoration: const InputDecoration(labelText: 'Chất liệu'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _pickImage,
                    child: const Text('Chọn ảnh mẫu vải'),
                  ),
                  const SizedBox(height: 16),
                  _pickedImage != null
                      ? Image.file(File(_pickedImage!.path), height: 100)
                      : Container(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveFabric,
                    child: const Text('Lưu mẫu vải'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
