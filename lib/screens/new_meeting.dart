import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/screens/map.dart';
import 'package:running_mate/widgets/ui_elements/input_label.dart';
import 'package:http/http.dart' as http;

class NewMeetingScreen extends ConsumerStatefulWidget {
  const NewMeetingScreen({super.key});

  @override
  ConsumerState<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends ConsumerState<NewMeetingScreen> {
  var isUpdating = false;
  final _formKey = GlobalKey<FormState>();

  final locTextController = TextEditingController();
  final timeTextController = TextEditingController();
  final dateTextController = TextEditingController();
  var _isNoLimited = false;
  var _enteredTitle = '';
  var _enteredDistance = '';
  var _enteredNumOfPeople = '';
  var _enteredDesc = '';
  var _formattedAddress = '';

  TimeOfDay? _enteredTimeOfDay;
  Timestamp? _createdAt;
  String? articleId;

  TimeOfDay _selectedTime = TimeOfDay.now();
  LatLng? _selectedCoords;
  DateTime? meetDatetime;

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
        _enteredTimeOfDay =
            TimeOfDay.fromDateTime(updatingArticle.meetDatetime!);
        isUpdating = true;
        meetDatetime = updatingArticle.meetDatetime!;
        articleId = updatingArticle.id;
        _enteredTitle = updatingArticle.title;
        _enteredDesc = updatingArticle.desc;
        _enteredDistance = updatingArticle.distance.toString();
        locTextController.text = updatingArticle.address!.title;
        timeTextController.text = updatingArticle.time;
        dateTextController.text = updatingArticle.date;
        _createdAt = updatingArticle.createdAt;
        _isNoLimited = updatingArticle.limitPeople == null;
        _enteredNumOfPeople = updatingArticle.limitPeople == null
            ? ''
            : updatingArticle.limitPeople.toString();
        _selectedCoords =
            LatLng(updatingArticle.address!.lat, updatingArticle.address!.lng);
      });
    }
  }

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
    _formattedAddress = await _getPlaceAddress(
        _selectedCoords!.latitude, _selectedCoords!.longitude);

    locTextController.text = result['text'];
  }

  Future<String> _getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${dotenv.env['google_api_key']}&language=ko');
    final response = await http.get(url);
    return jsonDecode(response.body)['results'][0]['formatted_address'];
  }

  void _onCreateArticle() async {
    if (_formKey.currentState!.validate() && _selectedCoords != null) {
      final date = dateTextController.text.split('-');
      _formKey.currentState!.save();
      _loading = true;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final authencatiedUser = FirebaseAuth.instance.currentUser!;
      DocumentReference docRef =
          firestore.collection('articles').doc(isUpdating ? articleId : null);
      await docRef.set(
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
          "joinUsers": null,
          "distance": _enteredDistance,
          "limitPeople": _isNoLimited ? '' : _enteredNumOfPeople,
          "createdAt": !isUpdating ? FieldValue.serverTimestamp() : _createdAt,
          "updatedAt": isUpdating ? FieldValue.serverTimestamp() : null,
          "timeStampDate": Timestamp.fromDate(DateTime(
              int.parse(date[0]),
              int.parse(date[1]),
              int.parse(date[2]),
              _enteredTimeOfDay!.hour,
              _enteredTimeOfDay!.minute)),
          "date": dateTextController.text,
          "time": timeTextController.text,
        },
      );

      _loading = false;
      if (!mounted) {
        return;
      }

      MeetingArticle article = MeetingArticle(
        id: articleId ?? docRef.id,
        title: _enteredTitle,
        desc: _enteredDesc,
        user: authencatiedUser.uid,
        date: dateTextController.text,
        time: timeTextController.text,
        distance: int.parse(_enteredDistance),
        limitPeople: _enteredNumOfPeople.isNotEmpty
            ? int.parse(_enteredNumOfPeople)
            : null,
        createdAt: Timestamp.fromDate(DateTime.now()),
        meetDatetime: meetDatetime ??
            DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]),
                _enteredTimeOfDay!.hour, _enteredTimeOfDay!.minute),
        address: Address(
          formattedAddress: '',
          title: locTextController.text,
          lat: _selectedCoords!.latitude,
          lng: _selectedCoords!.longitude,
        ),
      );
      if (isUpdating) {
        ref.read(meetingArticleProvider.notifier).addUpdateArticle(article);
      } else {
        ref.read(meetingArticleProvider.notifier).addCreatedArticle(article);
      }
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
        title: Text(!isUpdating ? '등록' : '게시글 수정'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
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
                  ),
          ),
        ),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 9, top: 10),
                            child: InputLabel(text: '거리 '),
                          ),
                          TextFormField(
                            initialValue: _enteredDistance,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Text('km'),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '거리를 입력해주세요';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredDistance = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const InputLabel(text: '인원'),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.zero,
                                child: Checkbox(
                                    value: _isNoLimited,
                                    onChanged: (val) {
                                      setState(() {
                                        _isNoLimited = val!;
                                      });
                                    }),
                              ),
                              const Text('제한 없음')
                            ],
                          ),
                          TextFormField(
                            enabled: _isNoLimited ? false : true,
                            initialValue: _enteredNumOfPeople,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Text('명'),
                              ),
                            ),
                            validator: (value) {
                              if (_isNoLimited) {
                                return null;
                              }
                              if (value == null || value.isEmpty) {
                                return '인원 입력해주세요';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredNumOfPeople = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const InputLabel(text: '자세한 설명'),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: _enteredDesc,
                  maxLength: 200,
                  maxLines: 6,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: _enteredDesc.isNotEmpty ? 15 : 30.0,
                      horizontal: 10.0,
                    ),
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
                  onChanged: (val) {
                    setState(() {
                      _enteredDesc = val;
                    });
                  },
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
                const InputLabel(text: '일시'),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: dateTextController,
                        onTap: () async {
                          DateTime now = DateTime.now();
                          DateTime week = now.add(const Duration(days: 7));

                          var date = await showDatePicker(
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: week,
                            helpText: '날짜는 일주일 내에서 선택할 수 있습니다.',
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
                            _enteredTimeOfDay = timeOfDay;
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
                const SizedBox(
                  height: 10,
                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
