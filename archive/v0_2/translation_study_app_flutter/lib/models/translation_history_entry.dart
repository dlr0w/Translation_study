// 翻訳履歴1件分を表すデータモデル。
class TranslationHistoryEntry {
  // 全フィールドを受け取るコンストラクタ。
  const TranslationHistoryEntry({
    // 原文。
    required this.sourceText,
    // 訳文。
    required this.translatedText,
    // 原言語コード。
    required this.sourceLanguage,
    // 訳言語コード。
    required this.targetLanguage,
    // 作成日時。
    required this.createdAt,
    // ローカルDBの主キー（新規保存前は null）。
    this.id,
  });

  // ローカルDBのID。
  final int? id;
  // 原文テキスト。
  final String sourceText;
  // 訳文テキスト。
  final String translatedText;
  // 原言語コード。
  final String sourceLanguage;
  // 訳言語コード。
  final String targetLanguage;
  // 作成日時。
  final DateTime createdAt;

  // DB保存用に Map へ変換する。
  Map<String, dynamic> toMap() {
    return {
      // 原文。
      'sourceText': sourceText,
      // 訳文。
      'translatedText': translatedText,
      // 原言語。
      'sourceLanguage': sourceLanguage,
      // 訳言語。
      'targetLanguage': targetLanguage,
      // タイムゾーン差分を避けるため UTC ISO8601 文字列で保存。
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  // DBレコード（Map）からモデルへ復元する。
  static TranslationHistoryEntry fromMap(Map<String, dynamic> map, {int? id}) {
    return TranslationHistoryEntry(
      // 主キー。
      id: id,
      // 原文。
      sourceText: map['sourceText'] as String,
      // 訳文。
      translatedText: map['translatedText'] as String,
      // 原言語。
      sourceLanguage: map['sourceLanguage'] as String,
      // 訳言語。
      targetLanguage: map['targetLanguage'] as String,
      // 保存文字列を DateTime に戻す。
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
