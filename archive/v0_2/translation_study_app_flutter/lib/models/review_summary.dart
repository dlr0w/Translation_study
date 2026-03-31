// 復習機能の基本集計を保持するモデル。
class ReviewSummary {
  // 画面表示に必要な集計値を受け取って保持する。
  const ReviewSummary({
    // 翻訳履歴の総件数。
    required this.translationCount,
    // 復習結果の総件数。
    required this.reviewCount,
    // 正解（◯）の件数。
    required this.correctCount,
    // 部分正解（△）の件数。
    required this.partialCount,
    // 不正解（×）の件数。
    required this.incorrectCount,
  });

  // 翻訳回数の表示に使う件数。
  final int translationCount;

  // 復習回数の表示に使う件数。
  final int reviewCount;

  // 正解数の表示に使う件数。
  final int correctCount;

  // 部分正解数の表示に使う件数。
  final int partialCount;

  // 不正解数の表示に使う件数。
  final int incorrectCount;

  // 復習回数に対する正解率を返す（0.0〜1.0）。
  double get correctRate {
    // 未復習の場合は0除算を避けるため0を返す。
    if (reviewCount == 0) return 0;
    // 正解数を復習回数で割って正解率を返す。
    return correctCount / reviewCount;
  }
}
