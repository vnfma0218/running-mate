import 'package:flutter/material.dart';

class LocationBottomModal extends StatefulWidget {
  const LocationBottomModal({super.key, this.prevLocName});
  final String? prevLocName;

  @override
  State<LocationBottomModal> createState() => _LocationBottomModalState();
}

class _LocationBottomModalState extends State<LocationBottomModal> {
  var _enteredLocName = '';
  final controlller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prevLocName != null) {
      controlller.text = widget.prevLocName!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 300,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '선택한 곳의 장소명을 입력해주세요',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '예) 여의도공원 광장, 하늘공원 입구',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _enteredLocName = value;
                  });
                },
                controller: controlller,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                autofocus: true,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                onPressed: _enteredLocName.trim().isNotEmpty
                    ? () => Navigator.pop(
                          context,
                          controlller.text,
                        )
                    : null,
                child: Text(
                  '장소 등록 완료',
                  style: TextStyle(
                    fontSize: 20,
                    color: _enteredLocName.trim().isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
