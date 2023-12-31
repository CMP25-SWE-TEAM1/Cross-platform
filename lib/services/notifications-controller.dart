import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gigachat/AppNavigator.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/firebase_options.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/services/notifications-navigation-pages/post-notification-navigation.dart';
import 'package:gigachat/services/notifications-navigation-pages/profile-notification-navigation.dart';

/// defines a Notification that can trigger a type of action
/// depending on its [payload]
class TriggerNotification{
  final Map<String,dynamic> payload;
  final String? actionID;
  final String? input;
  final String id;

  TriggerNotification(this.id, {required this.payload, required this.actionID, required this.input});

  static TriggerNotification fromFirebase(RemoteMessage msg){
    var data = msg.data["notification"];
    if (data.runtimeType == String){ //fk firebase ig
      data = jsonDecode(data);
    }
    return TriggerNotification(msg.messageId ?? "no-id", payload: data, actionID: 'firebase', input: null);
  }

  static TriggerNotification fromLocal(NotificationResponse res){
    var payload = res.payload;
    Map<String,dynamic> map = {};
    if (payload != null && payload.isNotEmpty){
      try {
        map = jsonDecode(payload);
      } catch (e){
        print("can't decode : $e");
      }
    }
    return TriggerNotification(map["_id"], payload: map, actionID: res.actionId, input: res.input);
  }

  static TriggerNotification fromNotificationsList(NotificationObject note){
    return TriggerNotification(note.id , payload: {
      "_id" : note.id,
      "destination" : note.targetID,
      "type" : note.type,
    }, actionID: "local", input: null);
  }
}

/// this class will manager all of the notification related functionality
/// and will communicate with the [Firebase] and dispatch LocalNotification
/// when needed
class NotificationsController {
  static final NotificationsController _notificationService = NotificationsController._internal();
  NotificationsController._internal();

  factory NotificationsController() {
    return _notificationService;
  }

  static NotificationsController getInstance(){
    return NotificationsController();
  }

  static void _DoDispatchNotificationChat(String target) async {
    if (target != Globals.currentActiveChat) {
      NavigatorState nav = AppNavigator.getNavigator(NavigatorDirection.HOME, NavigatorDirection.CHAT);
      nav.push(MaterialPageRoute(
          builder: (context) =>
              ProfileNotificationNavigation(target: target, chat: true,)));
    }
  }

  static void _DoDispatchNotificationFollow(String target) async {
    NavigatorState nav = AppNavigator.getNavigator(NavigatorDirection.HOME, NavigatorDirection.HOME);
    nav.push(MaterialPageRoute(builder: (context) => ProfileNotificationNavigation(target: target,)));
  }

