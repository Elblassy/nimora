import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/child_info.dart';
import '../theme/app_theme.dart';
import 'photo_preview.dart';

class UploadForm extends StatefulWidget {
  final Function(ChildInfo) onSubmit;

  const UploadForm({super.key, required this.onSubmit});

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  final _nameController = TextEditingController();
  int _selectedAge = 5;
  String _selectedTheme = 'adventure';
  Uint8List? _photoBytes;
  String? _photoFileName;

  final _themes = {
    'adventure': 'Adventure',
    'space': 'Space',
    'ocean': 'Ocean',
    'forest': 'Forest',
  };

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _photoBytes = result.files.single.bytes;
        _photoFileName = result.files.single.name;
      });
    }
  }

  void _submit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your child\'s name')),
      );
      return;
    }
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo')),
      );
      return;
    }

    widget.onSubmit(ChildInfo(
      name: _nameController.text.trim(),
      age: _selectedAge,
      photoBytes: _photoBytes,
      photoFileName: _photoFileName,
      theme: _selectedTheme,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppTheme.primary.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhotoPreview(
              photoBytes: _photoBytes,
              onTap: _pickPhoto,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Child\'s Name',
                hintText: 'Enter your child\'s name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedAge,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake),
              ),
              items: List.generate(10, (i) => i + 3)
                  .map((age) => DropdownMenuItem(
                        value: age,
                        child: Text('$age years old'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedAge = value ?? 5),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedTheme,
              decoration: const InputDecoration(
                labelText: 'Story Theme',
                prefixIcon: Icon(Icons.auto_stories),
              ),
              items: _themes.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedTheme = value ?? 'adventure'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Start My Story'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
