import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:running_mate/screens/home.dart';
import 'package:running_mate/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;

  var _enteredEmail;
  var _enteredPassword;
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
            SvgPicture.asset(
              'assets/icons/run.svg',
              height: 200,
              width: 200,
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      maxLength: 30,
                      decoration: InputDecoration(
                        label: const Text('이메일'),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '알맞은 이메일을 입력해주세요';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredEmail = value;
                      },
                    ),
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
                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _enteredEmail,
                                    password: _enteredPassword);

                            print(credential);
                          }
                        },
                        child: Text(
                          '로그인',
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
                        const Text('계정이 없으신가요?'),
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          onPressed: () {},
                          child: const Text('회원가입'),
                        )
                      ],
                    ),
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
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                              'email': result.user.email,
                              'name': result.user.displayName,
                              'imageUrl':
                                  result.additionalUserInfo.profile['picture'],
                            });
                          } else {}
                          if (!mounted) {
                            return;
                          }
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) {
                              return const HomeScreen();
                            },
                          ));
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/icons/google.svg',
                        height: 50,
                        width: 50,
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
