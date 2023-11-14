import 'package:flutter/material.dart';

class MyPageMenuItem extends StatelessWidget {
  const MyPageMenuItem(
      {super.key,
      required this.menuIcon,
      required this.menuName,
      required this.menuRouter});
  final Icon menuIcon;
  final String menuName;
  final Widget menuRouter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => menuRouter,
        ));
      },
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Row(
          children: [
            menuIcon,
            const SizedBox(width: 10),
            Text(
              menuName,
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
          ],
        ),
      ),
    );
  }
}
