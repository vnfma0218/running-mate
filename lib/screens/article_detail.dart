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
import 'package:running_mate/screens/new_article.dart';
import 'package:running_mate/services/auth_service.dart';
import 'package:running_mate/services/util_service.dart';
import 'package:running_mate/widgets/google_map.dart';
import 'package:running_mate/widgets/running_article/user_avatar.dart';
import 'package:running_mate/widgets/ui_elements/alert_dialog.dart';

const mapDropDownList = {
  "게시글 수정": "update",
  "삭제": "delete",
};

const List<String> dropDownList = <String>[
  '게시글 수정',
  '삭제',
];

class ArticleDetailScreen extends ConsumerStatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  final MeetingArticle article;

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
  String? currentUserId;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _getUserInfo();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _isMine = false;
    } else {
      currentUserId = currentUser.uid;
      _isMine = currentUserId == _article.user;
      if (_article.joinPeople != null) {
        _isJoined = _article.joinPeople!
            .where((element) => element.id == currentUserId)
            .isNotEmpty;
      }
    }
  }

  void _getUserInfo() async {
    final userDetail = await AuthService().getUserInfo(_article.user);
    setState(() {
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
        return const NewArticleScreen();
      },
    ));

    final updatedArticle = ref.read(meetingArticleProvider).updateArticle;
    setState(() {
      _article = updatedArticle;
    });
    _reLocateCameraPos();
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

  void _onDeleteArticle(BuildContext ctx) async {
    await FirebaseFirestore.instance
        .collection('articles')
        .doc(widget.article.id)
        .delete();

    if (!mounted) {
      return;
    }
    final articles = ref.watch(meetingArticleProvider).articleList;

    ref
        .read(meetingArticleProvider.notifier)
        .deleteArticle(articles.indexWhere((a) => a.id == widget.article.id));
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('참여 인원'),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Row(
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
                                  width: 20,
                                )
                              ],
                            ))
                        .toList(),
                  ),
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

            JoinUserModel joinUser = JoinUserModel(
                id: curUser!.id,
                name: curUser.name,
                imageUrl: curUser.imageUrl!);
            List<JoinUserModel> joinPeople = [];
            List<String> joinUesrIds = [];

            if (_article.joinPeople != null) {
              joinPeople = [..._article.joinPeople!];
            }
            if (!_isJoined) {
              joinPeople.add(joinUser);
            }
            if (_isJoined) {
              joinPeople.removeWhere((element) => element.id == joinUser.id);
            }

            final usersJson = joinPeople.map((e) => e.toJson()).toList();
            joinUesrIds = joinPeople.map((e) => e.id).toList();
            await FirebaseFirestore.instance
                .collection('articles')
                .doc(_article.id)
                .update(
                    {"joinPeople": usersJson, "joinUesrIds": joinUesrIds}).then(
              (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(_isJoined ? '참여가 취소되었습니다' : '참여신청이 완료 되었습니다.'),
                  ),
                );
              },
            );
            setState(() {
              _isJoined = !_isJoined;
              _article.joinPeople = joinPeople;
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_isMine)
            DropdownButton(
                icon: const Icon(Icons.more_vert),
                underline: const SizedBox.shrink(),
                items:
                    dropDownList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (mapDropDownList[value] == 'update') {
                    _onUpdateArticle();
                  }
                  if (mapDropDownList[value] == 'delete') {
                    _showDeleteDialog();
                  }
                }),
        ],
      ),
      bottomNavigationBar: !_isMine
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 26),
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
      body: SingleChildScrollView(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
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
                                  _user!.imageUrl!,
                                  width: 35,
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
                        if (_article.joinPeople != null)
                          GestureDetector(
                            onTap: _selectUserList,
                            child: SizedBox(
                              height: 24,
                              width: 24 * 1.7,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  for (var i = 0;
                                      i < _article.joinPeople!.length;
                                      i++)
                                    Positioned(
                                      left: i * 20,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.network(
                                              _article.joinPeople![i].imageUrl,
                                              width: 25,
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
                          bottom: BorderSide(color: Colors.grey, width: 1.0)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: Text(
                      _article.title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
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
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
