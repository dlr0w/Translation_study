import 'package:flutter/material.dart';

// 各画面で共通利用する本文レイアウト。
class AppPageBody extends StatelessWidget {
  const AppPageBody({
    super.key,
    required this.child,
    this.maxWidth = 1040,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 24),
  });

  // 実際の中身。
  final Widget child;
  // 横幅の上限。
  final double maxWidth;
  // 外側余白。
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - padding.vertical).clamp(
                0.0,
                double.infinity,
              )
            : 0.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.surface,
                scheme.surfaceContainerLowest,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -60,
                top: 140,
                child: _BackgroundOrb(
                  size: 180,
                  color: scheme.tertiary.withValues(alpha: 0.06),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      minHeight: minHeight,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 背景に置く装飾用の円形パーツ。
class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({
    required this.size,
    required this.color,
  });

  // 直径。
  final double size;
  // 塗り色。
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
