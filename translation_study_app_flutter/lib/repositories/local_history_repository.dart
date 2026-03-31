import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

import 'package:translation_study_app_client/translation_study_app_client.dart';

import '../models/review_result_entry.dart';
import '../models/review_summary.dart';
import '../models/translation_history_entry.dart';

// ローカル履歴と復習結果のの保持を担当するリポジトリ。
class LocalHistoryRepository {
  // 外部からnewさせないためのprivateコンストラクタ。
  LocalHistoryRepository._();

  // 単一インスタンスを使い回す。
  static final LocalHistoryRepository instance = LocalHistoryRepository._();

  // 翻訳履歴ストア（キー: int, 値: Map）。
  final _historyStore = intMapStoreFactory.store('translation_history');
  // 復習結果ストア（キー: int, 値: Map）。
  final _reviewStore = intMapStoreFactory.store('review_results');

  // DBインスタンス。
  Database? _db;
  // クライアントレコードID生成。
  final Uuid _uuid = const Uuid();

  // DBを取得する（未初期化なら開く）。
  Future<Database> _database() async {
    // 既に開いていればそれを返す。
    if (_db != null) {
      return _db!;
    }

    // Webの場合のDB設定
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase(
        'translation_study_app_web.db',
      );
      return _db!;
    }

