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
  late Future<dynamic> _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = AuthService().getUserInfo(null);
  }

  void _editProfilePage(UserModel user) async {
    final result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EditProfileScreen(user: user);
    }));

    if (result != null) {
      setState(() {
        _userInfo = AuthService().getUserInfo(null);
      });
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필을 수정했어요.'),
        ),
      );
    }
  }

  Widget checkUrl(String url) {
    try {
      return Image.network(
        url,
        height: 40.0,
        width: 40.0,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
      );
    } catch (e) {
      return const Icon(Icons.person);
    }
  }

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

          if (snapshot.connectionState != ConnectionState.waiting &&
              snapshot.hasData) {
            content = SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        checkUrl(snapshot.data['imageUrl']),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          snapshot.data['name'],
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () {
                            final user = UserModel(
                              id: snapshot.data['id'],
                              email: snapshot.data['email'],
                              imageUrl: snapshot.data['imageUrl'],
                              name: snapshot.data['name'],
                            );
                            _editProfilePage(user);
                          },
                          child: Text(
                            '프로필 수정',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
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
