import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:my_geofence/add_hospital.dart';
import 'package:my_geofence/hospital_screen.dart';
import 'package:my_geofence/main.dart';
import 'package:my_geofence/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  List data = [
    {"title": "Restaurants", "icon": Icons.restaurant, "index": 0},
    {"title": "Map", "icon": Icons.map, "index": 1},
    {"title": "Add Restaurant", "icon": Icons.add, "index": 2},
    {"title": "Start Geofence", "icon": Icons.play_circle_fill, "index": 3},
  ];

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    geofence.id;
    if (geofenceStatus == GeofenceStatus.ENTER) {
      displayNotification(
        geofence.id,
        "Visiting a Restaurant? Why wait in long queues when you can get food to near you",
        id: Random().nextInt(1000),
      );
    } else if (geofenceStatus == GeofenceStatus.EXIT) {
      displayNotification(
        geofence.id,
        "In need of a Food? visit nearest restaurant.",
        id: Random().nextInt(1000),
      );
    } else if (geofenceStatus == GeofenceStatus.DWELL) {
      displayNotification(
        geofence.id,
        "In need of a food? Get your food right now.",
        id: Random().nextInt(1000),
      );
    }
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  Future<void> displayNotification(String title, String body,
      {int id = 1, String payload}) async {
    BigTextStyleInformation bigTextStyleInformation =
    BigTextStyleInformation(
      body,
      contentTitle: "Restaurant : $title",
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('id', 'name',
        channelDescription: 'description',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: bigTextStyleInformation);
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      "Restaurant : $title",
      body,
      platformChannelSpecifics,
      payload: "1",
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      geofenceService.addStreamErrorListener(_onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Geofence Restaurants"),),
      body: _buildContentView(),
    );
  }

  CarouselSlider buildSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.easeInOut,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.7,
      ),
      items: [
        "image1",
        "image2",
        "image4",
        "image5",
        "image6",
      ]
          .map(
            (image) => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black54.withOpacity(0.1),
                  blurRadius: 3,
                  spreadRadius: 3,
                  offset: const Offset(0, 3))
            ],
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FadeInImage(
              fit: BoxFit.fill,
              placeholder: const AssetImage('images/image1.png'),
              image: AssetImage("images/$image.png"),
            ),
          ),
        ),
      )
          .toList(),
    );
  }


  Widget buildGridItem({
    @required Map quickLink,
    @required Function(int) onTap,
  }) {
    String title = quickLink['title'];
    return InkWell(
      onTap: () {
        onTap(quickLink['index']);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              quickLink['icon'],
              size: 40,
            ),
            const SizedBox(
              width: 60,
              child: Divider(
                thickness: 1,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView() {
    return Column(
      children: [
        const SizedBox(height: 25),
        buildSlider(),
        const SizedBox(height: 20),
        buildGridView(onTap: (index) {
          if (index == 0) {
            newScreen(const HospitalScreen());
          } else if (index == 1) {
            newScreen(const MapScreen());
          } else if (index == 2) {
            newScreen(AddHospitalScreen());
          } else if (index == 3) {
            if(geofenceService.isRunningService){
              data.removeAt(3);
              geofenceService.stop();
              data.insert(3, {"title": "Start Geofence", "icon": Icons.play_circle_fill, "index": 3});
            }else{
              print(geofenceList.length);
              geofenceService.start(geofenceList).catchError(_onError);
              data.removeAt(3);
              data.insert(3, {"title": "Stop Geofence", "icon": Icons.pause_circle_filled, "index": 3});
            }
            setState(() {
            });
          }
        })
      ],
    );
  }

  Widget buildGridView({
    @required Function(int) onTap,
  }) {
    return GridView.count(
      primary: false,
      shrinkWrap: true,
      childAspectRatio: 1.2,
      crossAxisCount: 2,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
      children: data.map(
            (option) => Card(
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: buildGridItem(
            onTap: onTap,
            quickLink: option,
          ),
        ),
      )
          .toList(),
    );
  }

  newScreen(pageName) => Navigator
      .push(context,MaterialPageRoute(builder: (BuildContext context) => pageName));

}


