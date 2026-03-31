// 復習画面で使う集計結果の用のモデル。
class ReviewSummary {
  // 画面に必要な件数をそのまま保持する。
  const ReviewSummary({
    // 保存済み翻訳履歴の件数。
    required this.translationCount,
    // 保存済み復習結果の件数。
    required this.reviewCount,
    // 正解数。
    required this.correctCount,
    // 部分正解数。
    required this.partialCount,
    // 不正解数。
    required this.incorrectCount,
  });

  // 翻訳総数。
  final int translationCount;

  // 復習総数。
  final int reviewCount;

  // 正解数。
  final int correctCount;

  // 部分正解数。
  final int partialCount;

  // 不正解数。
  final int incorrectCount;

  // 正解率を0.0から1.0の範囲で返す。
  double get correctRate {
    // 復習が無ければ割り算を行わない。
    if (reviewCount == 0) return 0;
    // 正解数を総復習数で割る。
    return correctCount / reviewCount;
  }
}
