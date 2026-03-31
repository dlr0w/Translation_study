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
import 'package:translation_study_app_client/src/protocol/protocol.dart' as _i2;

abstract class SyncTranslationHistoryData implements _i1.SerializableModel {
  SyncTranslationHistoryData._({
    required this.clientRecordId,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    required this.tags,
  });

  factory SyncTranslationHistoryData({
    required String clientRecordId,
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isFavorite,
    required List<String> tags,
  }) = _SyncTranslationHistoryDataImpl;

  factory SyncTranslationHistoryData.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SyncTranslationHistoryData(
      clientRecordId: jsonSerialization['clientRecordId'] as String,
      sourceText: jsonSerialization['sourceText'] as String,
      translatedText: jsonSerialization['translatedText'] as String,
      sourceLanguage: jsonSerialization['sourceLanguage'] as String,
      targetLanguage: jsonSerialization['targetLanguage'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      isFavorite: jsonSerialization['isFavorite'] as bool,
      tags: _i2.Protocol().deserialize<List<String>>(jsonSerialization['tags']),
    );
  }

  String clientRecordId;

  String sourceText;

  String translatedText;

  String sourceLanguage;

  String targetLanguage;

  DateTime createdAt;

  DateTime updatedAt;

  bool isFavorite;

  List<String> tags;

  /// Returns a shallow copy of this [SyncTranslationHistoryData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncTranslationHistoryData copyWith({
    String? clientRecordId,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncTranslationHistoryData',
      'clientRecordId': clientRecordId,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isFavorite': isFavorite,
      'tags': tags.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SyncTranslationHistoryDataImpl extends SyncTranslationHistoryData {
  _SyncTranslationHistoryDataImpl({
    required String clientRecordId,
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isFavorite,
    required List<String> tags,
  }) : super._(
         clientRecordId: clientRecordId,
         sourceText: sourceText,
         translatedText: translatedText,
         sourceLanguage: sourceLanguage,
         targetLanguage: targetLanguage,
         createdAt: createdAt,
         updatedAt: updatedAt,
         isFavorite: isFavorite,
         tags: tags,
       );

  /// Returns a shallow copy of this [SyncTranslationHistoryData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncTranslationHistoryData copyWith({
    String? clientRecordId,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return SyncTranslationHistoryData(
      clientRecordId: clientRecordId ?? this.clientRecordId,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags.map((e0) => e0).toList(),
    );
  }
}
