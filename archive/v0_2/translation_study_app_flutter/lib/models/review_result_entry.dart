// 復習の自己採点区分を定義する。
enum ReviewGrade {
  // 正解（◯）を表す。
  correct,
  // 部分正解（△）を表す。
  partial,
  // 不正解（×）を表す。
  incorrect,
}

// 復習結果1件分を永続化するデータモデル。
class ReviewResultEntry {
  // 復習結果モデルを生成する。
  const ReviewResultEntry({
    // 出題元となる翻訳履歴のID。
    required this.historyId,
    // ユーザーが入力した回答テキスト。
    required this.answerText,
    // 自己採点（◯/△/×）。
    required this.grade,
    // 復習を実施した日時。
    required this.reviewedAt,
    // ローカルDBの主キー（保存後に割り当て）。
    this.id,
  });

  // ローカルDBの主キー。
  final int? id;

  // 翻訳履歴との紐付けID。
  final int historyId;

  // 回答テキスト。
  final String answerText;

  // 自己採点区分。
  final ReviewGrade grade;

  // 復習日時。
  final DateTime reviewedAt;

  // Sembastへ保存できるMapに変換する。
  Map<String, dynamic> toMap() {
    // モデルの内容を保存用のキー構造に詰める。
    return {
      // 出題元履歴IDを保存する。
      'historyId': historyId,
      // 回答テキストを保存する。
      'answerText': answerText,
      // enumを文字列化して保存する。
      'grade': grade.name,
      // 日時をUTCのISO8601文字列として保存する。
      'reviewedAt': reviewedAt.toUtc().toIso8601String(),
    };
  }

  // DBレコード（Map）からモデルへ復元する。
  static ReviewResultEntry fromMap(Map<String, dynamic> map, {int? id}) {
    // 取り出した値を型変換しながらモデルへ再構築する。
    return ReviewResultEntry(
      // Sembastのレコードキーをセットする。
      id: id,
      // 保存された履歴IDを読み出す。
      historyId: map['historyId'] as int,
      // 保存された回答を読み出す。
      answerText: map['answerText'] as String,
      // 文字列からenumへ戻す。
      grade: _parseGrade(map['grade'] as String),
      // 文字列から日時へ戻す。
      reviewedAt: DateTime.parse(map['reviewedAt'] as String),
    );
  }

  // 永続化された文字列を採点enumに変換する。
  static ReviewGrade _parseGrade(String value) {
    // 保存済みの文字列値で分岐する。
    switch (value) {
      // 正解のケース。
      case 'correct':
        // 正解を返す。
        return ReviewGrade.correct;
      // 部分正解のケース。
      case 'partial':
        // 部分正解を返す。
        return ReviewGrade.partial;
      // 不正解のケース。
      case 'incorrect':
        // 不正解を返す。
        return ReviewGrade.incorrect;
      // 想定外の値のケース。
      default:
        // 安全側に倒して不正解として扱う。
        return ReviewGrade.incorrect;
    }
  }
}
