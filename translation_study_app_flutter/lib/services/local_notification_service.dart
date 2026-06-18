import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // 通知プラグインを初期化
  Future<void> initialize({
    required void Function(String? payload) onTap,
  }) async {
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

    await _plugin.initialize(
      settings: initializationSettings,
      // アプリがフォアグラウンドの状態で通知をタップした際の処理
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      // アプリがバックグラウンドの状態で通知をタップした際の処理
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

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

  // 通知を出してよいか、iOSに確認
  Future<void> _requestIOSPermissions() async {
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

  Future<void> _requestAndroidPermissions() async {
    // 通知を出してよいか、Androidに確認
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 毎日20時通知を予約
  Future<void> scheduleDailyReviewReminder() async {
    // TODO: 毎日20時通知を予約
  }
  // 毎日20時通知をキャンセル
  Future<void> cancelDailyReviewReminder() async {
    // TODO: 毎日20時通知をキャンセル
  }
}
