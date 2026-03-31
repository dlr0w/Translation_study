import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../main.dart';
import '../widgets/app_page_body.dart';

// 必要なタイミングだけ開くサインイン画面。
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: AppPageBody(
        maxWidth: 520,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SignInWidget(
                client: client,
                // 認証成功を呼び出し元へ返す。
                onAuthenticated: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
