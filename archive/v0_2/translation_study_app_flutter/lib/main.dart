// Serverpod が生成したクライアント型を使うための import。
import 'package:translation_study_app_client/translation_study_app_client.dart';
// Flutter の UI フレームワーク本体。
import 'package:flutter/material.dart';
// Serverpod と Flutter の接続監視を行うためのパッケージ。
import 'package:serverpod_flutter/serverpod_flutter.dart';
// 認証セッション管理を行うためのパッケージ。
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

// v0.2 のホーム画面（翻訳/復習タブ）。
import 'screens/app_home_screen.dart';

// アプリ全体で使う Serverpod クライアント。
late final Client client;
// サーバー URL（将来、画面側で参照する可能性を残して保持）。
late String serverUrl;

// Flutter アプリのエントリーポイント。
void main() async {
  // 非同期初期化前に Flutter バインディングを有効化する。
  WidgetsFlutterBinding.ensureInitialized();

  // assets/config.json または dart-define から Server URL を取得する。
  final serverUrl = await getServerUrl();

  // Serverpod クライアントを作成し、通信監視と認証セッション管理を設定する。
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // 認証モジュールを初期化する。
  client.auth.initialize();

  // Flutter アプリを起動する。
  runApp(const MyApp());
}

// アプリ全体のルートウィジェット。
class MyApp extends StatelessWidget {
  // const コンストラクタ。
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 端末上に表示されるアプリタイトル。
      title: 'Translation Study App',
      // v0.2 の簡易テーマ。
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      // 起動時に表示する画面。
      home: const AppHomeScreen(),
    );
  }
}