    // モバイル/デスクトップではアプリのドキュメントディレクトリを取得する。
    final dir = await getApplicationDocumentsDirectory();
    // DBファイルパスを組み立てる。
    final dbPath = p.join(dir.path, 'translation_study_app.db');
    // DBを開く。
    _db = await databaseFactoryIo.openDatabase(dbPath);
    // 開いたDBを返す。
    return _db!;
  }

  // 翻訳履歴を1件保存する。
  Future<int> addHistory(TranslationHistoryEntry entry) async {
    final db = await _database();
    final prepared = _prepareHistoryForPersistence(entry);
    return await _historyStore.add(db, prepared.toMap());
  }

  // 分かりやすくするためのaddメソッドのエイリアス
  Future<int> add(TranslationHistoryEntry entry) => addHistory(entry);

  // 翻訳履歴を条件付きで新しい順に取得する。
  Future<List<TranslationHistoryEntry>> all({
    bool favoritesOnly = false,
    String? tag,
    List<String>? tags,
    DateTime? createdFrom,
    DateTime? createdTo,
  }) async {
    final db = await _database();
    final records = await _historyStore.find(
      db,
      finder: Finder(sortOrders: [SortOrder('createdAt', false)]),
    );

    final normalizedTags = _normalizeTagFilters(
      tag: tag,
      tags: tags,
    );

    return records
        .map(
          (record) =>
              TranslationHistoryEntry.fromMap(record.value, id: record.key),
        )
        .where((entry) => !favoritesOnly || entry.isFavorite)
        .where((entry) {
          if (normalizedTags.isEmpty) {
            return true;
          }
          return entry.tags
              .map(_normalizeTag)
              .whereType<String>()
              .any(normalizedTags.contains);
        })
        .where((entry) {
          final createdAt = entry.createdAt.toLocal();
          final isAfterStart =
              createdFrom == null || !createdAt.isBefore(createdFrom);
          final isBeforeEnd =
              createdTo == null || createdAt.isBefore(createdTo);
          return isAfterStart && isBeforeEnd;
        })
        .toList();
  }

  // 翻訳画面向けに直近の履歴２０件を返す。
  Future<List<TranslationHistoryEntry>> latest({int limit = 20}) async {
    final histories = await all();
    return histories.take(limit).toList();
  }

  // 履歴IDを指定して1件取得する。
  Future<TranslationHistoryEntry?> findHistoryById(int historyId) async {
    final db = await _database();
    final record = await _historyStore.record(historyId).get(db);

    if (record == null) {
      return null;
    }

    return TranslationHistoryEntry.fromMap(record, id: historyId);
  }

  // 履歴のお気に入り状態のみを更新する。
  Future<void> updateHistoryFavorite({
    required int historyId,
    required bool isFavorite,
  }) async {
    final db = await _database();
    final existing = await _historyStore.record(historyId).get(db);

    if (existing == null) {
      return;
    }

    final entry = TranslationHistoryEntry.fromMap(existing, id: historyId);
    final updated = entry.copyWith(
      isFavorite: isFavorite,
      updatedAt: DateTime.now().toUtc(),
    );

    await _historyStore.record(historyId).put(db, updated.toMap());
  }

  // 履歴のメタデータを更新する。
  Future<void> updateHistoryMetadata({
    required int historyId,
    required bool isFavorite,
    required List<String> tags,
  }) async {
    final db = await _database();
    final existing = await _historyStore.record(historyId).get(db);

    if (existing == null) {
      return;
    }

    final entry = TranslationHistoryEntry.fromMap(existing, id: historyId);
    final updated = entry.copyWith(
      isFavorite: isFavorite,
      tags: _normalizeTags(tags),
      updatedAt: DateTime.now().toUtc(),
    );

    await _historyStore.record(historyId).put(db, updated.toMap());
  }

  // 保存済みタグの一覧を重複なしで返す。
  Future<List<String>> allTags() async {
    final histories = await all();
    final tags = histories.expand((entry) => entry.tags).toSet().toList();

    tags.sort(
      (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
    );
    return tags;
  }

  // ログアウト時にローカルの学習データを全消去する。
  Future<void> clearStudyData() async {
    final db = await _database();
    await _historyStore.delete(db);
    await _reviewStore.delete(db);
  }

  // 復習結果を1件保存する。
  Future<int> addReviewResult(ReviewResultEntry entry) async {
    final db = await _database();
    final history = await findHistoryById(entry.historyId);
    if (history == null) {
      throw StateError('Review history was not found.');
    }

    final prepared = _prepareReviewResultForPersistence(
      entry,
      historyClientRecordId: history.clientRecordId!,
    );

    return await _reviewStore.add(db, prepared.toMap());
  }

  // 復習結果を新しい順で全件取得する。
  Future<List<ReviewResultEntry>> allReviewResults() async {
    final db = await _database();
    final records = await _reviewStore.find(
      db,
      finder: Finder(sortOrders: [SortOrder('reviewedAt', false)]),
    );

    return records
        .map(
          (record) => ReviewResultEntry.fromMap(record.value, id: record.key),
        )
        .toList();
  }

  // 基本集計を返す。
  Future<ReviewSummary> getReviewSummary() async {
    final histories = await all();
    final reviews = await allReviewResults();

    final correct = reviews.where((r) => r.grade == ReviewGrade.correct).length;
    final partial = reviews.where((r) => r.grade == ReviewGrade.partial).length;
    final incorrect = reviews
        .where((r) => r.grade == ReviewGrade.incorrect)
        .length;

    return ReviewSummary(
      translationCount: histories.length,
      reviewCount: reviews.length,
      correctCount: correct,
      partialCount: partial,
      incorrectCount: incorrect,
    );
  }

  // 同期用に翻訳履歴を全件返すメソッド別名の設定。
  Future<List<TranslationHistoryEntry>> allHistoriesForSync() => all();

  // 同期用に復習結果を全件返すメソッド別名の設定。
  Future<List<ReviewResultEntry>> allReviewResultsForSync() =>
      allReviewResults();

  // サーバーから受け取った同期スナップショットをローカルへ反映する。
  Future<void> applySyncSnapshot(SyncSnapshot snapshot) async {
    final db = await _database();

    // まずは既存の翻訳履歴を読み出し、同期用IDごとに引ける状態へする。
    final historyRecords = await _historyStore.find(db);
    final historyKeyByClientRecordId = <String, int>{};
    final historyByClientRecordId = <String, TranslationHistoryEntry>{};

    for (final record in historyRecords) {
      final entry = TranslationHistoryEntry.fromMap(
        record.value,
        id: record.key,
      );
      final clientRecordId = entry.clientRecordId!;

      // 同期用IDからローカル主キーと現在値の両方を引けるようにしておく。
      historyKeyByClientRecordId[clientRecordId] = record.key;
      historyByClientRecordId[clientRecordId] = entry;
    }

    // サーバー履歴を1件ずつローカル形式へ詰め替えて反映する。
    for (final history in snapshot.histories) {
      final localEntry = historyByClientRecordId[history.clientRecordId];
      final localKey = historyKeyByClientRecordId[history.clientRecordId];
      // 受信DTOをローカル保存モデルへ変換する。
      final mappedEntry = TranslationHistoryEntry(
        id: localKey,
        sourceText: history.sourceText,
        translatedText: history.translatedText,
        sourceLanguage: history.sourceLanguage,
        targetLanguage: history.targetLanguage,
        createdAt: history.createdAt.toUtc(),
        isFavorite: history.isFavorite,
        tags: _normalizeTags(history.tags),
        clientRecordId: history.clientRecordId,
        updatedAt: history.updatedAt.toUtc(),
      );

      if (localKey == null) {
        // ローカル未登録なら新規保存し、直後の復習結果同期で使う対応表も更新する。
        final insertedKey = await _historyStore.add(db, mappedEntry.toMap());
        historyKeyByClientRecordId[history.clientRecordId] = insertedKey;
        historyByClientRecordId[history.clientRecordId] = mappedEntry
            .copyWith();
        continue;
      }

      // 競合時は updatedAt を優先し、同時刻ならサーバー値を採用する。
      final localUpdatedAt = localEntry!.updatedAt!.toUtc();
      if (!localUpdatedAt.isAfter(history.updatedAt)) {
        // サーバーのほうが新しいか同等なら、ローカル内容を上書きする。
        await _historyStore.record(localKey).put(db, mappedEntry.toMap());
        historyByClientRecordId[history.clientRecordId] = mappedEntry;
      }
    }

    // 次に復習結果を読み出し、こちらも同期用IDから引ける状態へそろえる。
    final reviewRecords = await _reviewStore.find(db);
    final reviewKeyByClientRecordId = <String, int>{};
    final reviewByClientRecordId = <String, ReviewResultEntry>{};

    for (final record in reviewRecords) {
      final entry = ReviewResultEntry.fromMap(record.value, id: record.key);
      final clientRecordId = entry.clientRecordId!;

      // 復習結果も同期用IDからローカル主キーと現在値を引けるようにする。
      reviewKeyByClientRecordId[clientRecordId] = record.key;
      reviewByClientRecordId[clientRecordId] = entry;
    }

    // 復習結果は紐づく履歴のローカル主キーが必要なので、履歴同期のあとで反映する。
    for (final reviewResult in snapshot.reviewResults) {
      final localKey = reviewKeyByClientRecordId[reviewResult.clientRecordId];
      final localEntry = reviewByClientRecordId[reviewResult.clientRecordId];
      final historyKey =
          historyKeyByClientRecordId[reviewResult.historyClientRecordId];

      if (historyKey == null) {
        // 親の履歴が見つからない復習結果は、整合性を保つため保存しない。
        continue;
      }

      // サーバーDTOを、ローカルの履歴主キーへ結び直した保存モデルへ変換する。
      final mappedEntry = ReviewResultEntry(
        id: localKey,
        historyId: historyKey,
        answerText: reviewResult.answerText,
        grade: _parseReviewGrade(reviewResult.grade),
        reviewedAt: reviewResult.reviewedAt.toUtc(),
        clientRecordId: reviewResult.clientRecordId,
        historyClientRecordId: reviewResult.historyClientRecordId,
        updatedAt: reviewResult.updatedAt.toUtc(),
      );

      if (localKey == null) {
        // 未登録なら新規保存し、以後の比較用キャッシュも更新する。
        final insertedKey = await _reviewStore.add(db, mappedEntry.toMap());
        reviewKeyByClientRecordId[reviewResult.clientRecordId] = insertedKey;
        reviewByClientRecordId[reviewResult.clientRecordId] = mappedEntry;
        continue;
      }

      // 履歴と同じく updatedAt ベースで上書き可否を決める。
      final localUpdatedAt = localEntry!.updatedAt!.toUtc();
      if (!localUpdatedAt.isAfter(reviewResult.updatedAt)) {
        // サーバー側が新しいか同等なら、ローカルの復習結果を更新する。
        await _reviewStore.record(localKey).put(db, mappedEntry.toMap());
        reviewByClientRecordId[reviewResult.clientRecordId] = mappedEntry;
      }
    }
  }

  // タグ文字列を比較用に正規化する。
  String? _normalizeTag(String? tag) {
    final normalized = tag?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  // 単一タグ指定と複数タグ指定を比較用集合へまとめる。
  Set<String> _normalizeTagFilters({
    String? tag,
    List<String>? tags,
  }) {
    final normalizedTags = <String>{};

    final singleTag = _normalizeTag(tag);
    if (singleTag != null) {
      normalizedTags.add(singleTag);
    }

    for (final candidate in tags ?? const <String>[]) {
      final normalized = _normalizeTag(candidate);
      if (normalized != null) {
        normalizedTags.add(normalized);
      }
    }

    return normalizedTags;
  }

  // タグ一覧を保存向けに整形する。
  List<String> _normalizeTags(List<String> tags) {
    final uniqueTags = <String>{};

    for (final tag in tags) {
      final trimmed = tag.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      uniqueTags.add(trimmed);
    }

    final sortedTags = uniqueTags.toList();
    sortedTags.sort(
      (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
    );
    return sortedTags;
  }

  // 新規翻訳履歴へ同期メタデータを補完する。
  TranslationHistoryEntry _prepareHistoryForPersistence(
    TranslationHistoryEntry entry,
  ) {
    return entry.copyWith(
      clientRecordId: entry.clientRecordId ?? _uuid.v7(),
      updatedAt: (entry.updatedAt ?? entry.createdAt).toUtc(),
      tags: _normalizeTags(entry.tags),
    );
  }

  // 新規復習結果へ同期メタデータを補完する。
  ReviewResultEntry _prepareReviewResultForPersistence(
    ReviewResultEntry entry, {
    required String historyClientRecordId,
  }) {
    return entry.copyWith(
      clientRecordId: entry.clientRecordId ?? _uuid.v7(),
      historyClientRecordId:
          entry.historyClientRecordId ?? historyClientRecordId,
      updatedAt: (entry.updatedAt ?? entry.reviewedAt).toUtc(),
      reviewedAt: entry.reviewedAt.toUtc(),
      answerText: entry.answerText.trim(),
    );
  }

  // サーバー同期DTOの文字列採点値をローカルenumへ変換する。
  ReviewGrade _parseReviewGrade(String value) {
    switch (value) {
      case 'correct':
        return ReviewGrade.correct;
      case 'partial':
        return ReviewGrade.partial;
      case 'incorrect':
        return ReviewGrade.incorrect;
      default:
        return ReviewGrade.incorrect;
    }
  }
}
