import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});
  final User user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nicknameController = TextEditingController();

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

  void _editProfile() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.id)
        .update({
      "name": nicknameController.text,
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
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    widget.user.imageUrl,
                    width: 80,
                  ),
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
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputLabel(text: '닉네임'),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    label: const Text('닉네임'),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
