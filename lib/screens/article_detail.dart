import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:running_mate/models/meeting_article.dart';
import 'package:running_mate/models/user.dart';
import 'package:running_mate/services/util_service.dart';
import 'package:running_mate/widgets/google_map.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen(
      {super.key, required this.article, required this.user});

  final MettingArticle article;
  final User user;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final List<Marker> _markers = [];

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
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/location_pin.png', 150);

    final marker = Marker(
      icon: BitmapDescriptor.fromBytes(markerIcon),
      markerId: const MarkerId('1'),
      position: LatLng(widget.article.address.lat, widget.article.address.lng),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  get getTimeDifference {
    return UtilService().formatDate(widget.article.createdAt.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMapWidget(
              center: LatLng(
                widget.article.address.lat,
                widget.article.address.lng,
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
                      child: Image.network(
                        widget.user.imageUrl,
                        width: 50,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.user.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.article.title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            '${widget.article.date} ${widget.article.time}'),
                      ),
                    )
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
                  widget.article.desc,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
