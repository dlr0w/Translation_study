import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../main.dart';
import '../repositories/local_history_repository.dart';
import '../screens/sign_in_screen.dart';

// ポップアップメニューから選ばれる操作。
enum _AuthMenuAction {
  signIn,
  signOut,
}

// 各画面のAppBarで使う共通認証メニュー。
class AuthMenuButton extends StatelessWidget {
  const AuthMenuButton({
    super.key,
    this.onDataChanged,
  });

  // サインイン/サインアウト後に親へ再読込を促す。
  final Future<void> Function()? onDataChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: client.auth.authInfoListenable,
      builder: (context, _) {
        final isAuthenticated = client.auth.isAuthenticated;
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        return PopupMenuButton<_AuthMenuAction>(
          // 認証済みかどうかでメニュー内容を切り替える。
          tooltip: isAuthenticated ? 'アカウント' : 'ログイン',
          onSelected: (action) async {
            switch (action) {
              case _AuthMenuAction.signIn:
                final didSignIn =
                    await navigator.push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => const SignInScreen(),
                      ),
                    ) ??
                    false;

                if (!navigator.mounted || !didSignIn) {
                  return;
                }

                if (!messenger.mounted) {
                  return;
                }
                _showSnackBar(messenger, 'ログインしました');
                break;
              case _AuthMenuAction.signOut:
                await LocalHistoryRepository.instance.clearStudyData();
                await client.auth.signOutDevice();
                if (!messenger.mounted) {
                  return;
                }
                await onDataChanged?.call();
                _showSnackBar(messenger, 'ログアウトしました');
                break;
            }
          },
          itemBuilder: (context) {
            if (!isAuthenticated) {
              return const [
                PopupMenuItem<_AuthMenuAction>(
                  value: _AuthMenuAction.signIn,
                  child: Text('ログイン'),
                ),
              ];
            }

            return const [
              PopupMenuItem<_AuthMenuAction>(
                value: _AuthMenuAction.signOut,
                child: Text('ログアウト'),
              ),
            ];
          },
          icon: Icon(
            isAuthenticated
                ? Icons.account_circle
                : Icons.account_circle_outlined,
          ),
        );
      },
    );
  }

  // どの画面でも同じ出し方で通知する。
  void _showSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
