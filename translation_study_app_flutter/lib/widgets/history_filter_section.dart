import 'package:flutter/material.dart';

import 'app_section_title.dart';
import 'filter_pill_wrap.dart';

// 履歴系画面で使う日付絞り込みの選択肢。
enum HistoryDatePreset {
  none('指定なし'),
  today('今日'),
  last7Days('過去7日'),
  last30Days('過去30日');

  const HistoryDatePreset(this.label);

  // 画面上に出すラベル。
  final String label;
}

// 履歴画面で使うフィルター入力部品。
class HistoryFilterSection extends StatelessWidget {
  // 表示に必要な状態とコールバックを受け取る。
  const HistoryFilterSection({
    super.key,
    required this.title,
    required this.favoritesOnly,
    required this.selectedTag,
    required this.selectedDatePreset,
    required this.availableTags,
    required this.onFavoritesOnlyChanged,
    required this.onDatePresetChanged,
    required this.onTagChanged,
  });

  // セクション名。
  final String title;
  // お気に入りだけに絞るか。
  final bool favoritesOnly;
  // 選択中タグ。
  final String? selectedTag;
  // 選択中の日付条件。
  final HistoryDatePreset selectedDatePreset;
  // ドロップダウンへ並べるタグ候補。
  final List<String> availableTags;
  // お気に入り条件変更時の通知先。
  final ValueChanged<bool> onFavoritesOnlyChanged;
  // 日付条件変更時の通知先。
  final ValueChanged<HistoryDatePreset> onDatePresetChanged;
  // タグ条件変更時の通知先。
  final ValueChanged<String?> onTagChanged;

  // フィルターUIを組み立てる。
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppSectionTitle.styleOf(context),
            ),
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
            FilterPillWrap<HistoryDatePreset>(
              options: HistoryDatePreset.values
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey(selectedTag ?? 'all-tags'),
              initialValue: selectedTag,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'タグ',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('すべてのタグ'),
                ),
                ...availableTags.map(
                  (tag) => DropdownMenuItem<String?>(
                    value: tag,
                    child: Text(tag),
                  ),
                ),
              ],
              onChanged: onTagChanged,
            ),
          ],
        ),
      ),
    );
  }
}
