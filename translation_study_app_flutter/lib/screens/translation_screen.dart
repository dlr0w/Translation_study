import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../main.dart';
import '../models/translation_history_entry.dart';
import '../repositories/local_history_repository.dart';
import '../widgets/app_page_body.dart';
import '../widgets/auth_menu_button.dart';
import '../widgets/translation/language_selector_row.dart';
import '../widgets/translation/translation_history_list.dart';
import 'history_detail_screen.dart';

// TODO　ウィジェットを分解する。
// 翻訳画面のStatefulWidget。
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => TranslationScreenState();
}

// 翻訳実行、結果表示、直近履歴表示をまとめて管理するState。
class TranslationScreenState extends State<TranslationScreen> {
  // UIで選択可能な言語コードと表示名のマップ。
  static const _languageOptions = <String, String>{
    'ja': '日本語',
    'en': '英語',
    'es': 'スペイン語',
    'fr': 'フランス語',
    'de': 'ドイツ語',
    'ko': '韓国語',
    'zh-cn': '中国語 (簡体字)',
  };

  // 原文入力のTextFieldコントローラー。
  final _textController = TextEditingController();
  // 原言語の初期値（日本語）。
  String _sourceLanguage = 'ja';
  // 訳言語の初期値（英語）。
  String _targetLanguage = 'en';
  // 直近の訳文表示用（未翻訳時はnull）。
  String? _translatedText;
  // 現在表示中の翻訳結果に対応する履歴ID。
  int? _currentHistoryId;
  // 現在表示中の翻訳結果のお気に入り状態。
  bool _isCurrentTranslationFavorite = false;
  // 翻訳API実行中かどうか。
  bool _isTranslating = false;
  // お気に入り更新中かどうか。
  bool _isUpdatingFavorite = false;
  // 履歴欄だけに出す同期中表示フラグ。
  bool _isHistorySyncing = false;
  // 履歴一覧を読み込むFuture。
  late Future<List<TranslationHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // 翻訳画面用の直近履歴を最新状態へ更新する。
  void _refreshData() {
    _historyFuture = LocalHistoryRepository.instance.latest(limit: 20);
  }

  // タブ再表示時に、一覧と現在の翻訳結果状態を同期する。
  Future<void> refreshOnTabSelected() async {
    await _refreshCurrentTranslationState();
  }

