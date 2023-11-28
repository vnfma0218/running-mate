import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';

class NewInquiryPage extends StatefulWidget {
  const NewInquiryPage({super.key});

  @override
  State<NewInquiryPage> createState() => _NewInquiryPageState();
}

class _NewInquiryPageState extends State<NewInquiryPage> {
  final _formKey = GlobalKey<FormState>();
  String _enteredTitle = '';
  String _enteredContent = '';

  void _submitInquiry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final authencatiedUser = FirebaseAuth.instance.currentUser!;

      try {
        await firestore.collection('inquiries').doc().set({
          "user": authencatiedUser.uid,
          "title": _enteredTitle,
          "content": _enteredContent,
          "createdAt": FieldValue.serverTimestamp()
        });
        _onSnackbarMessage(message: '문의가 접수되었습니다.');
      } catch (e) {
        _onSnackbarMessage(message: '문제가 생겼습니다. 잠시 후 다시 시도해주세요');
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      _formKey.currentState!.reset();
    }
  }

  void _onSnackbarMessage({required String message, int duration = 1200}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: duration),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('문의 남기기')),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '문의글을 작성해주세요.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          '관리자가 문의 확인 후, 답변드리겠습니다.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const InputLabel(text: '제목'),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: '제목을 입력해주세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.only(top: 14),
                            ),
                          ),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '제목을 입력해주세요';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredTitle = newValue!;
                          },
                        ),
                        const SizedBox(height: 20),
                        const InputLabel(text: '내용'),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: '내용을 입력해주세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: const Padding(
                              padding: EdgeInsets.only(top: 14),
                            ),
                          ),
                          maxLines: 8,
                          minLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '내용을 입력해주세요';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredContent = newValue!;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _submitInquiry,
                        child: const Text('문의')),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
