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
import 'package:serverpod/serverpod.dart' as _i1;

abstract class SyncReviewResultData
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SyncReviewResultData._({
    required this.clientRecordId,
    required this.historyClientRecordId,
    required this.answerText,
    required this.grade,
    required this.reviewedAt,
    required this.updatedAt,
  });

  factory SyncReviewResultData({
    required String clientRecordId,
    required String historyClientRecordId,
    required String answerText,
    required String grade,
    required DateTime reviewedAt,
    required DateTime updatedAt,
  }) = _SyncReviewResultDataImpl;

  factory SyncReviewResultData.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SyncReviewResultData(
      clientRecordId: jsonSerialization['clientRecordId'] as String,
      historyClientRecordId:
          jsonSerialization['historyClientRecordId'] as String,
      answerText: jsonSerialization['answerText'] as String,
      grade: jsonSerialization['grade'] as String,
      reviewedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['reviewedAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  String clientRecordId;

  String historyClientRecordId;

  String answerText;

  String grade;

  DateTime reviewedAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [SyncReviewResultData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncReviewResultData copyWith({
    String? clientRecordId,
    String? historyClientRecordId,
    String? answerText,
    String? grade,
    DateTime? reviewedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncReviewResultData',
      'clientRecordId': clientRecordId,
      'historyClientRecordId': historyClientRecordId,
      'answerText': answerText,
      'grade': grade,
      'reviewedAt': reviewedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncReviewResultData',
      'clientRecordId': clientRecordId,
      'historyClientRecordId': historyClientRecordId,
      'answerText': answerText,
      'grade': grade,
      'reviewedAt': reviewedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SyncReviewResultDataImpl extends SyncReviewResultData {
  _SyncReviewResultDataImpl({
    required String clientRecordId,
    required String historyClientRecordId,
    required String answerText,
    required String grade,
    required DateTime reviewedAt,
    required DateTime updatedAt,
  }) : super._(
         clientRecordId: clientRecordId,
         historyClientRecordId: historyClientRecordId,
         answerText: answerText,
         grade: grade,
         reviewedAt: reviewedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SyncReviewResultData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncReviewResultData copyWith({
    String? clientRecordId,
    String? historyClientRecordId,
    String? answerText,
    String? grade,
    DateTime? reviewedAt,
    DateTime? updatedAt,
  }) {
    return SyncReviewResultData(
      clientRecordId: clientRecordId ?? this.clientRecordId,
      historyClientRecordId:
          historyClientRecordId ?? this.historyClientRecordId,
      answerText: answerText ?? this.answerText,
      grade: grade ?? this.grade,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
