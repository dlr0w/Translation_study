import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

// 認証済みユーザーごとの履歴と復習結果を同期するendpoint。
class SyncEndpoint extends Endpoint {
  // クライアント送信内容をサーバーに取り込む。
  Future<SyncSnapshot> synchronize(
    Session session, {
    required SyncSnapshot localSnapshot,
  }) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) {
      throw Exception('Authentication required.');
    }

    await _upsertHistories(
      session,
      userIdentifier: userIdentifier,
      histories: localSnapshot.histories,
    );
    await _upsertReviewResults(
      session,
      userIdentifier: userIdentifier,
      reviewResults: localSnapshot.reviewResults,
    );

    return _buildSnapshot(session, userIdentifier: userIdentifier);
  }

  // 履歴群をclientRecordId単位でinsert/updateする。
  Future<void> _upsertHistories(
    Session session, {
    required String userIdentifier,
    required List<SyncTranslationHistoryData> histories,
  }) async {
    // 同一ユーザーの既存履歴をclientRecordId起点で取得できるようにする。
    final existingRows = await UserTranslationHistory.db.find(
      session,
      where: (table) => table.userIdentifier.equals(userIdentifier),
    );
    final existingByClientRecordId = {
      for (final row in existingRows) row.clientRecordId: row,
    };

    for (final history in histories) {
      // 未登録ならinsert、既存なら更新時刻ベースで上書きする。
      final existing = existingByClientRecordId[history.clientRecordId];
      if (existing == null) {
        final inserted = await UserTranslationHistory.db.insertRow(
          session,
          _mapHistory(
            userIdentifier: userIdentifier,
            history: history,
          ),
        );
        existingByClientRecordId[inserted.clientRecordId] = inserted;
        continue;
      }

      if (history.updatedAt.isAfter(existing.updatedAt)) {
        final updated = existing.copyWith(
          sourceText: history.sourceText,
          translatedText: history.translatedText,
          sourceLanguage: history.sourceLanguage,
          targetLanguage: history.targetLanguage,
          createdAt: history.createdAt,
          updatedAt: history.updatedAt,
          isFavorite: history.isFavorite,
          tagsJson: jsonEncode(history.tags),
        );
        final saved = await UserTranslationHistory.db.updateRow(
          session,
          updated,
        );
        existingByClientRecordId[saved.clientRecordId] = saved;
      }
    }
  }

  // 復習結果群をclientRecordId単位でinsert/updateする。
  Future<void> _upsertReviewResults(
    Session session, {
    required String userIdentifier,
    required List<SyncReviewResultData> reviewResults,
  }) async {
    // 同一ユーザーの既存復習結果をclientRecordId起点で引けるようにする。
    final existingRows = await UserReviewResult.db.find(
      session,
      where: (table) => table.userIdentifier.equals(userIdentifier),
    );
    final existingByClientRecordId = {
      for (final row in existingRows) row.clientRecordId: row,
    };

    for (final reviewResult in reviewResults) {
      // 未登録ならinsert、既存なら更新時刻ベースで上書き判定する。
      final existing = existingByClientRecordId[reviewResult.clientRecordId];
      if (existing == null) {
        final inserted = await UserReviewResult.db.insertRow(
          session,
          _mapReviewResult(
            userIdentifier: userIdentifier,
            reviewResult: reviewResult,
          ),
        );
        existingByClientRecordId[inserted.clientRecordId] = inserted;
        continue;
      }

      if (reviewResult.updatedAt.isAfter(existing.updatedAt)) {
        final updated = existing.copyWith(
          historyClientRecordId: reviewResult.historyClientRecordId,
          answerText: reviewResult.answerText,
          grade: reviewResult.grade,
          reviewedAt: reviewResult.reviewedAt,
          updatedAt: reviewResult.updatedAt,
        );
        final saved = await UserReviewResult.db.updateRow(session, updated);
        existingByClientRecordId[saved.clientRecordId] = saved;
      }
    }
  }

  // サーバー側の最新状態を同期スナップショットとして生成する。
  Future<SyncSnapshot> _buildSnapshot(
    Session session, {
    required String userIdentifier,
  }) async {
    final histories = await UserTranslationHistory.db.find(
      session,
      where: (table) => table.userIdentifier.equals(userIdentifier),
      orderBy: (table) => table.createdAt,
      orderDescending: true,
    );
    final reviewResults = await UserReviewResult.db.find(
      session,
      where: (table) => table.userIdentifier.equals(userIdentifier),
      orderBy: (table) => table.reviewedAt,
      orderDescending: true,
    );

    return SyncSnapshot(
      histories: histories.map(_mapHistoryData).toList(),
      reviewResults: reviewResults.map(_mapReviewResultData).toList(),
    );
  }

  // DBへ保存する翻訳履歴モデルを生成する。
  UserTranslationHistory _mapHistory({
    required String userIdentifier,
    required SyncTranslationHistoryData history,
  }) {
    return UserTranslationHistory(
      userIdentifier: userIdentifier,
      clientRecordId: history.clientRecordId,
      sourceText: history.sourceText,
      translatedText: history.translatedText,
      sourceLanguage: history.sourceLanguage,
      targetLanguage: history.targetLanguage,
      createdAt: history.createdAt.toUtc(),
      updatedAt: history.updatedAt.toUtc(),
      isFavorite: history.isFavorite,
      tagsJson: jsonEncode(history.tags),
    );
  }

  // DBへ保存する復習結果モデルを生成する。
  UserReviewResult _mapReviewResult({
    required String userIdentifier,
    required SyncReviewResultData reviewResult,
  }) {
    return UserReviewResult(
      userIdentifier: userIdentifier,
      clientRecordId: reviewResult.clientRecordId,
      historyClientRecordId: reviewResult.historyClientRecordId,
      answerText: reviewResult.answerText,
      grade: reviewResult.grade,
      reviewedAt: reviewResult.reviewedAt.toUtc(),
      updatedAt: reviewResult.updatedAt.toUtc(),
    );
  }

  // DBからクライアント返却用の翻訳履歴DTOを組み立てる。
  SyncTranslationHistoryData _mapHistoryData(UserTranslationHistory history) {
    return SyncTranslationHistoryData(
      clientRecordId: history.clientRecordId,
      sourceText: history.sourceText,
      translatedText: history.translatedText,
      sourceLanguage: history.sourceLanguage,
      targetLanguage: history.targetLanguage,
      createdAt: history.createdAt,
      updatedAt: history.updatedAt,
      isFavorite: history.isFavorite,
      tags: _decodeTags(history.tagsJson),
    );
  }

  // DBからクライアント返却用の復習結果DTOを組み立てる。
  SyncReviewResultData _mapReviewResultData(UserReviewResult reviewResult) {
    return SyncReviewResultData(
      clientRecordId: reviewResult.clientRecordId,
      historyClientRecordId: reviewResult.historyClientRecordId,
      answerText: reviewResult.answerText,
      grade: reviewResult.grade,
      reviewedAt: reviewResult.reviewedAt,
      updatedAt: reviewResult.updatedAt,
    );
  }

  // JSON文字列化されたタグ一覧を復元する。
  List<String> _decodeTags(String tagsJson) {
    final decoded = jsonDecode(tagsJson);
    if (decoded is! List) {
      return const [];
    }

    return decoded.map((tag) => tag.toString()).toList();
  }
}
