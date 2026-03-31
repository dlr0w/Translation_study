// 復習1件に対する採点区分。
enum ReviewGrade {
  // 正解
  correct,
  // △（現在未使用）
  partial,
  // 不正解
  incorrect,
}

// 復習結果の1レコードを表す保存用モデル。
class ReviewResultEntry {
  // 復習結果に必要な値を受け取る。
  const ReviewResultEntry({
    // 紐づく翻訳履歴のローカルID。
    required this.historyId,
    // 手入力回答を残す場合の本文。（現在未使用）
    required this.answerText,
    // ユーザーが付けた採点。
    required this.grade,
    // 復習を記録した時刻。
    required this.reviewedAt,
    // 同一セッション内の回答をまとめるID。
    this.sessionId,
    // 同期時に主キー代わりとして使うクライアント側のID。
    this.clientRecordId,
    // 紐づく翻訳履歴側の同期用ID。
    this.historyClientRecordId,
    // 同期競合判定に使う更新時刻。
    this.updatedAt,
    // Sembast側の採番ID。
    this.id,
  });

  // ローカルDBの主キー。
  final int? id;

  // 作成途中で作成したID（削除予定）
  final int historyId;

  // 回答本文。
  final String answerText;

  // 採点結果。
  final ReviewGrade grade;

  // 復習した日時。
  final DateTime reviewedAt;
  // 出題セッション識別子。
  final String? sessionId;
  // クライアント生成の同期用ID。
  final String? clientRecordId;
  // 履歴側の同期用ID。
  final String? historyClientRecordId;
  // 同期判定用の更新時刻。
  final DateTime? updatedAt;

  // 必要な項目だけ差し替えた新しいインスタンスを作る。
  ReviewResultEntry copyWith({
    int? historyId,
    String? answerText,
    ReviewGrade? grade,
    DateTime? reviewedAt,
    String? sessionId,
    String? clientRecordId,
    String? historyClientRecordId,
    DateTime? updatedAt,
  }) {
    return ReviewResultEntry(
      id: id,
      historyId: historyId ?? this.historyId,
      answerText: answerText ?? this.answerText,
      grade: grade ?? this.grade,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      sessionId: sessionId ?? this.sessionId,
      clientRecordId: clientRecordId ?? this.clientRecordId,
      historyClientRecordId:
          historyClientRecordId ?? this.historyClientRecordId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Sembastに保存できるMapへ変換する。
  Map<String, dynamic> toMap() {
    // プリミティブ値だけに落として永続化する。
    return {
      // 履歴との関連を保存する。
      'historyId': historyId,
      // セッション単位のまとまりを保存する。
      'sessionId': sessionId,
      // 同期時に使うレコードIDを保存する。
      'clientRecordId': clientRecordId,
      // 紐づく履歴の同期IDを保存する。
      'historyClientRecordId': historyClientRecordId,
      // 回答本文を保存する。
      'answerText': answerText,
      // enumは名前文字列へ変換する。
      'grade': grade.name,
      // 日時はUTCのISO8601文字列へそろえる。
      'reviewedAt': reviewedAt.toUtc().toIso8601String(),
      // 更新時刻を保存する。
      'updatedAt': (updatedAt ?? reviewedAt).toUtc().toIso8601String(),
    };
  }

  // SembastのMapからモデルへ戻す。
  static ReviewResultEntry fromMap(Map<String, dynamic> map, {int? id}) {
    // 保存時のキー構造から型付きモデルを組み立てる。
    return ReviewResultEntry(
      // Sembastの採番キーを受け取る。
      id: id,
      // 履歴参照IDを復元する。
      historyId: map['historyId'] as int,
      // セッションIDを復元する。
      sessionId: map['sessionId'] as String?,
      // 同期用レコードIDを復元する。
      clientRecordId: map['clientRecordId'] as String,
      // 紐づく履歴側の同期IDを復元する。
      historyClientRecordId: map['historyClientRecordId'] as String,
      // 回答本文を復元する。
      answerText: map['answerText'] as String,
      // 保存文字列からenumを復元する。
      grade: _parseGrade(map['grade'] as String),
      // ISO8601文字列から日時へ戻す。
      reviewedAt: DateTime.parse(map['reviewedAt'] as String),
      // 更新時刻を復元する。
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // 保存文字列からReviewGradeを復元する。
  static ReviewGrade _parseGrade(String value) {
    // 文字列値ごとに対応するenumを返す。
    switch (value) {
      case 'correct':
        return ReviewGrade.correct;
      case 'partial':
        return ReviewGrade.partial;
      case 'incorrect':
        return ReviewGrade.incorrect;
      default:
        // 未知の値は最も安全側の不正解へ倒す。
        return ReviewGrade.incorrect;
    }
  }
}
