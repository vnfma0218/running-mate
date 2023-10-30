import 'package:flutter/material.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/screens/my_page/edit_profile.dart';
import 'package:running_mate/services/auth_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Future<dynamic> _userInfo = AuthService().getUserInfo(null);

  @override
  build(BuildContext context) {
    return FutureBuilder(
        future: _userInfo,
        builder: (context, snapshot) {
          Widget content = const Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
          );
          if (snapshot.hasData) {
            content = SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            snapshot.data['imageUrl'],
                            width: 50,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          snapshot.data['name'],
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return EditProfileScreen(
                                user: User(
                                  id: snapshot.data['id'],
                                  email: snapshot.data['imageUrl'],
                                  imageUrl: snapshot.data['imageUrl'],
                                  name: snapshot.data['name'],
                                ),
                              );
                            }));
                          },
                          child: const Text('프로필 수정'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return content;
        });
  }
}
