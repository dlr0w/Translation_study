import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../main.dart';
import '../models/review_result_entry.dart';
import '../models/review_summary.dart';
import '../models/translation_history_entry.dart';
import '../repositories/local_history_repository.dart';
import '../services/sync_service.dart';
import '../utils/language_labels.dart';
import '../widgets/app_page_body.dart';
import '../widgets/app_section_title.dart';
import '../widgets/auth_menu_button.dart';
import '../widgets/filter_pill_wrap.dart';
import 'history_detail_screen.dart';

// TODO　行数が長くなっているので、ウィジェットを分解する。
// 復習タブ全体を担当する画面。
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => ReviewScreenState();
}

// 復習画面の入力状態と進行状態を管理するState。
class ReviewScreenState extends State<ReviewScreen> {
  // 出題順シャッフルとセッションID生成に使う。
  final _random = Random();

  // 現在使えるタグ候補。
  List<String> _availableTags = const [];
  // 現在のフィルター条件に合う候補。
  List<TranslationHistoryEntry> _filteredHistories = const [];
  // 今回のセッションで出す問題一覧。
  List<TranslationHistoryEntry> _sessionQuestions = const [];
  // 今回セッションの採点結果。
  List<_AnsweredReviewItem> _sessionResults = const [];
  // 直近で完了したセッションの結果。
  List<_AnsweredReviewItem> _latestCompletedResults = const [];
  // 復習全体の集計。
  ReviewSummary _summary = const ReviewSummary(
    translationCount: 0,
    reviewCount: 0,
    correctCount: 0,
    partialCount: 0,
    incorrectCount: 0,
  );

  // 初回データ読み込み中フラグ。
  bool _isLoading = true;
  // 回答保存中フラグ。
  bool _isSavingResult = false;
  // お気に入りだけ出題するかどうか。
  bool _favoritesOnly = false;
  // 選択中タグ集合。
  Set<String> _selectedTags = <String>{};
  // 選択中の日付条件。
  _ReviewDatePreset _selectedDatePreset = _ReviewDatePreset.none;
  // 現在の画面フェーズ。
  _ReviewPhase _phase = _ReviewPhase.setup;
  // 現在見ている問題番号。
  int _currentQuestionIndex = 0;
  // カード裏面を表示中かどうか。
  bool _isAnswerShown = false;
  // 現在進行中セッションのID。
  String? _activeSessionId;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  // タブ再選択時に必要なデータを読み直す。
  Future<void> refreshOnTabSelected() async {
    if (_phase == _ReviewPhase.study) {
      return;
    }
    await _loadOverviewData();
  }

