import 'package:flutter/material.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/screens/article_detail.dart';
import 'package:running_mate/services/auth_service.dart';

class BoardItem extends StatelessWidget {
  const BoardItem({super.key, required this.article});
  final MeetingArticle article;

  void _onTapArticle(BuildContext context) async {
    final userDetail = await AuthService().getUserInfo(article.user);
    final user = UserModel(
      id: userDetail['email'],
      email: userDetail['email'],
      imageUrl: userDetail['imageUrl'],
      name: userDetail['name'],
    );
    if (context.mounted) {
      _moveDetailPage(user, context);
    }
  }

  void _moveDetailPage(UserModel user, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          article: article,
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTapArticle(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        article.time,
                      ),
                      Text(
                        '(오늘)',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            // fontSize:
                            ),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    width: 20,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          article.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Row(
                          children: [
                            Text('10km'),
                          ],
                        ),
                        const Text('서울특별시 영등포구')
                      ],
                    ),
                  ),
                  // const Spacer(),
                  const Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
