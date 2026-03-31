import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../main.dart';
import '../models/translation_history_entry.dart';
import '../repositories/local_history_repository.dart';
import '../services/sync_service.dart';
import '../widgets/app_page_body.dart';
import '../widgets/app_section_title.dart';
import '../widgets/auth_menu_button.dart';
import '../widgets/history_filter_section.dart';
import '../widgets/translation/translation_history_list.dart';
import 'history_detail_screen.dart';

// TODO　部品のファイル分けが必要。
// 翻訳履歴タブの画面。
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

// 履歴画面の状態を管理するState。
class HistoryScreenState extends State<HistoryScreen> {
  // 履歴一覧の読み込みFuture。
  late Future<List<TranslationHistoryEntry>> _historyFuture;
  // タグ候補一覧の読み込みFuture。
  late Future<List<String>> _availableTagsFuture;
  // お気に入りだけを見るかどうか。
  bool _favoritesOnly = false;
  // 選択中の日付条件。
  HistoryDatePreset _selectedDatePreset = HistoryDatePreset.none;
  // 選択中のタグ。
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // 現在の条件でFutureを作り直す。
  void _refreshData() {
    final dateRange = _buildDateRange(_selectedDatePreset);
    _historyFuture = LocalHistoryRepository.instance.all(
      favoritesOnly: _favoritesOnly,
      tag: _selectedTag,
      createdFrom: dateRange.start,
      createdTo: dateRange.end,
    );
    _availableTagsFuture = LocalHistoryRepository.instance.allTags();
  }

  // タブ再選択時に一覧を再読込する。
  void refreshOnTabSelected() {
    if (!mounted) return;
    setState(_refreshData);
  }

  // サインアウト後にフィルターも初期化する。
  Future<void> resetAfterSignOut() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _favoritesOnly = false;
      _selectedDatePreset = HistoryDatePreset.none;
      _selectedTag = null;
      _refreshData();
    });
  }

  // 日付プリセットを検索範囲へ変換する。
  _HistoryDateRange _buildDateRange(HistoryDatePreset preset) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    switch (preset) {
      case HistoryDatePreset.none:
        return const _HistoryDateRange();
      case HistoryDatePreset.today:
        return _HistoryDateRange(start: todayStart, end: tomorrowStart);
      case HistoryDatePreset.last7Days:
        return _HistoryDateRange(
          start: todayStart.subtract(const Duration(days: 6)),
          end: tomorrowStart,
        );
      case HistoryDatePreset.last30Days:
        return _HistoryDateRange(
          start: todayStart.subtract(const Duration(days: 29)),
          end: tomorrowStart,
        );
    }
  }

  // 通知表示を1箇所へ寄せる。
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // 一覧の星ボタンからお気に入りを切り替える。
  Future<void> _toggleFavorite(TranslationHistoryEntry item) async {
    final historyId = item.id;
    if (historyId == null) {
      return;
    }

    final nextFavorite = !item.isFavorite;

    await LocalHistoryRepository.instance.updateHistoryFavorite(
      historyId: historyId,
      isFavorite: nextFavorite,
    );

    if (!mounted) return;

    setState(_refreshData);
    _showSnackBar(
      nextFavorite ? 'お気に入りに追加しました' : 'お気に入りを解除しました',
    );
    unawaited(SyncService.instance.syncQuietly());
  }

  // 詳細画面から戻ったあと一覧を更新する。
  Future<void> _openDetail(TranslationHistoryEntry item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HistoryDetailScreen(entry: item),
      ),
    );

    if (result == true && mounted) {
      setState(_refreshData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('履歴'),
        actions: [
          // 認証状態変化後に履歴一覧を引き直す。
          AuthMenuButton(
            onDataChanged: () async {
              if (client.auth.isAuthenticated) {
                refreshOnTabSelected();
                return;
              }
              await resetAfterSignOut();
            },
          ),
        ],
      ),
      body: AppPageBody(
        maxWidth: 980,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<List<String>>(
              future: _availableTagsFuture,
              builder: (context, snapshot) {
                return HistoryFilterSection(
                  title: '履歴フィルター',
                  favoritesOnly: _favoritesOnly,
                  selectedTag: _selectedTag,
                  selectedDatePreset: _selectedDatePreset,
                  availableTags: snapshot.data ?? const [],
                  onFavoritesOnlyChanged: (value) {
                    setState(() {
                      _favoritesOnly = value;
                      _refreshData();
                    });
                  },
                  onDatePresetChanged: (value) {
                    setState(() {
                      _selectedDatePreset = value;
                      _refreshData();
                    });
                  },
                  onTagChanged: (value) {
                    setState(() {
                      _selectedTag = value;
                      _refreshData();
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<TranslationHistoryEntry>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  final countText = snapshot.hasData
                      ? '${snapshot.data!.length}件'
                      : '読込中...';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '翻訳履歴',
                                      style: AppSectionTitle.styleOf(context),
                                    ),
                                  ],
                                ),
                              ),
                              Chip(label: Text(countText)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TranslationHistoryList(
                              snapshot: snapshot,
                              onTap: _openDetail,
                              onFavoriteTap: _toggleFavorite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 日付検索の開始・終了を束ねるモデル。
class _HistoryDateRange {
  const _HistoryDateRange({
    this.start,
    this.end,
  });

  // 開始時刻。
  final DateTime? start;
  // 終了時刻。
  final DateTime? end;
}
