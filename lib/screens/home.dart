import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:running_mate/screens/article_list.dart';
import 'package:running_mate/screens/auth.dart';
import 'package:running_mate/screens/my_page/my_page.dart';
import 'package:running_mate/screens/new_article.dart';
import 'package:running_mate/services/auth_service.dart';
import 'package:running_mate/widgets/bottom_nav_bar.dart';
import 'package:running_mate/widgets/ui_elements/alert_dialog.dart';

const myPageDropDownInfo = [
  {"text": '로그아웃', "value": 'logout'},
  {"text": '설정', "value": 'setting'},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _children = [
    {"widget": const ArticleListScreen(), "title": 'Today\'s Run'},
    {"widget": const ArticleListScreen(), "title": '기록'},
    {"widget": const MyPageScreen(), "title": '프로필'}
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNewArticle(BuildContext context) {
    print(AuthService().getUserInfo(null));
    if (AuthService().isLoggedIn()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return const NewArticleScreen();
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
        appBar: AppBar(
          title: Text(
            _children[_selectedIndex]['title'],
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text('지도로 보기'),
                      Icon(
                        Icons.map,
                      )
                    ],
                  ),
                ),
              ),
            if (_selectedIndex == 2)
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
                  onChanged: (value) {
                    if (value == 'logout') {
                      print('로그아웃 하기');
                      FirebaseAuth.instance.signOut();
                      setState(() {
                        _selectedIndex = 0;
                      });
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ));
                    }
                  }),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () => _onNewArticle(context),
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
