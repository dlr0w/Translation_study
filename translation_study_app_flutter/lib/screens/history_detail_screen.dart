import 'dart:async';

import 'package:flutter/material.dart';

import '../models/translation_history_entry.dart';
import '../repositories/local_history_repository.dart';
import '../services/sync_service.dart';
import '../utils/language_labels.dart';
import '../widgets/app_page_body.dart';

// 翻訳履歴1件の詳細と編集画面。
class HistoryDetailScreen extends StatefulWidget {
  const HistoryDetailScreen({super.key, required this.entry});

  // 表示対象の履歴。
  final TranslationHistoryEntry entry;

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

// 詳細画面の編集状態を管理するState。
class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  // タグ入力欄のコントローラー。
  late final TextEditingController _tagsController;
  // 編集中のお気に入り状態。
  late bool _isFavorite;
  // 二重保存防止フラグ。
  bool _isSaving = false;

  // 初期表示時にフォーム状態を作る。
  @override
  void initState() {
    super.initState();
    _isFavorite = widget.entry.isFavorite;
    _tagsController = TextEditingController(text: widget.entry.tags.join(', '));
  }

  // 画面破棄時にコントローラーを解放する。
  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  // 現在の入力内容を保存する。
  Future<void> _save() async {
    if (widget.entry.id == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await LocalHistoryRepository.instance.updateHistoryMetadata(
      historyId: widget.entry.id!,
      isFavorite: _isFavorite,
      tags: _parseTags(_tagsController.text),
    );
    unawaited(SyncService.instance.syncQuietly());

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  // カンマ区切り入力をタグ配列へ変換する。
  List<String> _parseTags(String input) {
    return input
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('履歴詳細')),
      body: AppPageBody(
        maxWidth: 760,
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailRow(label: '原文', value: widget.entry.sourceText),
                    _DetailRow(label: '訳文', value: widget.entry.translatedText),
                    _DetailRow(
                      label: '原言語',
                      value: languageLabelOf(widget.entry.sourceLanguage),
                    ),
                    _DetailRow(
                      label: '訳言語',
                      value: languageLabelOf(widget.entry.targetLanguage),
                    ),
                    _DetailRow(
                      label: '作成日時',
                      value: widget.entry.createdAt.toLocal().toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'お気に入り',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          icon: Icon(
                            _isFavorite ? Icons.star : Icons.star_border,
                          ),
                          label: Text(
                            _isFavorite ? '登録済み' : '登録する',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'タグ',
                        hintText: '例: 日常, ビジネス, 旅行',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('タグはカンマ区切りで入力します。'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: Text(_isSaving ? '保存中...' : '保存'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ラベルと値を縦並びで見せる部品。
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
