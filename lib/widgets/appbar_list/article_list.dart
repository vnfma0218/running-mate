import 'package:flutter/material.dart';

class ArticleListAppbar extends StatelessWidget {
  const ArticleListAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('투데이런'),
      actions: [
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
        )
      ],
    );
  }
}
