import 'package:translation_study_app_client/translation_study_app_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'screens/app_home_screen.dart';

// 画面全体で共有するAPIクライアント。
late final Client client;
// 接続先APIのURLを保持する。
late String serverUrl;

// Flutter起動時の初期化処理。
void main() async {
  // `runApp`前にFlutter側の初期化を済ませる。
  WidgetsFlutterBinding.ensureInitialized();

  // 配布形態に応じた設定ファイル(assets/config.json)からAPI URLを読み込む。
  serverUrl = await getServerUrl();

  // API通信・接続監視・認証状態管理を1つのクライアントへまとめる。
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // 保存済みセッションがあればここで復元する。
  await client.auth.initialize();

  // ルートウィジェットを起動する。
  runApp(const MyApp());
}

// テーマと初期画面を定義するルートウィジェット。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // アプリ全体の基準色をシードから組み立てる。
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
    );

    return MaterialApp(
      // OS側に表示されるアプリ名。
      title: 'Translation Study App',
      // 右上のデバッグ帯は常時隠す。
      debugShowCheckedModeBanner: false,
      // 画面全体で使い回す共通テーマを定義する。
      theme: ThemeData(
        // Material 3準拠の見た目を使う。
        useMaterial3: true,
        // 基準色を全体へ適用する。
        colorScheme: colorScheme,
        // 背景基準食のsurfaceに寄せる。
        scaffoldBackgroundColor: colorScheme.surface,
        // AppBarの背景やタイトル文字を統一する。
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface.withValues(alpha: 0.82),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        // カード全体の角丸と境界線をそろえる。
        cardTheme: CardThemeData(
          elevation: 0,
          color: colorScheme.surface.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          margin: EdgeInsets.zero,
        ),
        // 入力欄の塗り・余白・フォーカス時の線をまとめる。
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
          ),
        ),
        // 主ボタンの高さと文字の太さを統一する。
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // 補助ボタンも同じ寸法感でそろえる。
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            side: BorderSide(color: colorScheme.outlineVariant),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // フィルターの色と角丸を統一する。
        chipTheme: ChipThemeData(
          backgroundColor: colorScheme.surfaceContainerLowest,
          selectedColor: colorScheme.primaryContainer,
          secondarySelectedColor: colorScheme.primaryContainer,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurface),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        // 下部ナビゲーションの背景と選択時ラベルを整える。
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            );
          }),
          indicatorColor: colorScheme.primaryContainer,
        ),
        // Snackbarの背景色と角丸を共通化する。
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.inverseSurface,
          contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      // まずは3タブを持つホーム画面を開く。
      home: const AppHomeScreen(),
    );
  }
}
