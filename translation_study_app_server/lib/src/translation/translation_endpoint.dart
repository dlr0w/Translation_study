import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

import '../generated/protocol.dart';

// 翻訳APIを公開するendpoint。
class TranslationEndpoint extends Endpoint {
  // 通常時に使う翻訳クライアント。
  final GoogleTranslator _translator = GoogleTranslator();

  // 通常翻訳のタイムアウト。
  static const Duration _primaryTimeout = Duration(seconds: 8);
  // フォールバックAPIのタイムアウト。
  static const Duration _fallbackTimeout = Duration(seconds: 8);

  // 指定テキストを翻訳してDTOを返す。
  Future<TranslationResult> translate(
    // リクエストコンテキスト。
    Session session, {
    // 翻訳したい本文。
    required String text,
    // 原文言語コード。
    required String sourceLanguage,
    // 訳文言語コード。
    required String targetLanguage,
  }) async {
    // 前後の空白を落として扱う。
    final trimmed = text.trim();

    // 空文字は受け付けない。
    if (trimmed.isEmpty) {
      throw ArgumentError('text must not be empty');
    }

    // 同じ言語同士なら外部翻訳は不要。
    if (sourceLanguage == targetLanguage) {
      return TranslationResult(
        sourceText: trimmed,
        translatedText: trimmed,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        createdAt: DateTime.now().toUtc(),
      );
    }

    // 最終的に返す訳文。
    String translatedText;

    // まず通常翻訳を試し、失敗したら代替APIを使う。
    try {
      translatedText = await _translateWithPrimary(
        trimmed,
        sourceLanguage,
        targetLanguage,
      );
    } catch (primaryError, stackTrace) {
      // 一次手段の失敗はログへ残す。
      session.log(
        'Primary translation failed; fallback to MyMemory. '
        'error=$primaryError',
        stackTrace: stackTrace,
      );

      // 代替APIを実行する。
      translatedText = await _translateWithFallback(
        session,
        trimmed,
        sourceLanguage,
        targetLanguage,
      );
    }

    // クライアント返却用DTOを構築する。
    return TranslationResult(
      // 原文。
      sourceText: trimmed,
      // 訳文。
      translatedText: translatedText,
      // 原文言語。
      sourceLanguage: sourceLanguage,
      // 訳文言語。
      targetLanguage: targetLanguage,
      // サーバー記録時刻。
      createdAt: DateTime.now().toUtc(),
    );
  }

  // 通常時に使う翻訳ライブラリを呼び出す。
  Future<String> _translateWithPrimary(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    // ライブラリの翻訳呼び出し。
    final translated = await _translator
        .translate(text, from: sourceLanguage, to: targetLanguage)
        .timeout(_primaryTimeout);

    // 抽出した訳文を返す。
    return translated.text;
  }

  // 通常翻訳失敗時のフォールバック用API。
  Future<String> _translateWithFallback(
    Session session,
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    // クエリ付きURLを組み立てる。
    final uri = Uri.https(
      'api.mymemory.translated.net',
      '/get',
      <String, String>{
        'q': text,
        'langpair': '$sourceLanguage|$targetLanguage',
      },
    );

    // HTTP GETを実行する。
    final response = await http.get(uri).timeout(_fallbackTimeout);

    // 正常系以外は失敗扱いにする。
    if (response.statusCode != 200) {
      throw Exception(
        'Fallback translation failed: status=${response.statusCode}',
      );
    }

    // JSONを解析して訳文を取り出す。
    final dynamic body = jsonDecode(response.body);
    final dynamic responseData = body['responseData'];
    final dynamic translatedText = responseData is Map<String, dynamic>
        ? responseData['translatedText']
        : null;

    // 訳文が無ければ失敗とみなす。
    if (translatedText is! String || translatedText.trim().isEmpty) {
      throw Exception('Fallback translation failed: empty response');
    }

    // 取得できた訳文を返す。
    return translatedText;
  }
}
