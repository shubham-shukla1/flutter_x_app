// ignore_for_file: unnecessary_null_comparison
import 'dart:io';
import 'dart:convert';

import 'package:clevertap_plugin/clevertap_plugin.dart';

import '../../shared/app_logging/app_log_helper.dart';
import 'package:flutter_x_app/services/notification/notificationModel.dart' as nm;

import 'notificationModel.dart';

abstract class NoticationServiceAbstract {
  Future<List<dynamic>?> getAllNotifications();

  Future<void> readNotification(String id);

  Future<int?> getUnreadInboxCount();

  Future<void> readAllNotification();

// Future<bool> logOut();
}

class NotificationServiceImp implements NoticationServiceAbstract {
  static NotificationServiceImp? _instance;

  static NotificationServiceImp get instance {
    if (_instance == null) {
      _instance = NotificationServiceImp();
    }
    return _instance!;
  }

  @override
  Future<List<Notifications>?> getAllNotifications() async {
    if (Platform.isAndroid) {
      List<dynamic>? result = await CleverTapPlugin.getAllInboxMessages();
      List<NotificationModel> notificationsData = [];
      try {
        result!.forEach((element) {
          try {
            NotificationModel notificationModel = NotificationModel(
              id: element['id'].toString(),
              date: element['date'].toString(),
              isRead: element['isRead'].toString(),
              msg: Msg.fromJson(json.decode(element['msg'].toString())
                  as Map<String, dynamic>),
              // tags: element['tags'] as List<String>,
            );
            notificationsData.add(notificationModel);
          } catch (e, s) {
            AppLog.log(e.toString(), error: e, stackTrace: s);
          }
        });
      } catch (e) {
        AppLog.log(e.toString());
      }
      List<Notifications> notifications = [];
      notificationsData.forEach((element) {
        bool hasUrl = element.msg.content[0].action.hasUrl;

        notifications.add(Notifications(
            id: element.id,
            title: element.msg.content[0].title.text,
            body: element.msg.content[0].message.text,
            payload: hasUrl
                ? (Platform.isIOS)
                    ? element.msg.content[0].action.url.ios.text
                    : element.msg.content[0].action.url.android.text
                : null,
            isRead: element.isRead == 'true'));
      });
      return notifications;
    } else {
      List<dynamic>? result = await CleverTapPlugin.getAllInboxMessages();
      List<NotificationModel> notificationsData = [];
      try {
        result!.forEach((element) {
          try {
            Msg msgModel = Msg(
              content: [
                Content(
                  key: element['msg']['content'][0]['key'] as int,
                  message: Message(
                    text: element['msg']['content'][0]['message']['text']
                        .toString(),
                  ),
                  title: nm.Title(
                      text: element['msg']['content'][0]['title']['text']
                          .toString()),
                  action: nm.Action(
                    hasLinks: element['msg']['content'][0]['action']['hasLinks']
                        as bool,
                    hasUrl: element['msg']['content'][0]['action']['hasUrl']
                        as bool,
                    url: Url(
                      android: nm.Android(text: ''),
                      ios: nm.Ios(
                          text: element['msg']['content'][0]['action']['url']
                              ['ios']['text'] as String),
                    ),
                  ),
                ),
              ],
            );

            NotificationModel notificationModel = NotificationModel(
              id: element['_id'].toString(),
              date: element['date'].toString(),
              isRead: element['isRead'].toString(),
              msg: msgModel,
              // tags: element['tags'] as List<String>,
            );
            notificationsData.add(notificationModel);
          } catch (e, s) {
            AppLog.log(e.toString(), error: e, stackTrace: s);
          }
        });
      } catch (e) {
        AppLog.log(e.toString());
      }
      List<Notifications> notifications = [];
      notificationsData.forEach((element) {
        bool hasUrl = element.msg.content[0].action.hasUrl;

        notifications.add(Notifications(
            id: element.id,
            title: element.msg.content[0].title.text,
            body: element.msg.content[0].message.text,
            payload: hasUrl
                ? (Platform.isIOS)
                    ? element.msg.content[0].action.url.ios.text
                    : element.msg.content[0].action.url.android.text
                : null,
            isRead: element.isRead == 'true'));
      });
      return notifications;
    }
  }

  @override
  Future<void> readNotification(String id) async {
    CleverTapPlugin.markReadInboxMessageForId(id);
  }

  @override
  Future<int?> getUnreadInboxCount() async {
    return CleverTapPlugin.getInboxMessageUnreadCount();
  }

  @override
  Future<void> readAllNotification() async {
    try {
      List<dynamic>? allNotification =
          await CleverTapPlugin.getUnreadInboxMessages();
      allNotification!.forEach((element) async {
        if (Platform.isAndroid) {
          await CleverTapPlugin.markReadInboxMessageForId(
              element['id'].toString());
        } else {
          await CleverTapPlugin.markReadInboxMessageForId(
              element['_id'].toString());
        }
      });
    } catch (e, s) {
      AppLog.log(
        'Error reading all notifications: ',
        error: e,
        stackTrace: s,
      );
    }
  }
}
