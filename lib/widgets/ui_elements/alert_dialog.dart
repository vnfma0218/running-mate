import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
  const AlertDialogWidget(
      {super.key,
      required this.title,
      required this.content,
      this.confirmCb,
      this.confirmBtnText});
  final String title;
  final String content;
  final String? confirmBtnText;
  final void Function()? confirmCb;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: Text(confirmBtnText == null ? '확인' : '취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (confirmCb != null)
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: confirmCb,
            child: Text(confirmBtnText ?? '확인'),
          ),
      ],
    );
  }
}
