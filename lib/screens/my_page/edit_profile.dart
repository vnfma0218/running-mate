import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/widgets/ui_elements/image_input.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nicknameController = TextEditingController();
  File? _selectedImage;
  UploadTask? _uploadTask;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nicknameController.text = widget.user.name;
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  Future<String> uploadFile() async {
    setState(() {
      isLoading = true;
    });
    final path = 'files/${widget.user.id}}';

    final ref = FirebaseStorage.instance.ref().child(path);
    _uploadTask = ref.putFile(_selectedImage!);

    final snapshot = await _uploadTask!.whenComplete(() => null);
    final urlDownload = await snapshot.ref.getDownloadURL();
    return urlDownload;
  }

  void _editProfile() async {
    String? imageUrl = widget.user.imageUrl;
    if (_selectedImage != null) {
      imageUrl = await uploadFile();
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.id)
        .update({
      "name": nicknameController.text,
      "imageUrl": imageUrl,
    });
    setState(() {
      isLoading = false;
    });
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop('saved');
  }

  void _selectImage(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프로필 수정',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          TextButton(
            onPressed: _editProfile,
            child: const Text('완료'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        )
                      : isLoading
                          ? const Icon(Icons.person)
                          : widget.user.imageUrl != null
                              ? Image.network(
                                  widget.user.imageUrl!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person),
                                )
                              : const Icon(Icons.person),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: Colors.white,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          50,
                        ),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ImageInput(onPickImage: _selectImage),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputLabel(text: '닉네임'),
                Form(
                  child: TextFormField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      label: const Text('닉네임'),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
