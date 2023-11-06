import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/providers/user_provider.dart';
import 'package:running_mate/screens/my_page/edit_profile.dart';
import 'package:running_mate/services/auth_service.dart';
import 'package:running_mate/widgets/running_article/board_item.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen>
    with TickerProviderStateMixin {
  late Future<dynamic> _userInfo;
  late final TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userInfo = AuthService().getUserInfo(null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getMeetingHistories();
  }

  void _getMeetingHistories() async {
    final userId = ref.watch(userProvider)!.id;

    final collectionRef = _firestore.collection('articles');
    final myMeetssnapshot =
        await collectionRef.where('user', isEqualTo: userId).get();
    final joinedMeets =
        await collectionRef.where('joinUesrIds', arrayContains: userId).get();

    ref
        .read(meetingArticleProvider.notifier)
        .addMyMeetings(myMeetssnapshot.docs);
    ref
        .read(meetingArticleProvider.notifier)
        .addJoinedMeetings(joinedMeets.docs);
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
    final myMeets = ref.watch(meetingArticleProvider).myMeets;
    final joinedMeets = ref.watch(meetingArticleProvider).joinedMeets;
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
                        checkUrl(user!.imageUrl!),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          user.name,
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
                            _editProfilePage(user);
                          },
                          child: Text(
                            '프로필 수정',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: '참여 목록'),
                        Tab(text: '개설 목록'),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ListView.builder(
                            itemCount: joinedMeets.length,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    BoardItem(article: joinedMeets[index])
                                  ],
                                );
                              }
                              return BoardItem(article: joinedMeets[index]);
                            },
                          ),
                          ListView.builder(
                            itemCount: myMeets.length,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    BoardItem(article: myMeets[index])
                                  ],
                                );
                              }
                              return BoardItem(article: myMeets[index]);
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          return content;
        });
  }
}
