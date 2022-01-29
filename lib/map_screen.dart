import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_geofence/hopitals.dart';

import 'main.dart';

class MapScreen extends GoogleMapExampleAppPage {
  const MapScreen() : super(const Icon(Icons.linear_scale), 'Map');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title:Text("Map")),
      body: const PlaceCircleBody(),
    );
  }
}

class PlaceCircleBody extends StatefulWidget {
  const PlaceCircleBody();

  @override
  State<StatefulWidget> createState() => PlaceCircleBodyState();
}

class PlaceCircleBodyState extends State<PlaceCircleBody> {
  PlaceCircleBodyState();

  GoogleMapController controller;
  Map<CircleId, Circle> circles = <CircleId, Circle>{};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int _circleIdCounter = 1;
  CircleId selectedCircle;

  @override
  void initState() {
    for (var hospital in hospitals) {
      _add(hospital);
    }
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  void _add(Hospitals hospital) {
    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    final CircleId circleId = CircleId(circleIdVal);

    final Circle circle = Circle(
      circleId: circleId,
      strokeColor: Colors.red,
      strokeWidth: 2,
      center: LatLng(hospital.lat, hospital.lng),
      radius: hospital.radius,
    );
    circles[circleId] = circle;

    final MarkerId markerId = MarkerId(circleIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      infoWindow: InfoWindow(
        title: hospital.title,
        snippet: hospital.address,
      ),
      position: LatLng(hospital.lat, hospital.lng),
    );
    markers[markerId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      initialCameraPosition: const CameraPosition(
        target: LatLng(24.8917708, 67.0822045),
        zoom: 15.0,
      ),
      circles: Set<Circle>.of(circles.values),
      markers: Set<Marker>.of(markers.values),
      onMapCreated: _onMapCreated,
    );
  }

  // LatLng _createCenter() {
  //   final double offset = _circleIdCounter.ceilToDouble();
  //   return _createLatLng(51.4816 + offset * 0.2, -3.1791);
  // }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}

abstract class GoogleMapExampleAppPage extends StatelessWidget {
  const GoogleMapExampleAppPage(this.leading, this.title);

  final Widget leading;
  final String title;
}
