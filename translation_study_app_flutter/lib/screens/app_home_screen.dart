import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../main.dart';
import '../services/sync_service.dart';
import 'history_screen.dart';
import 'review_screen.dart';
import 'translation_screen.dart';

// 3タブを束ねるホーム画面。
class AppHomeScreen extends StatefulWidget {
  // 画面保持用にkeyを受け取る。
  const AppHomeScreen({super.key});

  // 対応するStateを生成する。
  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

// 現在タブと認証変化を管理するState。
class _AppHomeScreenState extends State<AppHomeScreen> {
  // 現在表示中のタブ番号。
  int _selectedIndex = 0;
  // 翻訳タブの状態への参照。
  final _translationScreenKey = GlobalKey<TranslationScreenState>();
  // 履歴タブの状態への参照。
  final _historyScreenKey = GlobalKey<HistoryScreenState>();
  // 復習タブの状態への参照。
  final _reviewScreenKey = GlobalKey<ReviewScreenState>();
  // 認証状態の差分検知に使う前回値。
  late bool _wasAuthenticated;

  // インデックス順に並べたタブ画面一覧。
  late final List<Widget> _pages = <Widget>[
    // 0番は翻訳画面。
    TranslationScreen(key: _translationScreenKey),
    // 1番は履歴画面。
    HistoryScreen(key: _historyScreenKey),
    // 2番は復習画面。
    ReviewScreen(key: _reviewScreenKey),
  ];

  @override
  void initState() {
    super.initState();
    _wasAuthenticated = client.auth.isAuthenticated;
    client.auth.authInfoListenable.addListener(_handleAuthStateChanged);

    if (_wasAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncAndRefreshAll();
      });
    }
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_handleAuthStateChanged);
    super.dispose();
  }

  // 指定タブだけを再読み込みする。
  void _refreshSelectedTab(int index) {
    switch (index) {
      case 0:
        _translationScreenKey.currentState?.refreshOnTabSelected();
        break;
      case 1:
        _historyScreenKey.currentState?.refreshOnTabSelected();
        break;
      case 2:
        _reviewScreenKey.currentState?.refreshOnTabSelected();
        break;
    }
  }

  // 全タブ再読み込みする。
  void _refreshAllTabs() {
    _translationScreenKey.currentState?.refreshOnTabSelected();
    _historyScreenKey.currentState?.refreshOnTabSelected();
    _reviewScreenKey.currentState?.refreshOnTabSelected();
  }

  // 認証状態が変わったときの処理をまとめる。
  void _handleAuthStateChanged() {
    final isAuthenticated = client.auth.isAuthenticated;
    if (_wasAuthenticated == isAuthenticated) {
      return;
    }

    _wasAuthenticated = isAuthenticated;

    if (isAuthenticated) {
      _syncAndRefreshAll();
      return;
    }

    if (!mounted) {
      return;
    }
    _refreshAllTabs();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) {
        return;
      }
      _refreshAllTabs();
    });
  }

  // サーバー同期後に全タブ表示を更新する。
  Future<void> _syncAndRefreshAll() async {
    _translationScreenKey.currentState?.setHistorySyncing(true);

    try {
      await SyncService.instance.syncQuietly();
      if (!mounted) {
        return;
      }
      _refreshAllTabs();
    } finally {
      _translationScreenKey.currentState?.setHistorySyncing(false);
    }
  }

  // タブ本体と下部ナビゲーションを構築する。
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // IndexedStackで非表示タブの状態も保持する。
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // 下部ナビゲーションでタブを切り替える。
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: NavigationBar(
                height: 72,
                // 選択中タブをUIに反映する。
                selectedIndex: _selectedIndex,
                // タブ選択後は表示更新と再読込を行う。
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  // 開いたタブだけ最新表示へ寄せる。
                  _refreshSelectedTab(index);
                },
                // 3つのタブ項目。
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.translate_outlined),
                    selectedIcon: Icon(Icons.translate),
                    label: '翻訳',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: '履歴',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.quiz_outlined),
                    selectedIcon: Icon(Icons.quiz),
                    label: '復習',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
