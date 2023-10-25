import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running_mate/screens/map.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';

class NewArticleScreen extends StatefulWidget {
  const NewArticleScreen({super.key});

  @override
  State<NewArticleScreen> createState() => _NewArticleScreenState();
}

class _NewArticleScreenState extends State<NewArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final locTextController = TextEditingController();
  final timeTextController = TextEditingController();
  final dateTextController = TextEditingController();
  var _enteredTitle = '';
  var _enteredDesc = '';
  TimeOfDay _selectedTime = TimeOfDay.now();
  LatLng? _selectedCoords;

  var _loading = false;

  void onTabLocationField() async {
    final Map<String, dynamic>? result =
        await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return MapScreen(
          coords: _selectedCoords,
          prevLocName: locTextController.text,
        );
      },
    ));

    if (result == null) {
      return;
    }
    _selectedCoords = result['coords'];
    locTextController.text = result['text'];
  }

  void _onCreateArticle() async {
    if (_formKey.currentState!.validate() && _selectedCoords != null) {
      _formKey.currentState!.save();
      _loading = true;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final authencatiedUser = FirebaseAuth.instance.currentUser!;
      await firestore.collection("articles").doc().set(
        {
          "user": authencatiedUser.uid,
          "title": _enteredTitle,
          "desc": _enteredDesc,
          "location": {
            "name": locTextController.text,
            "lat": _selectedCoords?.latitude,
            "lng": _selectedCoords?.longitude,
          },
          "createdAt": FieldValue.serverTimestamp(),
          "date": dateTextController.text,
          "time": timeTextController.text,
        },
      );

      _loading = false;
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 런닝 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 800,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputLabel(text: '제목'),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  maxLength: 30,
                  decoration: InputDecoration(
                    label: const Text('제목'),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredTitle = value!;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const InputLabel(text: '자세한 설명'),
                TextFormField(
                  maxLength: 200,
                  maxLines: 6,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 10.0),
                    label: const Column(
                      children: [
                        Text(
                            '오늘 런닝할 장소에 대한 설명이나, 거리, 속도, 예상 소요시간 등의 내용을 작성해주세요.'),
                        Text(''),
                        Text('자세히 작성해줄 수록 알맞은 러닝메이트를 찾을 수 있어요.'),
                      ],
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 10) {
                      return '최소 10자 이상 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredDesc = value!;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                const InputLabel(text: '시간 (일시는 당일 기준)'),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: dateTextController,
                        onTap: () async {
                          DateTime now = DateTime.now();
                          DateTime tomorrow = now.add(const Duration(days: 1));

                          var date = await showDatePicker(
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: tomorrow,
                            helpText: '날짜는 다음날까지 선택할 수 있습니다.',
                          );

                          if (date != null) {
                            setState(() {
                              dateTextController.text =
                                  date.toLocal().toString().split(" ")[0];
                            });
                          }
                        },
                        decoration: InputDecoration(
                          label: const Text('일자 선택'),
                          suffixIcon: const Icon(Icons.chevron_right_rounded),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (_) {
                          final date = dateTextController.text;
                          if (date.isEmpty || date.trim().isEmpty) {
                            return '일자를 선택해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: timeTextController,
                        onTap: () async {
                          final TimeOfDay? timeOfDay = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (timeOfDay != null) {
                            setState(() {
                              _selectedTime = timeOfDay;
                              timeTextController.text =
                                  timeOfDay.format(context);
                            });
                          }
                        },
                        decoration: InputDecoration(
                          label: const Text('시간 선택'),
                          suffixIcon: const Icon(Icons.chevron_right_rounded),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (_) {
                          final date = timeTextController.text;
                          if (date.isEmpty || date.trim().isEmpty) {
                            return '시간 선택해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const InputLabel(text: '장소'),
                TextFormField(
                  readOnly: true,
                  controller: locTextController,
                  onTap: onTabLocationField,
                  decoration: InputDecoration(
                    label: const Text('장소 선택'),
                    suffixIcon: const Icon(Icons.chevron_right_rounded),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: !_loading ? _onCreateArticle : null,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text(
                              '작성 완료',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
