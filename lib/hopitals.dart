import 'package:flutter/cupertino.dart';

class Hospitals {
  String title;
  String address;
  double lat;
  double lng;
  double radius;

  Hospitals({
    @required this.title,
    @required this.address,
    @required this.lat,
    @required this.lng,
    @required this.radius,
  });
}
