import 'package:flutter/material.dart';

class InputLabel extends StatelessWidget {
  const InputLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
