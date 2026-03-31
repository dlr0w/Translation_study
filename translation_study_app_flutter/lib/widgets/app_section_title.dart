import 'package:flutter/material.dart';

// カード見出しに共通利用するタイトル部品。
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(
    this.text, {
    super.key,
    this.maxLines = 1,
  });

  // 画面に出す見出し文。
  final String text;
  // 表示可能な最大行数。
  final int maxLines;

  // 他のウィジェットからも再利用できる見出しスタイル。
  static TextStyle styleOf(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge!.copyWith(
      fontSize: 18,
      height: 1.2,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
      color: theme.colorScheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    // テキストへ共通スタイルを適用する。
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: styleOf(context),
    );
  }
}
