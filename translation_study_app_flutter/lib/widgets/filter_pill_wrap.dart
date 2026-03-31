import 'package:flutter/material.dart';

// ピル型フィルター1件分の定義。
class FilterPillOption<T> {
  const FilterPillOption({
    required this.value,
    required this.label,
  });

  // 実際に選択される値。
  final T value;
  // 画面表示用の文言。
  final String label;
}

// ピル型選択肢を折り返し表示するラッパー。
class FilterPillWrap<T> extends StatelessWidget {
  const FilterPillWrap({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  // 表示候補。
  final List<FilterPillOption<T>> options;
  // 現在選択されている値。
  final T selectedValue;
  // 選択時の通知先。
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (option) => _FilterPill(
              label: option.label,
              selected: option.value == selectedValue,
              onTap: () => onSelected(option.value),
            ),
          )
          .toList(),
    );
  }
}

// ピル1個分の見た目を表す内部部品。
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  // ピルの表示文言。
  final String label;
  // 選択中ならtrue。
  final bool selected;
  // タップ時の処理。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check,
                  size: 16,
                  color: scheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.25,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
