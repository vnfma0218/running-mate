import 'package:flutter/material.dart';

class RecordItem extends StatelessWidget {
  const RecordItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(
            children: [
              Text('운동시간'),
              Row(
                children: [
                  Icon(Icons.timer),
                  Text('1시간'),
                ],
              ),
            ],
          ),
          SizedBox(width: 20),
          Column(
            children: [
              Text('거리'),
              Row(
                children: [
                  Icon(Icons.line_axis_sharp),
                  Text('9.87km'),
                ],
              ),
            ],
          ),
          SizedBox(width: 20),
          Column(
            children: [
              Text('평균 페이스'),
              Row(
                children: [
                  Icon(Icons.run_circle),
                  Text('5분'),
                ],
              ),
            ],
          ),
        ]),
      ),
      // child: ListTile(
      //   leading: Row(
      //     children: [
      //       Icon(Icons.timer),
      //       Text('1시간'),
      //     ],
      //   ),
      //   title: Row(
      //     children: [
      //       Icon(Icons.line_axis_sharp),
      //       Text('9.87km'),
      //     ],
      //   ),
      //   trailing: Row(
      //     children: [
      //       Icon(Icons.run_circle),
      //       Text('5분10초'),
      //     ],
      //   ),
      // ),
    );
  }
}
