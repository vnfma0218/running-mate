import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:running_mate/constants/constant.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/screens/home.dart';
import 'package:running_mate/services/auth_service.dart';
import 'package:running_mate/widgets/ui_elements/image_input.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  File? _selectedImage;
  UploadTask? _uploadTask;

  String? _enteredNickname;
  String? _enteredEmail;
  String? _enteredPassword;

  String? validateEmail(String? value) {
    final regex = RegExp(email_repex);
    return value!.isEmpty || !regex.hasMatch(value) ? '알맞은 이메일을 입력해주세요' : null;
  }

  String? validateNickname(String? value) {
    final regex = RegExp(nickname_regex);
    return value!.isEmpty || !regex.hasMatch(value)
        ? '닉네임은 2자 이상 16자 이하, 영어 또는 숫자 또는 한글로 입력해주세요'
        : null;
  }

  void _saveUserDetail(UserModel userModel) async {
    await FirebaseFirestore.instance.collection('users').doc(userModel.id).set(
      {
        'email': userModel.email,
        'name': userModel.name,
        'imageUrl': userModel.imageUrl
      },
    );

    _moveHomeScreen();
  }

  void _createUserWithEmail() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _enteredEmail!, password: _enteredPassword!);

      if (credential.user != null) {
        var userImageUrl = user_defalut_img_path;
        if (_selectedImage != null) {
          userImageUrl = await _uploadFile(credential.user!.uid);
        }

        _saveUserDetail(UserModel(
            id: credential.user!.uid,
            name: _enteredNickname!,
            imageUrl: userImageUrl,
            email: _enteredEmail!));
      }
    } on FirebaseAuthException catch (autherror) {
      _showSnackbar(autherror.message ?? '회원가입을 할 수 없습니다.');
    }
  }

  Future<String> _uploadFile(String uid) async {
    final path = 'files/$uid}';

    final ref = FirebaseStorage.instance.ref().child(path);
    _uploadTask = ref.putFile(_selectedImage!);

    final snapshot = await _uploadTask!.whenComplete(() => null);
    final urlDownload = await snapshot.ref.getDownloadURL();
    return urlDownload;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _selectImage(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _moveHomeScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return const HomeScreen();
      },
    ));
  }

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _enteredEmail!, password: _enteredPassword!);
      _moveHomeScreen();
    } on FirebaseAuthException catch (autherror) {
      _showSnackbar(autherror.message ?? '로그인을 할 수가 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            if (isLogin)
              SvgPicture.asset(
                'assets/icons/run.svg',
                height: 200,
                width: 200,
              ),
            if (!isLogin)
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: 120,
                              )
                            : const Icon(
                                Icons.person,
                                size: 100,
                              )),
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
                  )
                ],
              ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isLogin) const InputLabel(text: '닉네임'),
                  if (!isLogin)
                    TextFormField(
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: validateNickname,
                      onSaved: (value) {
                        _enteredNickname = value;
                      },
                    ),
                  const InputLabel(text: '이메일'),
                  TextFormField(
                    maxLength: 30,
                    decoration: InputDecoration(
                      label: const Text('이메일'),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: validateEmail,
                    onSaved: (value) {
                      _enteredEmail = value;
                    },
                  ),
                  const InputLabel(text: '비밀번호'),
                  TextFormField(
                    maxLength: 30,
                    obscureText: true,
                    decoration: InputDecoration(
                      label: const Text('비밀번호'),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '알맞은 패스워드를 입력해주세요';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredPassword = value;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                            12,
                          ))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (isLogin) {
                            _login();
                          } else {
                            _createUserWithEmail();
                          }
                        }
                      },
                      child: Text(
                        isLogin ? '로그인' : '회원가입',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(!isLogin ? '이미 계정이 있으신가요?' : '계정이 없으신가요?'),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(!isLogin ? '로그인' : '회원가입'),
                      )
                    ],
                  ),
                  if (isLogin)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      )),
                      onPressed: () async {
                        // google login
                        final result = await AuthService().signInWithGoogle();
                        final user = FirebaseAuth.instance.currentUser;
                        print(
                            '------------------login------------------------');
                        if (result.user.email != null) {
                          final userDetail =
                              await AuthService().getUserInfo(user!.uid);
                          if (userDetail == null) {
                            _saveUserDetail(
                              UserModel(
                                  id: user.uid,
                                  name: result.user.displayName,
                                  imageUrl: result
                                      .additionalUserInfo.profile['picture'],
                                  email: result.user.email),
                            );
                          }

                          _moveHomeScreen();
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/icons/google.svg',
                        height: 50,
                        width: 50,
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
