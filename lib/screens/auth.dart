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
  var _enteredEmail;
  var _enteredPassword;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
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
                child: Column(
              children: [
                TextFormField(
                  maxLength: 30,
                  decoration: InputDecoration(
                    label: const Text('Email'),
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
                  decoration: InputDecoration(
                    label: const Text('Password'),
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
                    _enteredEmail = value;
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
                    onPressed: () {},
                    child: Text(
                      '로그인',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  )),
                  label: const Text('구글 로그인'),
                  onPressed: () async {
                    final result = await AuthService().signInWithGoogle();
                    final user = FirebaseAuth.instance.currentUser;
                    print('------------------login------------------------');
                    if (result.user.email != null) {
                      final userDetail =
                          await AuthService().getUserInfo(user!.uid);
                      if (userDetail['email'] == null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                          'email': result.user.email,
                          'name': result.user.displayName,
                          'imageUrl':
                              result.additionalUserInfo.profile['picture'],
                        });
                      } else {
                        if (!mounted) {
                          return;
                        }
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return const HomeScreen();
                          },
                        ));
                      }
                    }
                  },
                  icon: SvgPicture.asset(
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
