import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/providers/user_provider.dart';
import 'package:running_mate/screens/new_meeting.dart';
import 'package:running_mate/services/auth_service.dart';
import 'package:running_mate/services/util_service.dart';
import 'package:running_mate/widgets/google_map.dart';
import 'package:running_mate/widgets/running_article/user_avatar.dart';
import 'package:running_mate/widgets/ui_elements/alert_dialog.dart';

enum ReportEnum {
  sexualContent('성적 컨텐츠', 'sexual'),
  abuseContent('욕설 컨텐츠', 'abuse'),
  marketingContent('홍보 컨텐츠', 'marketing'),
  etc('기타 부적절 컨텐츠', 'etc');

  const ReportEnum(this.label, this.value);

  final String label;
  final String value;
}

final Map<String, String> mineDropdownList = {
  '게시글 수정': 'update',
  '삭제': 'delete',
};
final Map<String, String> dropDownList = {
  '신고하기': 'report',
  // '공유하기': 'share',
};

class ArticleDetailScreen extends ConsumerStatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  final String articleId;

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  List<Marker> _markers = [];
  late bool _isMine = false;
  late bool _isJoined = false;
  late MeetingArticle _article;
  late GoogleMapController mapController;
  UserModel? _user;
  ReportEnum? _reportStatus;

  @override
  void initState() {
    super.initState();
  }

  void _getUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final userDetail = await AuthService().getUserInfo(_article.user);
    setState(() {
      if (currentUser == null) {
        _isMine = false;
      } else {
        _isMine = currentUser.uid == _article.user;
        if (_article.joinUsers != null) {
          _isJoined = _article.joinUsers!
              .where((id) => id == currentUser.uid)
              .isNotEmpty;
        }
      }
      _user = UserModel(
        id: userDetail['email'],
        email: userDetail['email'],
        imageUrl: userDetail['imageUrl'],
        name: userDetail['name'],
      );
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final marker = await _createMarker();
    setState(() {
      _markers.add(marker);
    });
  }

  _createMarker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/location_pin.png', 150);

    return Marker(
      icon: BitmapDescriptor.fromBytes(markerIcon),
      markerId: const MarkerId('1'),
      position: LatLng(_article.address!.lat, _article.address!.lng),
    );
  }

  void _reLocateCameraPos() async {
    mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(_article.address!.lat, _article.address!.lng),
      ),
    );
    final marker = await _createMarker();

    setState(() {
      _markers = [];
      _markers.add(marker);
    });
  }

  void _onUpdateArticle() async {
    ref.read(meetingArticleProvider.notifier).addUpdateArticle(_article);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const NewMeetingScreen();
      },
    ));
    ref.invalidate(articleDetailProvider);
    ref.read(meetingArticleProvider.notifier).resetUpdatingArticle();

    // _reLocateCameraPos();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialogWidget(
          title: '게시글 삭제',
          content: '삭제하시겠습니까?',
          confirmBtnText: '삭제',
          confirmCb: () => _onDeleteArticle(context),
        );
      },
    );
  }

  void _showReportDialog() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          ReportEnum? reportStatus;
          return StatefulBuilder(
            builder: (context, stfSetState) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 15),
                      const Text(
                        '게시글 신고',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ...ReportEnum.values.map(
                        (e) => ListTile(
                          title: Text(e.label),
                          leading: Radio<ReportEnum>(
                            value: e,
                            groupValue: reportStatus,
                            onChanged: (ReportEnum? value) {
                              stfSetState(() {
                                reportStatus = value;
                              });
                              setState(() {
                                _reportStatus = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('취소')),
                          TextButton(
                              onPressed:
                                  reportStatus == null ? null : _reportArticle,
                              child: const Text('신고'))
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void _onRunningDetailDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RunningDetailRow(label: '일자', text: _article.date),
                const Divider(thickness: 1, height: 25),
                RunningDetailRow(label: '시간', text: _article.time),
                const Divider(thickness: 1, height: 25),
                RunningDetailRow(
                    label: '예상 거리', text: '${_article.distance.toString()}km'),
                const Divider(thickness: 1, height: 25),
                RunningDetailRow(
                  label: '최대 인원',
                  text: _article.limitPeople == null
                      ? '제한 없음'
                      : '${_article.limitPeople.toString()}명',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _reportArticle() async {
    final db = FirebaseFirestore.instance;

    db
        .collection("reports")
        .where('articleId', isEqualTo: widget.articleId)
        .get()
        .then(
      (querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          for (var docSnapshot in querySnapshot.docs) {
            final report = Report.fromFirestore(docSnapshot, null);
            final prevCount = report.count;
            prevCount[_reportStatus!.name] =
                prevCount[_reportStatus!.name]! + 1;
            await db
                .collection('reports')
                .doc(report.id)
                .update({"count": prevCount});
          }
        } else {
          final Map<String, num> report = {};
          for (var entry in ReportEnum.values) {
            report.addAll({entry.name: 0});
          }
          report[_reportStatus!.name] = 1;
          await db.collection('reports').doc().set({
            "articleId": widget.articleId,
            "createdAt": FieldValue.serverTimestamp(),
            "count": report,
          });
        }
      },
    );

    _onSnackbarMessage(
      message: '신고해주셔서 감사합니다.',
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _onSnackbarMessage({required String message, int duration = 1200}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: duration),
        content: Text(message),
      ),
    );
  }

  void _onDeleteArticle(BuildContext ctx) async {
    await FirebaseFirestore.instance
        .collection('articles')
        .doc(widget.articleId)
        .delete();

    if (!mounted) {
      return;
    }
    final articles = ref.watch(meetingArticleProvider).articleList;

    ref
        .read(meetingArticleProvider.notifier)
        .deleteArticle(articles.indexWhere((a) => a.id == widget.articleId));
    Navigator.of(ctx).pop();
    Navigator.of(context).pop();
  }

  void _selectUserList() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 130,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('참여 인원'),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _article.joinPeople!
                      .map((e) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              UserAvatar(
                                imageUrl: e.imageUrl,
                                name: e.name,
                              ),
                              const SizedBox(
                                width: 8,
                              )
                            ],
                          ))
                      .toList(),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  get getTimeDifference {
    return UtilService().formatDate(_article.createdAt!.toDate());
  }

  void _toggleJoin() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialogWidget(
          title: _isJoined ? '참여 취소' : '참여',
          content: _isJoined ? "참여를 취소하시겠습니까?" : '참여하시겠습니까?',
          confirmBtnText: '확인',
          confirmCb: () async {
            final curUser = ref.watch(userProvider);
            List<String> joinUsers = [];

            if (_article.joinUsers != null) {
              joinUsers = [..._article.joinUsers!];
            }
            if (!_isJoined) {
              joinUsers.add(curUser!.id);
            }
            if (_isJoined) {
              joinUsers.removeWhere((id) => id == curUser!.id);
            }

            await FirebaseFirestore.instance
                .collection('articles')
                .doc(_article.id)
                .update({"joinUsers": joinUsers}).then(
              (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content:
                        Text(_isJoined ? '참여가 취소되었습니다' : '참여신청이 완료 되었습니다.'),
                  ),
                );
              },
            );
            setState(() {
              _isJoined = !_isJoined;
              var editedUsers = [..._article.joinPeople!];
              if (!_isJoined) {
                editedUsers.removeWhere((element) => element.id == curUser!.id);
              } else {
                editedUsers.add(
                  JoinUserModel(
                      id: curUser!.id,
                      name: curUser.name,
                      imageUrl: curUser.imageUrl!),
                );
              }
              _article.joinPeople = editedUsers;
            });
            if (!mounted) {
              return;
            }

            ref
                .read(meetingArticleProvider.notifier)
                .updateArticleList(_article);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final articleDetail =
        ref.watch(articleDetailProvider((id: widget.articleId)));
    final dropDownMenus = _isMine ? mineDropdownList : dropDownList;
    return Scaffold(
        appBar: AppBar(
          actions: [
            DropdownButton(
                icon: const Icon(Icons.more_vert),
                underline: const SizedBox.shrink(),
                items: dropDownMenus.entries
                    .map<DropdownMenuItem<String>>(
                      (MapEntry<String, String> entry) =>
                          DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == 'update') {
                    if (_article.joinUsers != null &&
                        _article.joinUsers!.isNotEmpty) {
                      _onSnackbarMessage(
                        message: '참여인원이 있어 수정할 수 없습니다.',
                      );
                    } else {
                      _onUpdateArticle();
                    }
                  }

                  if (value == 'delete') {
                    _showDeleteDialog();
                  }
                  if (value == 'report') {
                    _showReportDialog();
                  }
                }),
          ],
        ),
        bottomNavigationBar: !_isMine
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 26),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: _toggleJoin,
                    child: Text(
                      _isJoined ? '참여 취소' : '참여 하기',
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        body: articleDetail.when(
          data: (data) {
            _article = data;
            if (_article.user.isNotEmpty && _user == null) {
              _getUserInfo();
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: GoogleMapWidget(
                      center: LatLng(
                        _article.address!.lat,
                        _article.address!.lng,
                      ),
                      markers: _markers.toSet(),
                      onMapCreated: _onMapCreated,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_user != null)
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: _user != null
                                    ? Image.network(
                                        fit: BoxFit.cover,
                                        _user!.imageUrl!,
                                        width: 35,
                                        height: 35,
                                      )
                                    : const Icon(Icons.person),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                _user!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (data.joinPeople != null)
                                GestureDetector(
                                  onTap: _selectUserList,
                                  child: SizedBox(
                                    height: 24,
                                    width: 24 * 1.7,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        for (var i = 0;
                                            i < data.joinPeople!.length;
                                            i++)
                                          Positioned(
                                            left: i * 15,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                    child: Image.network(
                                                      data.joinPeople![i]
                                                          .imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: 25,
                                                      height: 25,
                                                    ),
                                                  )),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1.0)),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.6,
                              child: Text(
                                _article.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                                onPressed: _onRunningDetailDialog,
                                child: const Text('상세정보'))
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(getTimeDifference),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          _article.desc,
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return const Center(
              child: Text('Uh oh. Something went wrong!'),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}

class RunningDetailRow extends StatelessWidget {
  const RunningDetailRow({super.key, required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const Spacer(),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
