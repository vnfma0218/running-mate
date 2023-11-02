import 'package:flutter/material.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/screens/article_detail.dart';

class BoardItem extends StatefulWidget {
  const BoardItem({super.key, required this.article});
  final MeetingArticle article;

  @override
  State<BoardItem> createState() => _BoardItemState();
}

class _BoardItemState extends State<BoardItem> {
  bool _isButtonTapped = false;

  void _onTapArticle(BuildContext context) async {
    if (!_isButtonTapped) {
      _isButtonTapped = true; // make it true when clicked

      if (context.mounted) {
        _moveDetailPage(context);
        _isButtonTapped = false;
      }
    }
  }

  void _moveDetailPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          article: widget.article,
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
                        widget.article.time,
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
                          widget.article.title,
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
