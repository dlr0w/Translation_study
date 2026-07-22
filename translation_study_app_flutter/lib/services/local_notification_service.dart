import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// このクラスの責務
// 通知プラグインの初期化
// Android/iOSの通知許可リクエスト
// タイムゾーン初期化
// 毎日20時通知の予約
// 通知タップ時のpayload受け取り
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  // 通知プラグインのインスタンス
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // 通知プラグインを初期化
  static Future<void> initialize({
    required void Function(String? payload) onTap,
  }) async {
    // タイムゾーンを初期化
    await _initializeTimeZone();
    // TODO: 通知プラグインを初期化
    // Android 初期設定（引数にはアプリのアイコンが保存されているパスを指定。）
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // 現在はデフォルトのFlutter画像を指定。

    // iOS 初期設定
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
          // Darwin settings
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          // iOS-specific settings
          requestCarPlayPermission: true,
        );

    // MAC OS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    // WINDOWS
    final WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
          appName: 'TRANSLATION STUDY',
          appUserModelId: 'com.example.translation_study_app',

          // Search online for GUID generators to make your own
          guid: 'c0a6dafe-0cf5-4706-8f98-70268b7e1433',
        );

    // 全体設定
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsDarwin,
          windows: initializationSettingsWindows,
        );

    // プラグインの初期化
    await _plugin.initialize(
      settings: initializationSettings,
      // アプリがフォアグラウンドの状態で通知をタップした際の処理
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      // アプリがバックグラウンドの状態で通知をタップした際の処理
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    // プラットフォームごとの権限設定
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    } else if (Platform.isAndroid) {
      await _requestAndroidPermissions();
    } else if (kIsWeb) {
      return;
    } else {
      debugPrint('通知権限のリクエストはサポートされていません');
    }
  }

  static Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();

    // ローカルタイムゾーンを設定
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    // タイムゾーン情報からロケーションを取得
    final location = tz.getLocation(timezoneInfo.identifier);
    // ロケーションをローカルタイムゾーンとして設定
    tz.setLocalLocation(location);
  }

  // 通知を出してよいか、iOSに確認
  static Future<void> _requestIOSPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> _requestAndroidPermissions() async {
    // 通知を出してよいか、Androidに確認
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 通知のタップ時の処理
  static Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) async {
    // ここに処理を記載
    final payload = response.payload;
    if (payload != null) {
      debugPrint('通知がタップされました！: $payload');
    }
    debugPrint('onDidReceiveNotificationResponse: $response');
    // final String? payload = notificationResponse.payload;
    // if (notificationResponse.payload != null) {
    //   debugPrint('notification payload: $payload');
    // }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  // バックグラウンドで通知を受け取った時の処理
  static Future<void> _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response,
  ) async {
    debugPrint('onDidReceiveBackgroundNotificationResponse: $response');
  }

  // 毎日20時通知を予約
  static Future<void> scheduleDailyReviewReminder() async {
    // TODO: 毎日20時通知を予約
  }
  // 毎日20時通知をキャンセル
  static Future<void> cancelDailyReviewReminder() async {
    // TODO: 毎日20時通知をキャンセル
  }
}


// TODOメモ
// 参考URL
// https://zenn.dev/koichi_51/articles/6921b2176ec29a
// https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications#displaying-a-notification
// ・_onDidReceiveNotificationResponseの実装（Navigatorの実装？）
// ・_onDidReceiveBackgroundNotificationResponseの実装（Navigatorの実装？）
// ・通知を表示するの実装
// ・通知を表示するために必要なフィールドの実装
//
