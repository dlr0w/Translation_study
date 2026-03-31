import 'package:flutter/material.dart';

import '../main.dart';
import '../models/translation_history_entry.dart';
import '../repositories/local_history_repository.dart';
import '../widgets/translation/language_selector_row.dart';
import '../widgets/translation/translation_history_list.dart';
import 'history_detail_screen.dart';

// 翻訳画面の StatefulWidget。
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  // UI で選択可能な言語コードと表示名のマップ。
  static const _languageOptions = <String, String>{
    'ja': 'Japanese',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'ko': 'Korean',
    'zh-cn': 'Chinese (Simplified)',
  };

  // 原文入力の TextField コントローラー。
  final _textController = TextEditingController();
  // 原言語の初期値（日本語）。
  String _sourceLanguage = 'ja';
  // 訳言語の初期値（英語）。
  String _targetLanguage = 'en';
  // 直近の訳文表示用（未翻訳時は null）。
  String? _translatedText;
  // 翻訳 API 実行中かどうか。
  bool _isTranslating = false;
  // 履歴一覧を読み込む Future。
  late Future<List<TranslationHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = LocalHistoryRepository.instance.all();
  }

  // 翻訳ボタン押下時の処理本体。
  Future<void> _translate() async {
    if (_isTranslating) return;

    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('原文を入力してください。')),
      );
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

      await LocalHistoryRepository.instance.addHistory(history);

      if (!mounted) return;
      setState(() {
        _translatedText = result.translatedText;
        _historyFuture = LocalHistoryRepository.instance.all();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('翻訳に失敗しました: $e')),
      );
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
    return Scaffold(
      appBar: AppBar(title: const Text('翻訳')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '原文',
                hintText: '翻訳したい文章を入力',
              ),
            ),
            const SizedBox(height: 12),
            LanguageSelectorRow(
              languageOptions: _languageOptions,
              sourceLanguage: _sourceLanguage,
              targetLanguage: _targetLanguage,
              onSourceChanged: (value) {
                setState(() {
                  _sourceLanguage = value;
                });
              },
              onTargetChanged: (value) {
                setState(() {
                  _targetLanguage = value;
                });
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isTranslating ? null : _translate,
              child: Text(_isTranslating ? '翻訳中...' : '翻訳'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_translatedText ?? '訳文がここに表示されます'),
            ),
            const SizedBox(height: 16),
            const Text(
              '翻訳履歴',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<TranslationHistoryEntry>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  return TranslationHistoryList(
                    snapshot: snapshot,
                    onTap: (item) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => HistoryDetailScreen(entry: item),
                        ),
                      );
                    },
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