  // サインアウト後にフィルターと進行状態を初期化する。
  Future<void> resetAfterSignOut() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _favoritesOnly = false;
      _selectedTags = <String>{};
      _selectedDatePreset = _ReviewDatePreset.none;
      _phase = _ReviewPhase.setup;
      _sessionQuestions = const [];
      _sessionResults = const [];
      _latestCompletedResults = const [];
      _currentQuestionIndex = 0;
      _isAnswerShown = false;
      _activeSessionId = null;
    });
    await _loadOverviewData();
  }

  // 現在の条件に合う問題候補と集計を読み込む。
  Future<void> _loadOverviewData() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dateRange = _buildDateRange(_selectedDatePreset);
    final histories = await LocalHistoryRepository.instance.all(
      favoritesOnly: _favoritesOnly,
      tags: _selectedTags.toList(),
      createdFrom: dateRange.start,
      createdTo: dateRange.end,
    );
    final availableTags = await LocalHistoryRepository.instance.allTags();
    final summary = await LocalHistoryRepository.instance.getReviewSummary();

    if (!mounted) {
      return;
    }

    setState(() {
      _filteredHistories = histories;
      _availableTags = availableTags;
      _summary = summary;
      _selectedTags = _selectedTags.intersection(availableTags.toSet());
      _isLoading = false;
    });
  }

  // 画面内通知を1箇所へ寄せる。
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // 指定候補を使って新しい出題セッションを始める。
  void _startSession(List<TranslationHistoryEntry> histories) {
    if (histories.isEmpty) {
      return;
    }

    final questions = List<TranslationHistoryEntry>.from(histories)
      ..shuffle(_random);

    setState(() {
      _phase = _ReviewPhase.study;
      _sessionQuestions = questions;
      _sessionResults = const [];
      _currentQuestionIndex = 0;
      _isAnswerShown = false;
      _isSavingResult = false;
      _activeSessionId = _createSessionId();
    });
  }

  // 現在のフィルター条件で通常出題を始める。
  void _startReview() {
    _startSession(_filteredHistories);
  }

  // 直近セッションで不正解だった問題だけを再出題する。
  void _startIncorrectRetry() {
    final incorrectHistories = _latestCompletedResults
        .where((item) => item.grade == ReviewGrade.incorrect)
        .map((item) => item.history)
        .toList();

    _startSession(incorrectHistories);
  }

  // 現在表示対象の問題を返す。
  TranslationHistoryEntry? get _currentQuestion {
    if (_sessionQuestions.isEmpty) {
      return null;
    }
    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= _sessionQuestions.length) {
      return null;
    }
    return _sessionQuestions[_currentQuestionIndex];
  }

  // カードの表裏表示を切り替える。
  void _toggleAnswerVisibility() {
    setState(() {
      _isAnswerShown = !_isAnswerShown;
    });
  }

  // 自己採点を保存し、次問題か結果画面へ進める。
  Future<void> _recordAnswer(ReviewGrade grade) async {
    final question = _currentQuestion;
    final sessionId = _activeSessionId;

    if (question == null || question.id == null || sessionId == null) {
      return;
    }
    if (_isSavingResult) {
      return;
    }

    setState(() {
      _isSavingResult = true;
    });

    final result = ReviewResultEntry(
      historyId: question.id!,
      answerText: '',
      grade: grade,
      reviewedAt: DateTime.now(),
      sessionId: sessionId,
    );

    try {
      await LocalHistoryRepository.instance.addReviewResult(result);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSavingResult = false;
      });
      _showSnackBar('回答結果の保存に失敗しました: $error');
      return;
    }

    final summary = await LocalHistoryRepository.instance.getReviewSummary();

    if (!mounted) {
      return;
    }

    final nextResults = [
      ..._sessionResults,
      _AnsweredReviewItem(history: question, grade: grade),
    ];
    final isLastQuestion =
        _currentQuestionIndex >= _sessionQuestions.length - 1;

    setState(() {
      _summary = summary;
      _sessionResults = nextResults;
      _latestCompletedResults = nextResults;
      _isSavingResult = false;
      _isAnswerShown = false;

      if (isLastQuestion) {
        _phase = _ReviewPhase.result;
        _activeSessionId = null;
      } else {
        _currentQuestionIndex += 1;
      }
    });

    if (isLastQuestion) {
      unawaited(SyncService.instance.syncQuietly());
    }
  }

  // 条件設定フェーズへ戻る。
  Future<void> _returnToSetup() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _phase = _ReviewPhase.setup;
      _sessionQuestions = const [];
      _sessionResults = const [];
      _currentQuestionIndex = 0;
      _isAnswerShown = false;
      _activeSessionId = null;
    });
    await _loadOverviewData();
  }

  // 出題途中で戻る前に確認ダイアログを出す。
  Future<void> _confirmReturnToSetup() async {
    if (_phase != _ReviewPhase.study) {
      await _returnToSetup();
      return;
    }

    final shouldReturn = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('中断しますか？'),
          content: const Text('現在の回答状況は保存されません。条件設定画面へ戻りますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('戻る'),
            ),
          ],
        );
      },
    );

    if (shouldReturn == true) {
      await _returnToSetup();
    }
  }

  // お気に入り条件を切り替える。
  Future<void> _setFavoritesOnly(bool value) async {
    setState(() {
      _favoritesOnly = value;
    });
    await _loadOverviewData();
  }

  // 日付条件を切り替える。
  Future<void> _setDatePreset(_ReviewDatePreset value) async {
    setState(() {
      _selectedDatePreset = value;
    });
    await _loadOverviewData();
  }

  // タグの選択状態を切り替える。
  Future<void> _toggleTag(String tag) async {
    final nextTags = Set<String>.from(_selectedTags);
    if (nextTags.contains(tag)) {
      nextTags.remove(tag);
    } else {
      nextTags.add(tag);
    }

    setState(() {
      _selectedTags = nextTags;
    });
    await _loadOverviewData();
  }

  // 履歴詳細を開き、戻ったら手元の一覧へ反映する。
  Future<void> _openHistoryDetail(TranslationHistoryEntry item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HistoryDetailScreen(entry: item),
      ),
    );

    if (result != true || !mounted) {
      return;
    }

    final historyId = item.id;
    if (historyId != null) {
      final refreshed = await LocalHistoryRepository.instance.findHistoryById(
        historyId,
      );
      if (!mounted) {
        return;
      }
      if (refreshed != null) {
        setState(() {
          _filteredHistories = _replaceHistoryInList(
            _filteredHistories,
            refreshed,
          );
          _sessionQuestions = _replaceHistoryInList(
            _sessionQuestions,
            refreshed,
          );
          _sessionResults = _replaceHistoryInAnsweredItems(
            _sessionResults,
            refreshed,
          );
          _latestCompletedResults = _replaceHistoryInAnsweredItems(
            _latestCompletedResults,
            refreshed,
          );
        });
      }
    }

    await _loadOverviewData();
  }

  // 出題件数を含む開始ボタンラベル。
  String get _startButtonLabel => '${_filteredHistories.length}件出題';

  // 直近セッションの不正解数。
  int get _latestIncorrectCount => _latestCompletedResults
      .where((item) => item.grade == ReviewGrade.incorrect)
      .length;

  // 日付のセットを検索範囲へ変換する。
  _ReviewDateRange _buildDateRange(_ReviewDatePreset preset) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    switch (preset) {
      case _ReviewDatePreset.none:
        return const _ReviewDateRange();
      case _ReviewDatePreset.today:
        return _ReviewDateRange(start: todayStart, end: tomorrowStart);
      case _ReviewDatePreset.last7Days:
        return _ReviewDateRange(
          start: todayStart.subtract(const Duration(days: 6)),
          end: tomorrowStart,
        );
      case _ReviewDatePreset.last30Days:
        return _ReviewDateRange(
          start: todayStart.subtract(const Duration(days: 29)),
          end: tomorrowStart,
        );
    }
  }

  // セッション識別用IDを生成する。
  String _createSessionId() {
    final randomValue = _random.nextInt(1 << 30);
    return '${DateTime.now().microsecondsSinceEpoch}-$randomValue';
  }

  // 履歴一覧内の同一ID項目を更新版へ差し替える。
  List<TranslationHistoryEntry> _replaceHistoryInList(
    List<TranslationHistoryEntry> source,
    TranslationHistoryEntry updated,
  ) {
    return source
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
  }

  // 採点結果一覧内の履歴だけ最新内容へ差し替える。
  List<_AnsweredReviewItem> _replaceHistoryInAnsweredItems(
    List<_AnsweredReviewItem> source,
    TranslationHistoryEntry updated,
  ) {
    return source
        .map(
          (item) => item.history.id == updated.id
              ? _AnsweredReviewItem(history: updated, grade: item.grade)
              : item,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _phase == _ReviewPhase.study
            ? IconButton(
                onPressed: _confirmReturnToSetup,
                icon: const Icon(Icons.arrow_back),
                tooltip: '条件設定へ戻る',
              )
            : null,
        title: const Text('復習'),
        actions: [
          AuthMenuButton(
            onDataChanged: () async {
              if (client.auth.isAuthenticated) {
                if (_phase != _ReviewPhase.study) {
                  await _loadOverviewData();
                }
                return;
              }
              await resetAfterSignOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AppPageBody(
              maxWidth: 980,
              child: switch (_phase) {
                _ReviewPhase.setup => _buildSetupView(),
                _ReviewPhase.study => _buildStudyView(),
                _ReviewPhase.result => _buildResultView(),
              },
            ),
    );
  }

  // 条件設定フェーズのUIを構築する。
  Widget _buildSetupView() {
    final hasQuestions = _filteredHistories.isNotEmpty;
    final canRetryIncorrect = _latestIncorrectCount > 0;

    return ListView(
      children: [
        _SummaryCard(summary: _summary),
        const SizedBox(height: 16),
        _ReviewFilterCard(
          favoritesOnly: _favoritesOnly,
          selectedDatePreset: _selectedDatePreset,
          selectedTags: _selectedTags,
          availableTags: _availableTags,
          onFavoritesOnlyChanged: _setFavoritesOnly,
          onDatePresetChanged: _setDatePreset,
          onTagToggled: _toggleTag,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '出題対象: ${_filteredHistories.length}件',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: hasQuestions ? _startReview : null,
                  child: Text(_startButtonLabel),
                ),
                if (canRetryIncorrect) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _startIncorrectRetry,
                    child: Text('今回の×だけ復習 ($_latestIncorrectCount件)'),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!hasQuestions) ...[
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '条件に一致する翻訳履歴がありません。日付・タグ・お気に入り条件を見直してください。',
              ),
            ),
          ),
        ],
      ],
    );
  }

  // 出題中フェーズのUIを構築する。
  Widget _buildStudyView() {
    final question = _currentQuestion;
    if (question == null) {
      return const Center(child: Text('出題できる問題がありません。'));
    }
    final scheme = Theme.of(context).colorScheme;

    final progress = (_currentQuestionIndex + 1) / _sessionQuestions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '問題 ${_currentQuestionIndex + 1} / ${_sessionQuestions.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 16),
        Text(
          '${languageLabelOf(question.sourceLanguage)} -> ${languageLabelOf(question.targetLanguage)}',
        ),
        const SizedBox(height: 8),
        if (question.isFavorite || question.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (question.isFavorite) const Chip(label: Text('お気に入り')),
              ...question.tags.map((tag) => Chip(label: Text(tag))),
            ],
          ),
        const SizedBox(height: 16),
        Expanded(
          child: _FlashCard(
            question: question,
            isAnswerShown: _isAnswerShown,
            onTap: _toggleAnswerVisibility,
          ),
        ),
        const SizedBox(height: 16),
        if (_isAnswerShown)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSavingResult
                      ? null
                      : () => _recordAnswer(ReviewGrade.correct),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                  child: const Text('○'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSavingResult
                      ? null
                      : () => _recordAnswer(ReviewGrade.incorrect),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  ),
                  child: const Text('×'),
                ),
              ),
            ],
          )
        else
          const Text(
            'カードをタップして表裏を切り替えてください。',
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  // 結果フェーズのUIを構築する。
  Widget _buildResultView() {
    final correctItems = _sessionResults
        .where((item) => item.grade == ReviewGrade.correct)
        .toList();
    final incorrectItems = _sessionResults
        .where((item) => item.grade == ReviewGrade.incorrect)
        .toList();

    return ListView(
      children: [
        const Text(
          'お疲れ様でした。',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _SessionSummaryCard(
          totalCount: _sessionResults.length,
          correctCount: correctItems.length,
          incorrectCount: incorrectItems.length,
        ),
        const SizedBox(height: 16),
        if (incorrectItems.isNotEmpty)
          ElevatedButton(
            onPressed: _startIncorrectRetry,
            child: Text('今回の×だけ復習 (${incorrectItems.length}件)'),
          ),
        if (incorrectItems.isNotEmpty) const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _returnToSetup,
          child: const Text('条件設定に戻る'),
        ),
        const SizedBox(height: 16),
        _ReviewResultSection(
          title: '正解一覧',
          emptyMessage: '正解はありません。',
          items: correctItems,
          onTap: _openHistoryDetail,
        ),
        const SizedBox(height: 16),
        _ReviewResultSection(
          title: '不正解一覧',
          emptyMessage: '不正解はありません。',
          items: incorrectItems,
          onTap: _openHistoryDetail,
        ),
      ],
    );
  }
}

