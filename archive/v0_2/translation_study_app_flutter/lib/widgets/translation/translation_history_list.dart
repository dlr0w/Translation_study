import 'package:flutter/material.dart';

import '../../models/translation_history_entry.dart';

// 翻訳履歴一覧の表示専用ウィジェット。
class TranslationHistoryList extends StatelessWidget {
  const TranslationHistoryList({
    super.key,
    required this.snapshot,
    required this.onTap,
  });

  final AsyncSnapshot<List<TranslationHistoryEntry>> snapshot;
  final ValueChanged<TranslationHistoryEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final histories = snapshot.data!;
    if (histories.isEmpty) {
      return const Center(child: Text('履歴はまだありません。'));
    }

    return ListView.separated(
      itemCount: histories.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = histories[index];
        return ListTile(
          title: Text(
            item.sourceText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${item.sourceLanguage} -> ${item.targetLanguage} | ${item.createdAt.toLocal()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}
