import 'package:translation_study_app_client/translation_study_app_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:translation_study_app_flutter/services/local_notification_service.dart';

import 'screens/app_home_screen.dart';

// 画面全体で共有するAPIクライアント。
late final Client client;
// 接続先APIのURLを保持する。
late String serverUrl;

// Flutter起動時の初期化処理。
void main() async {
  // `runApp`前にFlutter側の初期化を済ませる。
  WidgetsFlutterBinding.ensureInitialized();
  // 通知サービスを初期化
  await LocalNotificationService.instance.initialize(onTap: (payload) {
    // TODO: 後で通知をタップした時の処理を書く。
    // payloadが'review_today'なら復習画面を開く。
    }

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
    // テーマ全体の元になる配色をここで作る。
    final colorScheme = ColorScheme.fromSeed(
      // ベースにする色。ここを変えると全体の雰囲気が変わる。
      seedColor: const Color(0xFF0F766E),
      // 明るいテーマとして配色を生成する。
      brightness: Brightness.light,
    );

    return MaterialApp(
      // OS側に表示されるアプリ名。
      title: 'Translation Study App',
      // 右上のデバッグ帯は常時隠す。
      debugShowCheckedModeBanner: false,
      // アプリ全体に適用する見た目をここで定義する。
      theme: ThemeData(
        // Material 3準拠の見た目を使う。
        useMaterial3: true,
        // さきほど作った配色をテーマ全体に流し込む。
        colorScheme: colorScheme,
        // 各画面の基本背景色を設定する。
        scaffoldBackgroundColor: colorScheme.surface,
        // AppBar全体の見た目をまとめて設定する。
        appBarTheme: AppBarTheme(
          // AppBarの背景色。少し透けさせて軽さを出す。
          backgroundColor: colorScheme.surface.withValues(alpha: 0.82),
          // Material 3の上に乗る色味を無効化する。
          surfaceTintColor: Colors.transparent,
          // AppBarの影を消してフラットにする。
          elevation: 0,
          // タイトルを中央ではなく左寄せにする。
          centerTitle: false,
          // AppBarタイトル文字の色と大きさと太さを決める。
          titleTextStyle: TextStyle(
            // タイトル文字色。
            color: colorScheme.onSurface,
            // タイトル文字サイズ。
            fontSize: 22,
            // タイトル文字の太さ。
            fontWeight: FontWeight.w700,
          ),
        ),
        // Cardウィジェット共通の見た目を設定する。
        cardTheme: CardThemeData(
          // カードの影の高さ。0でほぼ影なし。
          elevation: 0,
          // カード背景色。少し透けさせる。
          color: colorScheme.surface.withValues(alpha: 0.92),
          // カード上の余計な色味を無効化する。
          surfaceTintColor: Colors.transparent,
          // もし影が出る場合の色を薄く設定する。
          shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
          // カードの形を角丸付きの長方形にする。
          shape: RoundedRectangleBorder(
            // 角の丸み。
            borderRadius: BorderRadius.circular(28),
            // 枠線の色を薄く付ける。
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          // Card自身の外側余白は付けず、必要な場所で個別に余白を持たせる。
          margin: EdgeInsets.zero,
        ),
        // TextFieldなど入力欄の共通デザインを設定する。
        inputDecorationTheme: InputDecorationTheme(
          // 背景色を塗る入力欄にする。
          filled: true,
          // 入力欄の塗り色。
          fillColor: colorScheme.surfaceContainerLowest,
          // 入力欄の内側余白。
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          // デフォルト状態の枠線。
          border: OutlineInputBorder(
            // 枠線の角丸。
            borderRadius: BorderRadius.circular(20),
            // 枠線の色。
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          // 有効だが未フォーカス時の枠線。
          enabledBorder: OutlineInputBorder(
            // 枠線の角丸。
            borderRadius: BorderRadius.circular(20),
            // 枠線の色。
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          // フォーカス中の枠線。
          focusedBorder: OutlineInputBorder(
            // 枠線の角丸。
            borderRadius: BorderRadius.circular(20),
            // フォーカス時だけ主色で少し太く見せる。
            borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
          ),
        ),
        // ElevatedButtonの共通スタイルを設定する。
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // ボタンの影を消す。
            elevation: 0,
            // ボタンの最小高さをそろえる。
            minimumSize: const Size.fromHeight(54),
            // ボタンの形を角丸にする。
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            // ボタン文字のサイズと太さ。
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // OutlinedButtonの共通スタイルを設定する。
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            // ボタンの最小高さをそろえる。
            minimumSize: const Size.fromHeight(54),
            // ボタンの形を角丸にする。
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            // 枠線の色。
            side: BorderSide(color: colorScheme.outlineVariant),
            // ボタン文字のサイズと太さ。
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Chip系ウィジェットの共通スタイルを設定する。
        chipTheme: ChipThemeData(
          // 未選択時の背景色。
          backgroundColor: colorScheme.surfaceContainerLowest,
          // 選択時の背景色。
          selectedColor: colorScheme.primaryContainer,
          // 補助的な選択状態でも同じ背景色を使う。
          secondarySelectedColor: colorScheme.primaryContainer,
          // 枠線の色。
          side: BorderSide(color: colorScheme.outlineVariant),
          // チップ形状を丸いピル型にする。
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          // ラベル文字色。
          labelStyle: TextStyle(color: colorScheme.onSurface),
          // チップ内の余白。
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        // NavigationBarの共通スタイルを設定する。
        navigationBarTheme: NavigationBarThemeData(
          // 下部ナビの背景色。少し透けさせる。
          backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
          // 上に乗る色味を無効化する。
          surfaceTintColor: Colors.transparent,
          // 選択状態に応じてラベル文字の太さを変える。
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            // このラベルが現在選択中かどうか。
            final isSelected = states.contains(WidgetState.selected);
            // 選択中なら少し太く、未選択でも十分読める太さにする。
            return TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            );
          }),
          // 選択中アイテムの背景色。
          indicatorColor: colorScheme.primaryContainer,
        ),
        // Snackbarの共通スタイルを設定する。
        snackBarTheme: SnackBarThemeData(
          // 画面下に浮く表示にする。
          behavior: SnackBarBehavior.floating,
          // Snackbarの背景色。
          backgroundColor: colorScheme.inverseSurface,
          // Snackbar内の文字色。
          contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
          // Snackbarの角丸。
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
