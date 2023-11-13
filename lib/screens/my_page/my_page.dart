import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/providers/user_provider.dart';
import 'package:running_mate/screens/my_page/edit_profile.dart';
import 'package:running_mate/screens/my_page/meet_histories.dart';
import 'package:running_mate/screens/my_page/record_histories.dart';
import 'package:running_mate/services/auth_service.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
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
    final user = ref.watch(userProvider);

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
            content = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      checkUrl(user!.imageUrl!),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        user.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(),
                        ),
                        onPressed: () {
                          _editProfilePage(user);
                        },
                        child: Text(
                          '프로필 수정',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MeetHistoriesScreen(),
                      ));
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.run_circle_outlined,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '모임 목록',
                          style: Theme.of(context).textTheme.bodyLarge!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RecordHistoriesScreen(),
                      ));
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '기록 관리',
                          style: Theme.of(context).textTheme.bodyLarge!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RecordHistoriesScreen(),
                      ));
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mail_outlined,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '공지사항',
                          style: Theme.of(context).textTheme.bodyLarge!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return content;
        });
  }
}
