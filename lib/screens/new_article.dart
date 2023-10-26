import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/screens/map.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';
import 'package:http/http.dart' as http;

class NewArticleScreen extends ConsumerStatefulWidget {
  const NewArticleScreen({super.key});

  @override
  ConsumerState<NewArticleScreen> createState() => _NewArticleScreenState();
}

class _NewArticleScreenState extends ConsumerState<NewArticleScreen> {
  var isUpdating = false;
  final _formKey = GlobalKey<FormState>();

  final locTextController = TextEditingController();
  final timeTextController = TextEditingController();
  final dateTextController = TextEditingController();
  var _enteredTitle = '';
  var _enteredDesc = '';
  var _formattedAddress = '';
  late String articleId;

  TimeOfDay _selectedTime = TimeOfDay.now();
  LatLng? _selectedCoords;

  var _loading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updatingArticle = ref.watch(meetingArticleProvider).updateArticle;
    if (updatingArticle.id.isNotEmpty) {
      setState(() {
        isUpdating = true;
        articleId = updatingArticle.id;
        _enteredTitle = updatingArticle.title;
        _enteredDesc = updatingArticle.desc;
        locTextController.text = updatingArticle.address!.title;
        timeTextController.text = updatingArticle.time;
        dateTextController.text = updatingArticle.date;
        _selectedCoords =
            LatLng(updatingArticle.address!.lat, updatingArticle.address!.lng);
      });
    }
  }

  void onTabLocationField() async {
    print('_selectedCoords: $_selectedCoords');
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
    // print(_selectedCoords.);
    _formattedAddress = await _getPlaceAddress(
        _selectedCoords!.latitude, _selectedCoords!.longitude);
    locTextController.text = result['text'];
  }

  Future<String> _getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${dotenv.env['google_api_key']}&language=ko');

    final response = await http.get(url);
    final addressComponents =
        jsonDecode(response.body)['results'][0]['address_components'] as List;
    // final locality = addressComponents.where(
    //   (element) => element.types.contains('locality'),
    // );
    print(addressComponents);
    print(
        'response : ${jsonDecode(response.body)['results'][0]['address_components']}');
    return jsonDecode(response.body)['results'][0]['formatted_address'];
  }

  void _onCreateArticle() async {
    if (_formKey.currentState!.validate() && _selectedCoords != null) {
      print('--------------게시글 등록 Or 수정---------');
      print('_formattedAddress:$_formattedAddress');
      _formKey.currentState!.save();
      _loading = true;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final authencatiedUser = FirebaseAuth.instance.currentUser!;
      await firestore
          .collection("articles")
          .doc(isUpdating ? articleId : null)
          .set(
        {
          "user": authencatiedUser.uid,
          "title": _enteredTitle,
          "desc": _enteredDesc,
          "location": {
            "formattedAddress": _formattedAddress,
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
      if (isUpdating) {
        ref
            .read(meetingArticleProvider.notifier)
            .addUpdateArticle(MeetingArticle(
              id: articleId,
              title: _enteredTitle,
              desc: _enteredDesc,
              user: authencatiedUser.uid,
              date: dateTextController.text,
              time: timeTextController.text,
              createdAt: Timestamp.fromDate(DateTime.now()),
              address: Address(
                formattedAddress: '',
                title: locTextController.text,
                lat: _selectedCoords!.latitude,
                lng: _selectedCoords!.longitude,
              ),
            ));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(!isUpdating ? '등록' : '게시글 수정'),
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
                  initialValue: _enteredTitle,
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
                  initialValue: _enteredDesc,
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
                          : Text(
                              !isUpdating ? '작성 완료' : '수정 완료',
                              style: const TextStyle(
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