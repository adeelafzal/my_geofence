import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_geofence/add_hospital.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchLocationPage extends StatefulWidget {
  const SearchLocationPage({Key key}) : super(key: key);

  @override
  _SearchLocationPageState createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage>
    with WidgetsBindingObserver {
  final Completer<GoogleMapController> _controller = Completer();
   bool serviceEnabled, locationDenied = false, serviceDenied = false;
  LatLng latLng;

  animateCamera(LatLng latlng) {
    _controller.future.then((value) {
      value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(latlng.latitude, latlng.longitude),
        zoom: 15,
      )));
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    latLng = LatLng(24.8917708,67.0822045);
    handlePermission();

    super.initState();
  }

  Future<Position> getCurrentLocation() async {

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return await Geolocator.getCurrentPosition();

}

  handlePermission() {
    getCurrentLocation()
        .then((position) {
      if (position != null) {
          latLng = LatLng(position.latitude, position.longitude);

        animateCamera(LatLng(position.latitude, position.longitude));
      }
    }).catchError((error) {
      if (error == 'services disabled') {
        serviceDenied = true;
        return;
      }
      if (error == 'permanently denied') locationDenied = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (serviceDenied) {
        Geolocator.isLocationServiceEnabled().then((serviceEnabled) {
          if (serviceEnabled) {
            serviceDenied = false;
            handlePermission();
          }
        });
        return;
      }
      if (locationDenied) {
        Geolocator.checkPermission().then((permission) async {

            locationDenied = false;
            await Geolocator.getCurrentPosition().then((position) {
              if (position != null) {
                latLng = LatLng(position.latitude, position.longitude);
                animateCamera(LatLng(position.latitude, position.longitude));
              }
            });
        });
      }
    }
  }

  Future<List> getAddress(double lat, double lng) async {
    final coordinates = Coordinates(lat, lng);
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    addresses.first;
    String fullAddress = addresses.first.addressLine;
    return [{"lat":lat,"lng":lng,"address":fullAddress}];
  }
String address="";
  @override
  Widget build(BuildContext context) {
    double screeSize = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Search Location"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: latLng,
                    zoom: 15,
                  ),
                  buildingsEnabled: true,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onCameraMove: (position) {
                    latLng =
                        LatLng(position.target.latitude, position.target.longitude);
                  },
                ),
                const Center(
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                  context,
                  getAddress(latLng.latitude,
                      latLng.longitude));
            },
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }
}
