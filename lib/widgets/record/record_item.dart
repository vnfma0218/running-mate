import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_mate/constants/constant.dart';
import 'package:running_mate/models/record.dart';
import 'package:running_mate/providers/record_provider.dart';
import 'package:running_mate/widgets/ui_elements/alert_dialog.dart';

class RecordItem extends ConsumerWidget {
  const RecordItem(
      {super.key, required this.record, required this.onUpdateRecord});
  final RecordModel record;
  final Function(RecordModel record) onUpdateRecord;

  void _showMemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모'),
        content: SingleChildScrollView(child: Text(record.memo!)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(BuildContext context, WidgetRef ref) async {
    final resultCode =
        await ref.read(recordProvider.notifier).deleteRecord(record.id!);

    if (ResultCodeType.success.code == resultCode) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('삭제하였습니다.'),
          ),
        );
        ref.read(recordProvider.notifier).fetchCalendarRecords(null);
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialogWidget(
          title: '기록삭제',
          content: '기록을 삭제하시겠습니까?',
          confirmBtnText: '삭제',
          confirmCb: () {
            _deleteRecord(context, ref);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => onUpdateRecord(record),
              child: Text(
                '수정',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _showDeleteDialog(context, ref),
              child: Text(
                '삭제',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
            const SizedBox(width: 10)
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text('운동시간'),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.timer),
                        Text(
                            '${record.hour.toString()}시간 ${record.miniutes.toString()}분'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Text('거리'),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.line_axis_sharp),
                        Text('${record.distance.toString()}km'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                if (record.memo != null && record.memo!.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showMemoDialog(context),
                    child: const Column(
                      children: [
                        Text('메모'),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.article),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