// 出題条件入力カード。
class _ReviewFilterCard extends StatelessWidget {
  const _ReviewFilterCard({
    required this.favoritesOnly,
    required this.selectedDatePreset,
    required this.selectedTags,
    required this.availableTags,
    required this.onFavoritesOnlyChanged,
    required this.onDatePresetChanged,
    required this.onTagToggled,
  });

  // お気に入り条件。
  final bool favoritesOnly;
  // 日付条件。
  final _ReviewDatePreset selectedDatePreset;
  // 現在選択中のタグ。
  final Set<String> selectedTags;
  // タグ候補一覧。
  final List<String> availableTags;
  // お気に入り条件変更時の通知先。
  final ValueChanged<bool> onFavoritesOnlyChanged;
  // 日付条件変更時の通知先。
  final ValueChanged<_ReviewDatePreset> onDatePresetChanged;
  // タグ選択変更時の通知先。
  final ValueChanged<String> onTagToggled;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSectionTitle('出題条件'),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('お気に入りのみ'),
              value: favoritesOnly,
              onChanged: onFavoritesOnlyChanged,
            ),
            const SizedBox(height: 8),
            const Text(
              '翻訳した日',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FilterPillWrap<_ReviewDatePreset>(
              options: _ReviewDatePreset.values
                  .map(
                    (preset) => FilterPillOption(
                      value: preset,
                      label: preset.label,
                    ),
                  )
                  .toList(),
              selectedValue: selectedDatePreset,
              onSelected: onDatePresetChanged,
            ),
            const SizedBox(height: 16),
            const Text(
              'タグ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (availableTags.isEmpty)
              const Text('利用できるタグはまだありません。')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTags
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: selectedTags.contains(tag),
                        onSelected: (_) => onTagToggled(tag),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// 表面と裏面を切り替えるフラッシュカード。
class _FlashCard extends StatelessWidget {
  const _FlashCard({
    required this.question,
    required this.isAnswerShown,
    required this.onTap,
  });

  // 表示中の問題。
  final TranslationHistoryEntry question;
  // 裏面を見せるかどうか。
  final bool isAnswerShown;
  // タップ時の切り替え処理。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final targetAngle = isAnswerShown ? pi : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetAngle),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOut,
      builder: (context, angle, child) {
        final showFrontSide = angle <= pi / 2;
        final displayAngle = showFrontSide ? angle : angle - pi;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(displayAngle),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: _FlashCardFace(
                title: showFrontSide ? '原文' : '訳文',
                text: showFrontSide
                    ? question.sourceText
                    : question.translatedText,
                hint: showFrontSide ? 'タップして答えを見る' : 'もう一度タップで表面に戻る',
                colors: showFrontSide
                    ? [Colors.blue.shade50, Colors.white]
                    : [Colors.teal.shade50, Colors.white],
              ),
            ),
          ),
        );
      },
    );
  }
}

