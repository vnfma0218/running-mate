import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar(
      {super.key, required this.onSelectPage, required this.selectedIdx});
  final void Function(int selectIdx) onSelectPage;
  final int selectedIdx;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.circle),
          label: '러닝모임',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stacked_bar_chart_outlined),
          label: '기록',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_rounded),
          label: '채팅',
        ),
      ],
      currentIndex: selectedIdx,
      selectedItemColor: Colors.amber[800],
      onTap: onSelectPage,
    );
  }
}
