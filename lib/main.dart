import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:my_geofence/hopitals.dart';
import 'package:my_geofence/splash_screen.dart';

List<Hospitals> hospitals = [];
final geofenceList = <Geofence>[];
final geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: false,
    allowMockLocations: true,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return geofenceService.isRunningService;
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
        child: SplashScreen(),
      ),
    );
  }
}