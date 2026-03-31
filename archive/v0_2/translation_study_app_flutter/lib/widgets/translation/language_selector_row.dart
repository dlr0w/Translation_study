import 'package:flutter/material.dart';

// 翻訳画面の言語選択行。
class LanguageSelectorRow extends StatelessWidget {
  const LanguageSelectorRow({
    super.key,
    required this.languageOptions,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  final Map<String, String> languageOptions;
  final String sourceLanguage;
  final String targetLanguage;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey('source-$sourceLanguage'),
            initialValue: sourceLanguage,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '原言語',
            ),
            items: _buildItems(),
            onChanged: (value) {
              if (value == null) return;
              onSourceChanged(value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey('target-$targetLanguage'),
            initialValue: targetLanguage,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '訳言語',
            ),
            items: _buildItems(),
            onChanged: (value) {
              if (value == null) return;
              onTargetChanged(value);
            },
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildItems() {
    return languageOptions.entries
        .map(
          (entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          ),
        )
        .toList();
  }
}
