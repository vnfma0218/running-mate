import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({
    super.key,
    this.center = const LatLng(37.525967411259835, 126.92247283324362),
    required this.markers,
    required this.onMapCreated,
    this.onCameraMove,
  });
  final LatLng center;
  final Set<Marker> markers;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(CameraPosition)? onCameraMove;

  // late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    // mapController = controller;

    onMapCreated(controller);
    // final marker = Marker(
    //   markerId: const MarkerId('0'),
    //   position: LatLng(center.latitude, center.longitude),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      // myLocationEnabled: true,
      zoomControlsEnabled: false,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 15,
      ),
      // padding: const EdgeInsets.all(8),
      onCameraMove: (position) {
        if (onCameraMove != null) {
          onCameraMove!(position);
        }
      },
    );
  }
}