  static void _DoDispatchNotificationLike(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationReply(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationQuote(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationRetweet(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchNotificationMention(String target) async {
    _DoDispatchTypePost(target);
  }

  static void _DoDispatchTypePost(String target) async {
    NavigatorState nav = AppNavigator.getNavigator(NavigatorDirection.HOME, NavigatorDirection.HOME);
    nav.push(MaterialPageRoute(builder: (context) => PostNotificationNavigation(target: target,)));
  }

  static void _DoDispatchNotification(TriggerNotification note) {
    NavigatorState? state = Globals.appNavigator.currentState;

    //print("Dispatching Note: ${note.payload}" );
    if (note.actionID != 'local') {
      LocalSettings.instance.setValue<String>(
          name: "last_note_id", val: note.id);
      LocalSettings.instance.apply();
    }


    if (state != null){
      if (Auth().getCurrentUser() == null){
        return; //not logged in
      }
      // trigger the notification
      switch (note.payload["type"]){
        case "follow" :
          _DoDispatchNotificationFollow(note.payload["destination"]);
          break;
        case "like"   :
          _DoDispatchNotificationLike(note.payload["destination"]);
          break;
        case "reply"  :
          _DoDispatchNotificationReply(note.payload["destination"]);
          break;
        case "quote"  :
          _DoDispatchNotificationQuote(note.payload["destination"]);
          break;
        case "retweet":
          _DoDispatchNotificationRetweet(note.payload["destination"]);
          break;
        case "mention":
          _DoDispatchNotificationMention(note.payload["destination"]);
          break;
        case "message":
          _DoDispatchNotificationChat(note.payload["destination"]);
          break;
      }
    } else {
      print("State was null");
    }
  }

  /// triggers a [TriggerNotification] [note] and moves the user to the right page
  /// of the application to display the correct content of the notification
  static void dispatchNotification(TriggerNotification note , BuildContext context){
    _DoDispatchNotification(note);
  }

  /// returns the notification that caused the application to launch
  /// will return null if the app started normally
  static Future<TriggerNotification?> getLaunchNotification() async {
    if (Platform.isWindows){
      return null;
    }

    RemoteMessage? msg = await FirebaseMessaging.instance.getInitialMessage();
    if (msg != null) {
      TriggerNotification note = TriggerNotification.fromFirebase(msg);
      String? id = LocalSettings.instance.getValue<String>(
          name: "last_note_id", def: null);
      if (id != note.id) {
        return note;
      }
    }

    NotificationAppLaunchDetails? l = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (l != null && l.didNotificationLaunchApp){
      TriggerNotification note = TriggerNotification.fromLocal(l.notificationResponse!);
      String? id = LocalSettings.instance.getValue<String>(name: "last_note_id", def: null);
      if (id == null || id != note.id){ //because this stupid thing doesn't return null
        return note;
      }
    }
    return null;
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? FirebaseToken;
  static int _counter = 1;

  /// initializes the notifications controller
  Future<void> init() async {

    if (Platform.isWindows){
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_notifications');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
      macOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _foregroundNotification,
      onDidReceiveBackgroundNotificationResponse: _backgroundNotification,
    );

    platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

  }

  /// de-initializes the notification controller
  Future<void> logout() async {
    if (!Platform.isAndroid){
      print("Firebase is disabled on windows");
      return;
    }

    if(FirebaseToken == null){
      return;
    }
    FirebaseToken = null;
    await FirebaseMessaging.instance.deleteToken();
  }

  /// links the [NotificationsController] with the Firebase
  /// and starts listening on incoming notifications
  Future<void> login() async {
    if(FirebaseToken != null){
      return;
    }

    if (!Platform.isAndroid){
      print("Firebase is disabled on windows");
      return;
    }

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();
    FirebaseToken = await firebaseMessaging.getToken();
    print("Firebase Token : $FirebaseToken");

    //this will handle the messages when the app is background
    FirebaseMessaging.onBackgroundMessage(_backgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("firebase: ${event.data}");
      TriggerNotification note = TriggerNotification.fromFirebase(event);
      _DoDispatchNotification(note);
    });

    //this will handle them when the app is in foreground
    FirebaseMessaging.onMessage.listen((event) {
      print("Firebase Message : ${event.notification}");
      final RemoteNotification? note = event.notification;
      if (note == null) return;
      var map = jsonDecode(event.data["notification"]);
      if (map["type"] == "message"){
        if (map["destination"] == Globals.currentActiveChat){
          return;
        }
      }
      showNotification(_counter++ , title: note.title , body: note.body , payload: event.data["notification"]);
    });
  }

  final AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    "gigachat-channel-id",   //Required for Android 8.0 or after
    "gigachat-channel",      //Required for Android 8.0 or after
    channelDescription: "this is the gigachat app notification channel",  //Required for Android 8.0 or after
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    color: Colors.black,
  );

  late final NotificationDetails platformChannelSpecifics;

  /// shows one notification with [id] and [title]
  /// and with content [body] and payload data [payload]
  void showNotification(
      int id,
      {String? title, String? body, String? payload}
      ) async {

    EventsController.instance.triggerEvent(
        EventsController.EVENT_NOTIFICATION_RECEIVED, {});

    if (payload != null) {
      var note = jsonDecode(payload);
      if (note["type"] == "mention") {
        EventsController.instance.triggerEvent(
            EventsController.EVENT_NOTIFICATION_MENTIONED, {});
      }
    }

    await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload);
  }



  @pragma("vm-entry-point")
  static void _foregroundNotification(NotificationResponse res){
    TriggerNotification note = TriggerNotification.fromLocal(res);
    _DoDispatchNotification(note);
  }

  @pragma("vm-entry-point")
  static void _backgroundNotification(NotificationResponse res){
    print("background: ${res.payload}");
    //this runs on the background without the app
    //nothing to do here
    //AppTriggerNotification = TriggerNotification(payload: res.payload == null || res.payload!.isEmpty ? {} : jsonDecode(res.payload!), actionID: res.actionId, input: res.input);
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessage(RemoteMessage message) async {
    print("background message : $message");
    EventsController.instance.triggerEvent(EventsController.EVENT_NOTIFICATION_RECEIVED, {});
    var note = jsonDecode(message.data["notification"]);
    if (note["type"] == "mention"){
      EventsController.instance.triggerEvent(EventsController.EVENT_NOTIFICATION_MENTIONED, {});
    }
    // firebase should already create the notification ..
    // await NotificationsController().init();
    // RemoteNotification note = message.notification!;
    // NotificationsController().showNotification(-1 , title: note.title , body: note.body , payload: jsonEncode(message.data));
  }

}