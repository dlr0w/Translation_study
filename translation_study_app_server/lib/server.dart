import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// Serverpodサーバーの初期化と起動をまとめる。
void run(List<String> args) async {
  // 生成済みprotocolとendpoint定義を束ねてServerpodを作る。
  final pod = Serverpod(args, Protocol(), Endpoints());

  // 認証サービスを初期化し、利用可能なログイン方式を登録する。
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // サーバー向けアクセストークンはJWTで扱う。
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // メールアドレスとパスワードでの認証を有効にする。
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  // `/`と`/index.html`へトップページを割り当てる。
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // `web/static`配下の静的ファイルをそのまま配信する。
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Flutter Webが読む設定JSONを配信する。
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Flutter Webビルド成果物があれば`/app`で配信する。
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // `/app`以下をFlutter Webアプリへ割り当てる。
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // 未ビルドなら案内用HTMLを返す。
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // 最後にサーバーを起動する。
  await pod.start();
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // 本来はここでメール送信するが、現状はログ出力だけにしている。
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // 本来はここでメール送信するが、現状はログ出力だけにしている。
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}
