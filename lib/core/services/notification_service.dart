import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:video_call_app/configs/dependency_injection.dart';
import 'package:video_call_app/core/controller/global_naviagtor.dart';
import 'package:video_call_app/features/video_call/presentation/screens/incoming_call_screen.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _incomingCallChannel =
      AndroidNotificationChannel(
        'incoming_call_channel',
        'Incoming Calls',
        description: 'Notifications for incoming video calls',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: false,
      );

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = const InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: DarwinInitializationSettings(),
    );

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) async {
        _handleTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Android channel setup
    final android = _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_incomingCallChannel);
    // On Android 13+ you must request the POST_NOTIFICATIONS runtime permission
    final enabled = await android?.areNotificationsEnabled();
    if (enabled == false) {
      await android?.requestNotificationsPermission();
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    NotificationService.instance._handleTap(response.payload);
  }

  Future<void> showIncomingCallNotification({
    String callerName = 'Unknown caller',
    String roomId = 'defaultRoom',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _incomingCallChannelId,
      _incomingCallChannelName,
      channelDescription: _incomingCallChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      ticker: 'Incoming video call',
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _fln.show(
      1001,
      'Incoming video call',
      callerName,
      details,
      payload: roomId,
    );
  }

  Future<void> cancelIncomingCallNotification() async {
    await _fln.cancel(1001);
  }

  void _handleTap(String? payload) {
    final nav = locator<GlobalNavigator>().navigatorKey.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: 'Caller',
          roomId: payload ?? 'defaultRoom',
        ),
      ),
    );
  }
}

const String _incomingCallChannelId = 'incoming_call_channel';
const String _incomingCallChannelName = 'Incoming Calls';
const String _incomingCallChannelDescription =
    'Notifications for incoming video calls';
