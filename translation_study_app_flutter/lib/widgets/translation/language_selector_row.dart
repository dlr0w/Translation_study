import 'package:flutter/material.dart';

// 原文言語と訳文言語を並べて選ぶ部品。
class LanguageSelectorRow extends StatelessWidget {
  const LanguageSelectorRow({
    super.key,
    required this.languageOptions,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  // 表示に使う言語候補。
  final Map<String, String> languageOptions;
  // 現在の原文言語。
  final String sourceLanguage;
  // 現在の訳文言語。
  final String targetLanguage;
  // 原文言語変更時の通知先。
  final ValueChanged<String> onSourceChanged;
  // 訳文言語変更時の通知先。
  final ValueChanged<String> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                value: sourceLanguage,
                labelText: '原文の言語',
                onChanged: onSourceChanged,
              ),
              const SizedBox(height: 12),
              Align(
                child: Icon(
                  Icons.south_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildField(
                value: targetLanguage,
                labelText: '翻訳先',
                onChanged: onTargetChanged,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildField(
                value: sourceLanguage,
                labelText: '原文の言語',
                onChanged: onSourceChanged,
              ),
            ),
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildField(
                value: targetLanguage,
                labelText: '翻訳先',
                onChanged: onTargetChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  // ドロップダウン1つ分を組み立てる。
  Widget _buildField({
    required String value,
    required String labelText,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$labelText-$value'),
      initialValue: value,
      decoration: InputDecoration(labelText: labelText),
      items: _buildItems(),
      onChanged: (nextValue) {
        if (nextValue == null) return;
        onChanged(nextValue);
      },
    );
  }

  // 候補一覧を`DropdownMenuItem`に変換する。
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
