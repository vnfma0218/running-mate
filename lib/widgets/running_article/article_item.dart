import 'package:flutter/material.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/screens/article_detail.dart';
import 'package:running_mate/services/auth_service.dart';

class ArticleItem extends StatefulWidget {
  const ArticleItem({super.key, required this.article});

  final MettingArticle article;

  @override
  State<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  String get locationImage {
    final lat = widget.article.address.lat;
    final lng = widget.article.address.lng;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$lat,$lng&key=AIzaSyCcwCS4yhhju8hHNvv17aOTEhhuh69l-tw';
    // return 'https://images.unsplash.com/photo-1486218119243-13883505764c?auto=format&fit=crop&q=60&w=800&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8cnVubmluZ3xlbnwwfHwwfHx8MA%3D%3D';
  }

  void _onTapArticle(BuildContext context) async {
    final userDetail = await AuthService().getUserInfo(widget.article.user);
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ArticleDetailScreen(
        article: widget.article,
        user: User(
            email: userDetail['email'],
            imageUrl: userDetail['imageUrl'],
            name: userDetail['name']),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => _onTapArticle(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              locationImage,
              width: screenWidth * 0.45,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    widget.article.address.name,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
