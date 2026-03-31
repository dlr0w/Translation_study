import 'package:flutter/material.dart';

import '../models/translation_history_entry.dart';

// 翻訳履歴1件の詳細表示画面。
class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.entry});

  final TranslationHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('履歴詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: '原文', value: entry.sourceText),
            _DetailRow(label: '訳文', value: entry.translatedText),
            _DetailRow(label: '原言語', value: entry.sourceLanguage),
            _DetailRow(label: '訳言語', value: entry.targetLanguage),
            _DetailRow(
              label: '作成日時',
              value: entry.createdAt.toLocal().toString(),
            ),
          ],
        ),
      ),
    );
  }
}

// 詳細画面の行表示部品（ラベル＋値）。
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