  // 履歴欄専用の同期中表示を切り替える。
  void setHistorySyncing(bool isSyncing) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isHistorySyncing = isSyncing;
    });
  }

  // ログアウト後に翻訳画面の表示状態を初期化する。
  void resetAfterSignOut() {
    if (!mounted) {
      return;
    }

    setState(() {
      _textController.clear();
      _translatedText = null;
      _currentHistoryId = null;
      _isCurrentTranslationFavorite = false;
      _isHistorySyncing = false;
      _refreshData();
    });
  }

  // 共通のSnackbar表示処理。
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // 現在表示中の翻訳結果状態を保存済み履歴に同期する。
  Future<void> _refreshCurrentTranslationState() async {
    final currentHistoryId = _currentHistoryId;
    TranslationHistoryEntry? currentHistory;

    if (currentHistoryId != null) {
      currentHistory = await LocalHistoryRepository.instance.findHistoryById(
        currentHistoryId,
      );
    }

    if (!mounted) return;

    setState(() {
      _refreshData();
      _currentHistoryId = currentHistory?.id;
      if (currentHistory != null) {
        _isCurrentTranslationFavorite = currentHistory.isFavorite;
      } else {
        _translatedText = null;
      }
    });
  }

  // 現在表示中の訳文をクリップボードへコピーする。
  Future<void> _copyTranslatedText() async {
    final translatedText = _translatedText;
    if (translatedText == null || translatedText.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: translatedText));

    if (!mounted) return;
    _showSnackBar('翻訳結果をコピーしました');
  }

  // 現在表示中の翻訳結果のお気に入り状態を切り替える。
  Future<void> _toggleFavorite() async {
    final currentHistoryId = _currentHistoryId;
    if (currentHistoryId == null || _isUpdatingFavorite) {
      return;
    }

    final nextFavorite = !_isCurrentTranslationFavorite;

    setState(() {
      _isCurrentTranslationFavorite = nextFavorite;
      _isUpdatingFavorite = true;
    });

    try {
      await LocalHistoryRepository.instance.updateHistoryFavorite(
        historyId: currentHistoryId,
        isFavorite: nextFavorite,
      );

      if (!mounted) return;

      setState(() {
        _isUpdatingFavorite = false;
        _refreshData();
      });

      _showSnackBar(
        nextFavorite ? 'お気に入りに追加しました' : 'お気に入りを解除しました',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCurrentTranslationFavorite = !nextFavorite;
        _isUpdatingFavorite = false;
      });

      _showSnackBar('お気に入りの更新に失敗しました: $e');
    }
  }

  // 直近履歴一覧上の星ボタンからお気に入り状態を切り替える。
  Future<void> _toggleHistoryItemFavorite(TranslationHistoryEntry item) async {
    final historyId = item.id;
    if (historyId == null) {
      return;
    }

    final nextFavorite = !item.isFavorite;

    try {
      await LocalHistoryRepository.instance.updateHistoryFavorite(
        historyId: historyId,
        isFavorite: nextFavorite,
      );

      if (!mounted) return;

      setState(() {
        _refreshData();
        if (historyId == _currentHistoryId) {
          _isCurrentTranslationFavorite = nextFavorite;
        }
      });

      _showSnackBar(
        nextFavorite ? 'お気に入りに追加しました' : 'お気に入りを解除しました',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('お気に入りの更新に失敗しました: $e');
    }
  }

  // 翻訳ボタン押下時の処理本体。
  Future<void> _translate() async {
    if (_isTranslating) return;

    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('原文を入力してください。');
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final result = await client.translation.translate(
        text: text,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      final history = TranslationHistoryEntry(
        sourceText: result.sourceText,
        translatedText: result.translatedText,
        sourceLanguage: result.sourceLanguage,
        targetLanguage: result.targetLanguage,
        createdAt: result.createdAt,
      );

      final historyId = await LocalHistoryRepository.instance.addHistory(
        history,
      );

      if (!mounted) return;
      setState(() {
        _translatedText = result.translatedText;
        _currentHistoryId = historyId;
        _isCurrentTranslationFavorite = false;
        _refreshData();
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('翻訳に失敗しました: $e');
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 訳文が出ている間だけコピー操作を有効にする。
    final hasTranslatedText =
        _translatedText != null && _translatedText!.isNotEmpty;
    // 各所で使う配色と文字スタイルをまとめて取る。
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('翻訳'),
        actions: [
          AuthMenuButton(
            onDataChanged: () async {
              // 認証変化後に、手元の履歴と表示中の結果を整合させる。
              if (!mounted) {
                return;
              }
              if (!client.auth.isAuthenticated) {
                resetAfterSignOut();
                return;
              }
              if (_currentHistoryId == null) {
                setState(_refreshData);
                return;
              }
              await _refreshCurrentTranslationState();
            },
          ),
        ],
      ),
      body: AppPageBody(
        maxWidth: 1120,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 横幅が十分あるときは翻訳欄と履歴欄を横並びにする。
            final isWide = constraints.maxWidth >= 900;

            // 翻訳入力から結果表示までをまとめた主カード。
            final translateCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '翻訳',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LanguageSelectorRow(
                      languageOptions: _languageOptions,
                      sourceLanguage: _sourceLanguage,
                      targetLanguage: _targetLanguage,
                      onSourceChanged: (value) {
                        // 翻訳元言語を切り替える。
                        setState(() {
                          _sourceLanguage = value;
                        });
                      },
                      onTargetChanged: (value) {
                        // 翻訳先言語を切り替える。
                        setState(() {
                          _targetLanguage = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: '原文',
                        hintText: '翻訳したい文章を入力',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _isTranslating ? null : _translate,
                      icon: Icon(
                        _isTranslating
                            ? Icons.hourglass_top
                            : Icons.auto_awesome,
                      ),
                      label: Text(_isTranslating ? '翻訳中...' : '翻訳する'),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.75,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '翻訳内容',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 現在表示中の結果だけをお気に入り操作できる。
                            IconButton.filledTonal(
                              onPressed:
                                  (_currentHistoryId == null ||
                                      _isUpdatingFavorite)
                                  ? null
                                  : _toggleFavorite,
                              tooltip: _isCurrentTranslationFavorite
                                  ? 'お気に入りを解除'
                                  : 'お気に入りに追加',
                              icon: Icon(
                                _isCurrentTranslationFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 訳文があるときだけコピーを許可する。
                            IconButton.filledTonal(
                              onPressed: hasTranslatedText
                                  ? _copyTranslatedText
                                  : null,
                              tooltip: 'コピー',
                              icon: const Icon(Icons.copy_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ResultPanel(
                      text: _translatedText,
                      placeholder: '訳文がここに表示されます',
                    ),
                  ],
                ),
              ),
            );

            // 直近履歴の閲覧と詳細遷移をまとめた部品。
            final historyCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '最近の翻訳履歴',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Chip(label: Text('最新20件')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Stack(
                        children: [
                          // 非同期で直近履歴を読み込み、一覧部品へ渡す。
                          Positioned.fill(
                            child: FutureBuilder<List<TranslationHistoryEntry>>(
                              future: _historyFuture,
                              builder: (context, snapshot) {
                                return TranslationHistoryList(
                                  snapshot: snapshot,
                                  onFavoriteTap: _toggleHistoryItemFavorite,
                                  onTap: (item) {
                                    // 詳細編集から戻ったら、現在表示中の結果も含めて再同期する。
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute<bool>(
                                            builder: (_) => HistoryDetailScreen(
                                              entry: item,
                                            ),
                                          ),
                                        )
                                        .then((result) {
                                          if (result == true && mounted) {
                                            _refreshCurrentTranslationState();
                                          }
                                        });
                                  },
                                );
                              },
                            ),
                          ),
                          if (_isHistorySyncing)
                            // タブ全体の同期中でも、ここでは履歴欄だけローディングを重ねる。
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withValues(
                                      alpha: 0.82,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (isWide) {
              // デスクトップ幅では左右2カラムに分ける。
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [translateCard],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 9,
                    child: SizedBox(
                      height: 760,
                      child: historyCard,
                    ),
                  ),
                ],
              );
            }

            // 画面が狭い場合は縦積みで順に見せる。
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                translateCard,
                const SizedBox(height: 20),
                SizedBox(
                  height: 420,
                  child: historyCard,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// 訳文表示欄の見た目だけを切り出した部品。
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.text,
    required this.placeholder,
  });

  final String? text;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      // ドット模様をクリップしてカード内だけに閉じ込める。
      borderRadius: BorderRadius.circular(28),
      child: CustomPaint(
        painter: _DotPatternPainter(
          dotColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              text ?? placeholder,
              style: theme.textTheme.titleMedium?.copyWith(
                height: 1.55,
                color: text == null ? theme.colorScheme.onSurfaceVariant : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 結果欄の背景部品。
class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter({
    required this.dotColor,
  });

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const spacing = 18.0;
    const radius = 1.1;

    // 一定間隔で小さな円を並べ、単調すぎない背景を作る。
    for (double y = 10; y < size.height; y += spacing) {
      for (double x = 10; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) {
    // 色が変わったときだけ描き直す。
    return oldDelegate.dotColor != dotColor;
  }
}
