import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/translation_history_entry.dart';
import '../../utils/language_labels.dart';

// 翻訳履歴一覧を描画する表示専用部品。
class TranslationHistoryList extends StatelessWidget {
  const TranslationHistoryList({
    super.key,
    required this.snapshot,
    required this.onTap,
    this.onFavoriteTap,
  });

  // 非同期読み込み結果。
  final AsyncSnapshot<List<TranslationHistoryEntry>> snapshot;
  // 行タップ時の通知先。
  final ValueChanged<TranslationHistoryEntry> onTap;
  // 星ボタン押下時の通知先。
  final ValueChanged<TranslationHistoryEntry>? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!snapshot.hasData) {
      // まだデータが無い間はローディングだけを見せる。
      return const Center(child: CircularProgressIndicator());
    }

    final histories = snapshot.data!;
    if (histories.isEmpty) {
      // レコードが0件なら空状態を表示する。
      return const Center(child: Text('履歴はまだありません。'));
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: histories.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = histories[index];
        return Material(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onTap(item),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.isFavorite
                          ? Colors.amber.shade100
                          : theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onFavoriteTap == null
                          ? null
                          : () => onFavoriteTap!(item),
                      tooltip: item.isFavorite ? 'お気に入りを解除' : 'お気に入りに追加',
                      icon: Icon(
                        item.isFavorite ? Icons.star : Icons.star_border,
                        color: item.isFavorite
                            ? Colors.amber.shade800
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.sourceText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _buildSubtitle(item),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 一覧の補足情報を2行の文字列へ整形する。
  String _buildSubtitle(TranslationHistoryEntry item) {
    // 表示用の日付へ整形する。
    final formatedDate = DateFormat(
      'yyyy/MM/dd HH:mm',
    ).format(item.createdAt.toLocal());
    // タグ未設定時でも空欄にしない。
    final tagText = item.tags.isEmpty ? 'タグなし' : item.tags.join(', ');
    // 言語コードを画面表示向けの文言へ変換する。
    final sourceLanguage = languageLabelOf(item.sourceLanguage);
    final targetLanguage = languageLabelOf(item.targetLanguage);
    return '$sourceLanguage -> $targetLanguage | $formatedDate\nタグ：$tagText';
  }
}
