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
import '../sync/sync_translation_history_data.dart' as _i2;
import '../sync/sync_review_result_data.dart' as _i3;
import 'package:translation_study_app_server/src/generated/protocol.dart'
    as _i4;

abstract class SyncSnapshot
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SyncSnapshot._({
    required this.histories,
    required this.reviewResults,
  });

  factory SyncSnapshot({
    required List<_i2.SyncTranslationHistoryData> histories,
    required List<_i3.SyncReviewResultData> reviewResults,
  }) = _SyncSnapshotImpl;

  factory SyncSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncSnapshot(
      histories: _i4.Protocol()
          .deserialize<List<_i2.SyncTranslationHistoryData>>(
            jsonSerialization['histories'],
          ),
      reviewResults: _i4.Protocol().deserialize<List<_i3.SyncReviewResultData>>(
        jsonSerialization['reviewResults'],
      ),
    );
  }

  List<_i2.SyncTranslationHistoryData> histories;

  List<_i3.SyncReviewResultData> reviewResults;

  /// Returns a shallow copy of this [SyncSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncSnapshot copyWith({
    List<_i2.SyncTranslationHistoryData>? histories,
    List<_i3.SyncReviewResultData>? reviewResults,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncSnapshot',
      'histories': histories.toJson(valueToJson: (v) => v.toJson()),
      'reviewResults': reviewResults.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncSnapshot',
      'histories': histories.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'reviewResults': reviewResults.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SyncSnapshotImpl extends SyncSnapshot {
  _SyncSnapshotImpl({
    required List<_i2.SyncTranslationHistoryData> histories,
    required List<_i3.SyncReviewResultData> reviewResults,
  }) : super._(
         histories: histories,
         reviewResults: reviewResults,
       );

  /// Returns a shallow copy of this [SyncSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncSnapshot copyWith({
    List<_i2.SyncTranslationHistoryData>? histories,
    List<_i3.SyncReviewResultData>? reviewResults,
  }) {
    return SyncSnapshot(
      histories:
          histories ?? this.histories.map((e0) => e0.copyWith()).toList(),
      reviewResults:
          reviewResults ??
          this.reviewResults.map((e0) => e0.copyWith()).toList(),
    );
  }
}
