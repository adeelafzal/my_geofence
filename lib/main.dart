import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:my_geofence/add_hospital.dart';
import 'package:my_geofence/hopitals.dart';
import 'package:my_geofence/hospital_screen.dart';
import 'package:my_geofence/map_screen.dart';

List<Hospitals> hospitals = [];

void main() => runApp( MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create a [GeofenceService] instance and set options.
  final _geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: false,
      allowMockLocations: true,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // Create a [Geofence] list.
  final _geofenceList = <Geofence>[
    Geofence(
      id: 'place_1',
      latitude: 24.882998,
      longitude: 67.09685,
      radius: [
        GeofenceRadius(id: 'radius_400m', length: 400),
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    if (geofenceStatus == GeofenceStatus.ENTER) {
      displayNotification(
        "Visiting a Hospital? Why wait in long queues when you can consult a certified doctor through our App? Click here to experience the convenience of TPL Sahulat.",
        id: Random().nextInt(1000),
      );
    } else if (geofenceStatus == GeofenceStatus.EXIT) {
      displayNotification(
        "In need of a Doctor? Consult a certified doctor through our App right away. Click here to experience the convenience of TPL Sahulat.",
        id: Random().nextInt(1000),
      );
    } else if (geofenceStatus == GeofenceStatus.DWELL) {
      displayNotification(
        "In need of a Doctor? Book a Doctor to visit you at home through our App right away. Click here to experience the convenience of TPL Sahulat.",
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  setUpNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) {});
  }

  @override
  void initState() {
    super.initState();
    setUpNotification();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
  }
  GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return _geofenceService.isRunningService;
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription:
              'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: const Text('Geofence Hospitals'),
          ),
          body: _buildContentView(),
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
          }else if (index == 2) {
            newScreen(AddHospitalScreen());
          }
        })
      ],
    );
  }

  newScreen(pageName) => navigatorKey.currentState.push(MaterialPageRoute(builder: (BuildContext context) => pageName));
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
    children: [
      {"title": "Hospitals", "icon": Icons.local_hospital, "index": 0},
      {"title": "Map", "icon": Icons.map, "index": 1},
      {"title": "Add Hospital", "icon": Icons.add_box_rounded, "index": 2},
      {"title": "Start Geofence", "icon": Icons.play_circle_fill, "index": 3},
    ]
        .map(
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

Future<void> displayNotification(String body,
    {int id = 1, String payload}) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'id',
    'name',
    channelDescription: 'description',
    importance: Importance.high,
    priority: Priority.high,
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id,
    "Geofence",
    body,
    platformChannelSpecifics,
    payload: "1",
  );
}