// フラッシュカード片面の見た目を作る部品。
class _FlashCardFace extends StatelessWidget {
  const _FlashCardFace({
    required this.title,
    required this.text,
    required this.hint,
    required this.colors,
  });

  // 片面のタイトル。
  final String title;
  // 片面の本文。
  final String text;
  // 下部に出す案内文。
  final String hint;
  // 背景グラデーション色。
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                text,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Text(
            hint,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// 正解一覧・不正解一覧を表示する部品。
class _ReviewResultSection extends StatelessWidget {
  const _ReviewResultSection({
    required this.title,
    required this.emptyMessage,
    required this.items,
    required this.onTap,
  });

  // セクション名。
  final String title;
  // 空状態メッセージ。
  final String emptyMessage;
  // 表示対象の結果一覧。
  final List<_AnsweredReviewItem> items;
  // 行タップ時の通知先。
  final ValueChanged<TranslationHistoryEntry> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionTitle('$title (${items.length}件)'),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(emptyMessage)
            else
              ...items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item.grade == ReviewGrade.correct
                        ? Icons.circle_outlined
                        : Icons.close,
                  ),
                  title: Text(
                    item.history.sourceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.history.translatedText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onTap(item.history),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 復習全体の集計表示カード。
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final ratePercent = (summary.correctRate * 100).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionTitle('学習統計'),
            const SizedBox(height: 8),
            Text('翻訳回数: ${summary.translationCount}'),
            Text('復習回数: ${summary.reviewCount}'),
            Text('正解率: $ratePercent%'),
            Text(
              '内訳: ◯${summary.correctCount} / △${summary.partialCount} / ×${summary.incorrectCount}',
            ),
          ],
        ),
      ),
    );
  }
}

