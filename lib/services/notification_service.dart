import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void notificationPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: true,
      sound: true,
      criticalAlert: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("*");

    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("*@");
    }else{
      print("*@#");
    }
  }

  Future<String> getToken() async {
    String? token = await firebaseMessaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
      print("istokenrefresh called ");
    });
  }

  void initLocalNotification(BuildContext context , RemoteMessage message) async {
    var androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');

      var intializationSetting = InitializationSettings(android: androidInitialization);

      await flutterLocalNotificationsPlugin.initialize(intializationSetting, onDidReceiveNotificationResponse: (payload){});
  }

  void firebaseInit() async {
    FirebaseMessaging.onMessage.listen((message) {

      if(kDebugMode){
        print(message.notification!.title.toString());
      print(message.notification!.body.toString());
      }
      
      
      showNotification(message);
      print('firebaseinit called');

      
     });
  }

  Future<void> showNotification(RemoteMessage message) async {
    var androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');

      var intializationSetting = InitializationSettings(android: androidInitialization);

      await flutterLocalNotificationsPlugin.initialize(intializationSetting, onDidReceiveNotificationResponse: (payload){});
    print('show notification called');
    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(Random.secure().nextInt(100000).toString(), 'arogya_mitra',description: 'description',importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(androidNotificationChannel.id.toString(),androidNotificationChannel.name.toString(),channelDescription: 'description',importance: Importance.high,priority: Priority.high,ticker: 'ticker',styleInformation: BigPictureStyleInformation(FilePathAndroidBitmap("assets/images/heart.png"),largeIcon: FilePathAndroidBitmap("assets/images/heart.png")));

    

    NotificationDetails notificationDetails =  NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero,()  {
      print("future delayed");
       flutterLocalNotificationsPlugin.show(0, message.notification!.title.toString(), message.notification!.body.toString(), notificationDetails);
    } );
  }
}