import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/providers/article_provider.dart';
import 'package:running_mate/screens/new_article.dart';
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
  const ArticleDetailScreen(
      {super.key, required this.article, required this.user});

  final MeetingArticle article;
  final UserModel user;

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  List<Marker> _markers = [];
  late MeetingArticle _article;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
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
    print('------------_onMapCreated from article detail screen------------');
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
    ref.read(meetingArticleProvider.notifier).addUpdateArticle(widget.article);

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

    ref.watch(meetingArticleProvider.notifier).resetUpdatingArticle();

    // widget.article =
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('참여 인원'),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserAvatar(userName: 'name'),
                      SizedBox(
                        width: 20,
                      ),
                      UserAvatar(userName: '유저명'),
                      SizedBox(
                        width: 20,
                      ),
                      UserAvatar(userName: '유저명유저명유저명'),
                    ],
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButton(
              icon: const Icon(Icons.more_vert),
              underline: const SizedBox.shrink(),
              items: dropDownList.map<DropdownMenuItem<String>>((String value) {
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
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: widget.user.imageUrl != null
                            ? Image.network(
                                widget.user.imageUrl!,
                                width: 35,
                              )
                            : const Icon(Icons.person),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.user.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _selectUserList,
                        child: SizedBox(
                          height: 24,
                          width: 24 * 1.7,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_circle_rounded,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_circle_sharp,
                                  ),
                                ),
                              ),
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
