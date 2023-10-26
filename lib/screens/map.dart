import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:running_mate/widgets/google_map.dart';
import 'package:running_mate/widgets/location_bottom_modal.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.coords, this.prevLocName});

  final LatLng? coords;
  final String? prevLocName;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final List<Marker> _markers = [];
  var isMapMoved = false;

  late LatLng _center = const LatLng(37.525967411259835, 126.92247283324362);

  @override
  void initState() {
    print('widget.coords: ${widget.coords}');
    if (widget.coords != null) {
      _center = widget.coords!;
    } else {
      _getLocation();
      // _center = const LatLng(37.525967411259835, 126.92247283324362);
    }
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final marker = Marker(
      markerId: const MarkerId('0'),
      position: LatLng(_center.latitude, _center.longitude),
    );

    _markers.add(marker);
  }

  void _onCameraMove(position) {
    _center = position.target;
    isMapMoved = true;
  }

  void _selectLocation() async {
    final String? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LocationBottomModal(
          prevLocName: isMapMoved ? null : widget.prevLocName,
        );
      },
    );
    if (result == null || result.trim().isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    Timer(const Duration(milliseconds: 500), () {
      Navigator.pop(context, {
        'text': result,
        'coords': _center,
      });
    });
  }

  _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (locationData.latitude != null) {
      print('----------getcur location---------------');
      mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘 함께',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '뛰고 싶은 장소를 선택해주세요',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMapWidget(
                      markers: _markers.toSet(),
                      onMapCreated: _onMapCreated,
                      onCameraMove: _onCameraMove),
                  Image.asset(
                    'assets/images/location_pin.png',
                    width: 50,
                    height: 50,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      return Transform.translate(
                        offset: const Offset(4, -27),
                        child: child,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _selectLocation,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '선택 완료',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _getLocation();
          // var gps = await getCurrentLocation();

          // _controller.animateCamera(
          //     CameraUpdate.newLatLng(LatLng(gps.latitude, gps.longitude)));
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.my_location,
          color: Colors.black,
        ),
      ),
    );
  }
}
