import 'package:flutter/cupertino.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/api/notifications-requests.dart';
import 'package:gigachat/services/events-controller.dart';

/// this class will be responsible for all user notifications functionality
/// it will act as a mediator between the API interfaces and Widgets of the
class NotificationsProvider extends ChangeNotifier{
  static NotificationsProvider? _instance;

  NotificationsProvider._internal();

  factory NotificationsProvider(){
    _instance ??= NotificationsProvider._internal();
    return _instance!;
  }

  static get instance {
    return NotificationsProvider();
  }

  final List<NotificationObject> _notifications = [];
  int page = 1;
  int count = 25;
  int offset = 0;
  bool _canLoadMore = true;

  /// initializes the provider
  /// and start listening on the events
  void init(){
    EventsController.instance.addEventHandler(EventsController.EVENT_NOTIFICATION_SEEN,
      HandlerStructure(id: "NotificationsProvider",
        handler: (data) {
          for (NotificationObject note in _notifications){
            if (note.id == data["id"]){
              note.seen = true;
              EventsController.instance.triggerEvent(EventsController.EVENT_NOTIFICATIONS_CHANGED, {});
              notifyListeners();
            }
          }
        },
      ),
    );
  }

  /// returns current notifications unseen count for a user [token]
  /// (normally the [Auth._currentUser])
  /// will always return something even if the request fails
  Future<int> getUnseenCount(String token) async {
    var k = await Notifications.apiGetUnseenCount(token);
    if (k.data == null){
      return 0;
    }
    return k.data!;
  }

  /// reloads all notifications for a user [token]
  /// (normally the [Auth._currentUser])
  Future<List<NotificationObject>> reloadAll(String token) async {
    _notifications.clear();
    _canLoadMore = true;
    page = 1;
    return await getAllNotifications(token);
  }

  /// gets the current notifications
  List<NotificationObject> getCurrentNotifications(){
    return _notifications;
  }

  /// returns weather this provider can load more messages or not
  bool canLoadMore(){
    return _canLoadMore;
  }

  /// get all notifications for a user [token]
  /// and marks them as seen
  /// (normally the [Auth._currentUser])
  Future<List<NotificationObject>> getAllNotifications(String token) async {
    if (_notifications.isEmpty){ //first load
      await getNotifications(token);
      await markAllSeen(token);
    }
    return _notifications;
  }

  /// get all notifications for a user [token]
  /// (normally the [Auth._currentUser])
  Future<List<NotificationObject>> getNotifications(String token) async {
    if (!_canLoadMore){
      return [];
    }

    var k = await Notifications.apiGetNotifications(token, page, count);
    if (k.data == null || k.data!.isEmpty){
      _canLoadMore = false;
      return [];
    }

    _notifications.addAll(k.data!);
    page++;
    print("loading note : ${_notifications.length}");
    EventsController.instance.triggerEvent(EventsController.EVENT_NOTIFICATIONS_CHANGED, {});
    notifyListeners();
    return k.data!;
  }

  /// marks all notifications for a user [token] as seen
  /// (normally the [Auth._currentUser])
  Future<void> markAllSeen(String token) async {
    await Notifications.apiMarkAll(token);
  }


}