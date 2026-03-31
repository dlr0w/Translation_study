/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class TranslationResult implements _i1.SerializableModel {
  TranslationResult._({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
  });

  factory TranslationResult({
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required DateTime createdAt,
  }) = _TranslationResultImpl;

  factory TranslationResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return TranslationResult(
      sourceText: jsonSerialization['sourceText'] as String,
      translatedText: jsonSerialization['translatedText'] as String,
      sourceLanguage: jsonSerialization['sourceLanguage'] as String,
      targetLanguage: jsonSerialization['targetLanguage'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  String sourceText;

  String translatedText;

  String sourceLanguage;

  String targetLanguage;

  DateTime createdAt;

  /// Returns a shallow copy of this [TranslationResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TranslationResult copyWith({
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TranslationResult',
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TranslationResultImpl extends TranslationResult {
  _TranslationResultImpl({
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required DateTime createdAt,
  }) : super._(
         sourceText: sourceText,
         translatedText: translatedText,
         sourceLanguage: sourceLanguage,
         targetLanguage: targetLanguage,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TranslationResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TranslationResult copyWith({
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
  }) {
    return TranslationResult(
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
