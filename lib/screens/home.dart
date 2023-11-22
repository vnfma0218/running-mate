import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/providers/user_provider.dart';
import 'package:running_mate/screens/article_list.dart';
import 'package:running_mate/screens/auth/login.dart';
import 'package:running_mate/screens/calendar/event_calendar.dart';
import 'package:running_mate/screens/my_page/my_page.dart';
import 'package:running_mate/screens/new_meeting.dart';
import 'package:running_mate/services/auth_service.dart';
import 'package:running_mate/widgets/bottom_nav_bar.dart';
import 'package:running_mate/widgets/ui_elements/alert_dialog.dart';

const myPageDropDownInfo = [
  {"text": '로그아웃', "value": 'logout'},
  // {"text": '설정', "value": 'setting'},
];

enum PageType {
  articles(0, 'articles'),
  record(1, 'record'),
  mypage(2, 'mypage');

  const PageType(this.number, this.value);

  final int number;
  final String value;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _children = [
    {"widget": const ArticleListScreen(), "title": '러닝 모임'},
    {"widget": const EventCalendarScreen(), "title": '기록'},
    {"widget": const MyPageScreen(), "title": '프로필'}
  ];

  @override
  void initState() {
    super.initState();

    _setUserInfo();
  }

  void _setUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final user = await AuthService().getUserInfo(null);
      UserModel userModel = UserModel(
          id: user['id'],
          name: user['name'],
          imageUrl: user['imageUrl'],
          email: user['email']);
      ref.read(userProvider.notifier).setUserInfo(userModel);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNewArticle(BuildContext context) {
    if (AuthService().isLoggedIn()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return const NewMeetingScreen();
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialogWidget(
            title: '게시글 작성',
            content: '로그인이 필요한 서비스입니다. \n로그인 하시겠습니까?',
            confirmBtnText: '확인',
            confirmCb: () => {
              Navigator.of(context).pop(),
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              ),
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _selectedIndex != PageType.record.number
            ? AppBar(
                title: Text(
                  _children[_selectedIndex]['title'],
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                actions: [
                  // if (_selectedIndex == PageType.articles.number)
                  //   Padding(
                  //     padding: const EdgeInsets.only(right: 10),
                  //     child: GestureDetector(
                  //       onTap: () {},
                  //       child: const Row(
                  //         children: [
                  //           Text('지도로 보기'),
                  //           Icon(
                  //             Icons.map,
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  if (_selectedIndex == PageType.mypage.number)
                    DropdownButton(
                        icon: const Icon(Icons.more_vert),
                        underline: const SizedBox.shrink(),
                        items: [
                          for (Map<String, String> item in myPageDropDownInfo)
                            DropdownMenuItem<String>(
                              value: item['value'],
                              child: Text(item['text']!),
                            )
                        ],
                        onChanged: (value) async {
                          if (value == 'logout') {
                            await FirebaseAuth.instance.signOut();
                            // setState(() {
                            //   _selectedIndex = 0;
                            // });
                            if (!mounted) {
                              return;
                            }
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => const AuthScreen(),
                            ));
                          }
                        }),
                ],
              )
            : null,
        floatingActionButton: _selectedIndex == PageType.articles.number
            ? FloatingActionButton(
                onPressed: () {
                  if (_selectedIndex == PageType.articles.number) {
                    _onNewArticle(context);
                  }
                },
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: BottomNavBar(
          onSelectPage: _onItemTapped,
          selectedIdx: _selectedIndex,
        ),
        body: _children[_selectedIndex]['widget']);
  }
}
