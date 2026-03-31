import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'package:translation_study_app_client/translation_study_app_client.dart';

import '../main.dart';
import '../models/review_result_entry.dart';
import '../models/translation_history_entry.dart';
import '../repositories/local_history_repository.dart';

// ローカルデータとサーバーデータの同期をまとめるサービス。
class SyncService {
  SyncService._();

  // 画面から共通利用する。
  static final SyncService instance = SyncService._();

  // 多重同期を防ぐため進行中Futureを保持する。
  Future<bool>? _inFlightSync;

  // 明示的に同期を開始し、進行中なら同じFutureを返す。
  Future<bool> syncNow() {
    final inFlightSync = _inFlightSync;
    if (inFlightSync != null) {
      return inFlightSync;
    }

    final syncFuture = _syncNowInternal();
    _inFlightSync = syncFuture;
    return syncFuture.whenComplete(() {
      if (identical(_inFlightSync, syncFuture)) {
        _inFlightSync = null;
      }
    });
  }

  // UIから呼びやすいよう例外をキャッチしてfalseを返す。
  Future<bool> syncQuietly() async {
    try {
      return await syncNow();
    } catch (error, stackTrace) {
      debugPrint('Sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  // 認証確認からスナップショット反映までを順に実行する。
  Future<bool> _syncNowInternal() async {
    if (!client.auth.isAuthenticated) {
      return false;
    }

    final localSnapshot = await _buildLocalSnapshot();
    final remoteSnapshot = await client.sync.synchronize(
      localSnapshot: localSnapshot,
    );
    await LocalHistoryRepository.instance.applySyncSnapshot(remoteSnapshot);
    return true;
  }

  // ローカルDBの内容を送信用DTOに詰め替える。
  Future<SyncSnapshot> _buildLocalSnapshot() async {
    final histories = await LocalHistoryRepository.instance
        .allHistoriesForSync();
    final reviewResults = await LocalHistoryRepository.instance
        .allReviewResultsForSync();

    return SyncSnapshot(
      histories: histories.map(_mapHistory).toList(),
      reviewResults: reviewResults.map(_mapReviewResult).toList(),
    );
  }

  // 翻訳履歴を送信用DTOに詰め替える。
  SyncTranslationHistoryData _mapHistory(TranslationHistoryEntry entry) {
    return SyncTranslationHistoryData(
      clientRecordId: entry.clientRecordId!,
      sourceText: entry.sourceText,
      translatedText: entry.translatedText,
      sourceLanguage: entry.sourceLanguage,
      targetLanguage: entry.targetLanguage,
      createdAt: entry.createdAt.toUtc(),
      updatedAt: entry.updatedAt!.toUtc(),
      isFavorite: entry.isFavorite,
      tags: entry.tags,
    );
  }

  // 復習結果を送信用DTOに詰め替える。
  SyncReviewResultData _mapReviewResult(ReviewResultEntry entry) {
    return SyncReviewResultData(
      clientRecordId: entry.clientRecordId!,
      historyClientRecordId: entry.historyClientRecordId!,
      answerText: entry.answerText,
      grade: entry.grade.name,
      reviewedAt: entry.reviewedAt.toUtc(),
      updatedAt: entry.updatedAt!.toUtc(),
    );
  }
}
