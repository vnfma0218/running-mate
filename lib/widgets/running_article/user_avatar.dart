import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.person,
          size: 30,
        ),
      ],
    );
  }
}