// 今回セッションだけの結果サマリーカード。
class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({
    required this.totalCount,
    required this.correctCount,
    required this.incorrectCount,
  });

  final int totalCount;
  final int correctCount;
  final int incorrectCount;

  @override
  Widget build(BuildContext context) {
    final rate = totalCount == 0 ? 0 : (correctCount / totalCount) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今回の出題: $totalCount件'),
            Text('正解: $correctCount件'),
            Text('不正解: $incorrectCount件'),
            Text('正解率: ${rate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}

// 1問ぶんの採点結果を保持するモデル。
class _AnsweredReviewItem {
  const _AnsweredReviewItem({
    required this.history,
    required this.grade,
  });

  // 採点対象の翻訳履歴。
  final TranslationHistoryEntry history;
  // 自己採点結果。
  final ReviewGrade grade;
}

// 復習画面の表示フェーズ。
enum _ReviewPhase {
  setup,
  study,
  result,
}

// 出題条件で選べる日付プリセット。
enum _ReviewDatePreset {
  none('指定なし'),
  today('今日'),
  last7Days('過去7日'),
  last30Days('過去30日');

  const _ReviewDatePreset(this.label);

  // 画面表示ラベル。
  final String label;
}

// 日付フィルター用の開始・終了を束ねるモデル。
class _ReviewDateRange {
  const _ReviewDateRange({
    this.start,
    this.end,
  });

  // 開始時刻。
  final DateTime? start;
  // 終了時刻。
  final DateTime? end;
}
