// Web 判定用。
import 'package:flutter/foundation.dart' show kIsWeb;
// パス結合用ユーティリティ。
import 'package:path/path.dart' as p;
// アプリ用ドキュメントディレクトリ取得（モバイル/デスクトップ向け）。
import 'package:path_provider/path_provider.dart';
// Sembast（モバイル/デスクトップ用 IO 実装）。
import 'package:sembast/sembast_io.dart';
// Sembast（Web 用 IndexedDB 実装）。
import 'package:sembast_web/sembast_web.dart';

import '../models/review_result_entry.dart';
import '../models/review_summary.dart';
import '../models/translation_history_entry.dart';

// ローカル履歴と復習結果の永続化を担当するリポジトリ。
class LocalHistoryRepository {
  // 外部から new させないための private コンストラクタ。
  LocalHistoryRepository._();

  // 単一インスタンスを使い回す。
  static final LocalHistoryRepository instance = LocalHistoryRepository._();

  // 翻訳履歴ストア（キー: int, 値: Map）。
  final _historyStore = intMapStoreFactory.store('translation_history');
  // 復習結果ストア（キー: int, 値: Map）。
  final _reviewStore = intMapStoreFactory.store('review_results');

  // DBインスタンス（遅延初期化）。
  Database? _db;

  // DBを取得する（未初期化なら開く）。
  Future<Database> _database() async {
    // 既に開いていればそれを返す。
    if (_db != null) return _db!;

    // Web の場合は path_provider を使わず、IndexedDB を使う。
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('translation_study_app_web.db');
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
  Future<void> addHistory(TranslationHistoryEntry entry) async {
    final db = await _database();
    await _historyStore.add(db, entry.toMap());
  }

  // 後方互換のためのエイリアス。
  Future<void> add(TranslationHistoryEntry entry) => addHistory(entry);

  // 翻訳履歴を新しい順で全件取得する。
  Future<List<TranslationHistoryEntry>> all() async {
    final db = await _database();
    final records = await _historyStore.find(
      db,
      finder: Finder(sortOrders: [SortOrder('createdAt', false)]),
    );

    return records
        .map((record) => TranslationHistoryEntry.fromMap(record.value, id: record.key))
        .toList();
  }

  // 復習結果を1件保存する。
  Future<void> addReviewResult(ReviewResultEntry entry) async {
    final db = await _database();
    await _reviewStore.add(db, entry.toMap());
  }

  // 復習結果を新しい順で全件取得する。
  Future<List<ReviewResultEntry>> allReviewResults() async {
    final db = await _database();
    final records = await _reviewStore.find(
      db,
      finder: Finder(sortOrders: [SortOrder('reviewedAt', false)]),
    );

    return records
        .map((record) => ReviewResultEntry.fromMap(record.value, id: record.key))
        .toList();
  }

  // v0.2 の基本集計を返す。
  Future<ReviewSummary> getReviewSummary() async {
    final histories = await all();
    final reviews = await allReviewResults();

    final correct = reviews.where((r) => r.grade == ReviewGrade.correct).length;
    final partial = reviews.where((r) => r.grade == ReviewGrade.partial).length;
    final incorrect = reviews.where((r) => r.grade == ReviewGrade.incorrect).length;

    return ReviewSummary(
      translationCount: histories.length,
      reviewCount: reviews.length,
      correctCount: correct,
      partialCount: partial,
      incorrectCount: incorrect,
    );
  }
}
