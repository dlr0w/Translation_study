// 翻訳履歴1件を保持するモデル。
class TranslationHistoryEntry {
  // 履歴保存に必要な値を受け取る。
  const TranslationHistoryEntry({
    // 翻訳前の本文。
    required this.sourceText,
    // 翻訳後の本文。
    required this.translatedText,
    // 入力側の言語コード。
    required this.sourceLanguage,
    // 出力側の言語コード。
    required this.targetLanguage,
    // 翻訳を記録した時刻。
    required this.createdAt,
    // お気に入りかどうか。（defalutはfalse）
    this.isFavorite = false,
    // ユーザーが付けたタグ一覧。
    this.tags = const [],
    // 同期時に主キー代わりとなるID。
    this.clientRecordId,
    // 同期競合判定に使う更新時刻。
    this.updatedAt,
    // Sembastの採番ID。
    this.id,
  });

  // ローカルDBの主キー。
  final int? id;
  // 原文。
  final String sourceText;
  // 訳文。
  final String translatedText;
  // 原文の言語コード。
  final String sourceLanguage;
  // 訳文の言語コード。
  final String targetLanguage;
  // 作成日時。
  final DateTime createdAt;
  // お気に入り状態。
  final bool isFavorite;
  // 履歴に付いたタグ。
  final List<String> tags;
  // 同期用のクライアント側ID。
  final String? clientRecordId;
  // 同期用の更新時刻。
  final DateTime? updatedAt;

  // 一部の値だけ差し替えた新しいモデルを返す。
  TranslationHistoryEntry copyWith({
    bool? isFavorite,
    List<String>? tags,
    String? clientRecordId,
    DateTime? updatedAt,
  }) {
    return TranslationHistoryEntry(
      id: id,
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      clientRecordId: clientRecordId ?? this.clientRecordId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Sembast保存用のMapに変換する。
  Map<String, dynamic> toMap() {
    return {
      // 原文を保存する。
      'sourceText': sourceText,
      // 訳文を保存する。
      'translatedText': translatedText,
      // 原文の言語コードを保存する。
      'sourceLanguage': sourceLanguage,
      // 訳文の言語コードを保存する。
      'targetLanguage': targetLanguage,
      // タイムゾーン差を避けるためUTC文字列へそろえる。
      'createdAt': createdAt.toUtc().toIso8601String(),
      // 同期用IDを保存する。
      'clientRecordId': clientRecordId,
      // 更新時刻を保存する。
      'updatedAt': (updatedAt ?? createdAt).toUtc().toIso8601String(),
      // お気に入り状態を保存する。
      'isFavorite': isFavorite,
      // タグ一覧を保存する。
      'tags': tags,
    };
  }

  // SembastのMapからモデルへ復元する。
  static TranslationHistoryEntry fromMap(Map<String, dynamic> map, {int? id}) {
    return TranslationHistoryEntry(
      // 採番済みキーをそのまま受け取る。
      id: id,
      // 原文を復元する。
      sourceText: map['sourceText'] as String,
      // 訳文を復元する。
      translatedText: map['translatedText'] as String,
      // 原文の言語コードを復元する。
      sourceLanguage: map['sourceLanguage'] as String,
      // 訳文の言語コードを復元する。
      targetLanguage: map['targetLanguage'] as String,
      // 保存文字列を日時へ戻す。
      createdAt: DateTime.parse(map['createdAt'] as String),
      // 同期用IDを復元する。
      clientRecordId: map['clientRecordId'] as String,
      // 更新時刻を復元する。
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      // お気に入り状態を復元する。
      isFavorite: map['isFavorite'] as bool,
      // タグ一覧を復元する。
      tags: (map['tags'] as List<dynamic>)
          .map((value) => value.toString())
          .toList(),
    );
  }
}
