import 'package:flutter/services.dart';

class NotificationService {
  static const EventChannel _eventChannel =
  EventChannel('notification_expense_manager/notifications');

  static const MethodChannel _methodChannel =
  MethodChannel('notification_expense_manager/settings');

  /// Stream nhận notification realtime từ Android.
  static Stream<Map<String, dynamic>> get notifications {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final data = Map<String, dynamic>.from(event as Map);

      return {
        'packageName': data['packageName']?.toString() ?? '',
        'title': data['title']?.toString() ?? '',
        'text': data['text']?.toString() ?? '',
        'timestamp': data['timestamp'],
      };
    });
  }

  /// Kiểm tra người dùng đã cấp Notification Access chưa.
  static Future<bool> isNotificationAccessGranted() async {
    try {
      final bool? result =
      await _methodChannel.invokeMethod<bool>(
        'isNotificationAccessGranted',
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Mở màn hình Notification Access của Android.
  static Future<void> openNotificationSettings() async {
    try {
      await _methodChannel.invokeMethod(
        'openNotificationSettings',
      );
    } on PlatformException catch (e) {
      print(
        'Không thể mở Notification Settings: ${e.message}',
      );
    }
  }
}