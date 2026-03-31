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

abstract class UserTranslationHistory
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserTranslationHistory._({
    this.id,
    required this.userIdentifier,
    required this.clientRecordId,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    required this.tagsJson,
  });

  factory UserTranslationHistory({
    int? id,
    required String userIdentifier,
    required String clientRecordId,
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isFavorite,
    required String tagsJson,
  }) = _UserTranslationHistoryImpl;

  factory UserTranslationHistory.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UserTranslationHistory(
      id: jsonSerialization['id'] as int?,
      userIdentifier: jsonSerialization['userIdentifier'] as String,
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
      tagsJson: jsonSerialization['tagsJson'] as String,
    );
  }

  static final t = UserTranslationHistoryTable();

  static const db = UserTranslationHistoryRepository._();

  @override
  int? id;

  String userIdentifier;

  String clientRecordId;

  String sourceText;

  String translatedText;

  String sourceLanguage;

  String targetLanguage;

  DateTime createdAt;

  DateTime updatedAt;

  bool isFavorite;

  String tagsJson;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserTranslationHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserTranslationHistory copyWith({
    int? id,
    String? userIdentifier,
    String? clientRecordId,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? tagsJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserTranslationHistory',
      if (id != null) 'id': id,
      'userIdentifier': userIdentifier,
      'clientRecordId': clientRecordId,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'isFavorite': isFavorite,
      'tagsJson': tagsJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static UserTranslationHistoryInclude include() {
    return UserTranslationHistoryInclude._();
  }

  static UserTranslationHistoryIncludeList includeList({
    _i1.WhereExpressionBuilder<UserTranslationHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserTranslationHistoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserTranslationHistoryTable>? orderByList,
    UserTranslationHistoryInclude? include,
  }) {
    return UserTranslationHistoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserTranslationHistory.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserTranslationHistory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserTranslationHistoryImpl extends UserTranslationHistory {
  _UserTranslationHistoryImpl({
    int? id,
    required String userIdentifier,
    required String clientRecordId,
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isFavorite,
    required String tagsJson,
  }) : super._(
         id: id,
         userIdentifier: userIdentifier,
         clientRecordId: clientRecordId,
         sourceText: sourceText,
         translatedText: translatedText,
         sourceLanguage: sourceLanguage,
         targetLanguage: targetLanguage,
         createdAt: createdAt,
         updatedAt: updatedAt,
         isFavorite: isFavorite,
         tagsJson: tagsJson,
       );

  /// Returns a shallow copy of this [UserTranslationHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserTranslationHistory copyWith({
    Object? id = _Undefined,
    String? userIdentifier,
    String? clientRecordId,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? tagsJson,
  }) {
    return UserTranslationHistory(
      id: id is int? ? id : this.id,
      userIdentifier: userIdentifier ?? this.userIdentifier,
      clientRecordId: clientRecordId ?? this.clientRecordId,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tagsJson: tagsJson ?? this.tagsJson,
    );
  }
}

class UserTranslationHistoryUpdateTable
    extends _i1.UpdateTable<UserTranslationHistoryTable> {
  UserTranslationHistoryUpdateTable(super.table);

  _i1.ColumnValue<String, String> userIdentifier(String value) =>
      _i1.ColumnValue(
        table.userIdentifier,
        value,
      );

  _i1.ColumnValue<String, String> clientRecordId(String value) =>
      _i1.ColumnValue(
        table.clientRecordId,
        value,
      );

  _i1.ColumnValue<String, String> sourceText(String value) => _i1.ColumnValue(
    table.sourceText,
    value,
  );

  _i1.ColumnValue<String, String> translatedText(String value) =>
      _i1.ColumnValue(
        table.translatedText,
        value,
      );

  _i1.ColumnValue<String, String> sourceLanguage(String value) =>
      _i1.ColumnValue(
        table.sourceLanguage,
        value,
      );

  _i1.ColumnValue<String, String> targetLanguage(String value) =>
      _i1.ColumnValue(
        table.targetLanguage,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<bool, bool> isFavorite(bool value) => _i1.ColumnValue(
    table.isFavorite,
    value,
  );

  _i1.ColumnValue<String, String> tagsJson(String value) => _i1.ColumnValue(
    table.tagsJson,
    value,
  );
}

class UserTranslationHistoryTable extends _i1.Table<int?> {
  UserTranslationHistoryTable({super.tableRelation})
    : super(tableName: 'user_translation_history') {
    updateTable = UserTranslationHistoryUpdateTable(this);
    userIdentifier = _i1.ColumnString(
      'userIdentifier',
      this,
    );
    clientRecordId = _i1.ColumnString(
      'clientRecordId',
      this,
    );
    sourceText = _i1.ColumnString(
      'sourceText',
      this,
    );
    translatedText = _i1.ColumnString(
      'translatedText',
      this,
    );
    sourceLanguage = _i1.ColumnString(
      'sourceLanguage',
      this,
    );
    targetLanguage = _i1.ColumnString(
      'targetLanguage',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
    isFavorite = _i1.ColumnBool(
      'isFavorite',
      this,
    );
    tagsJson = _i1.ColumnString(
      'tagsJson',
      this,
    );
  }

  late final UserTranslationHistoryUpdateTable updateTable;

  late final _i1.ColumnString userIdentifier;

  late final _i1.ColumnString clientRecordId;

  late final _i1.ColumnString sourceText;

  late final _i1.ColumnString translatedText;

  late final _i1.ColumnString sourceLanguage;

  late final _i1.ColumnString targetLanguage;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnBool isFavorite;

  late final _i1.ColumnString tagsJson;

  @override
  List<_i1.Column> get columns => [
    id,
    userIdentifier,
    clientRecordId,
    sourceText,
    translatedText,
    sourceLanguage,
    targetLanguage,
    createdAt,
    updatedAt,
    isFavorite,
    tagsJson,
  ];
}

class UserTranslationHistoryInclude extends _i1.IncludeObject {
  UserTranslationHistoryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserTranslationHistory.t;
}

class UserTranslationHistoryIncludeList extends _i1.IncludeList {
  UserTranslationHistoryIncludeList._({
    _i1.WhereExpressionBuilder<UserTranslationHistoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserTranslationHistory.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserTranslationHistory.t;
}

class UserTranslationHistoryRepository {
  const UserTranslationHistoryRepository._();

  /// Returns a list of [UserTranslationHistory]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UserTranslationHistory>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserTranslationHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserTranslationHistoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserTranslationHistoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserTranslationHistory>(
      where: where?.call(UserTranslationHistory.t),
      orderBy: orderBy?.call(UserTranslationHistory.t),
      orderByList: orderByList?.call(UserTranslationHistory.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [UserTranslationHistory] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UserTranslationHistory?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserTranslationHistoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserTranslationHistoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserTranslationHistoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<UserTranslationHistory>(
      where: where?.call(UserTranslationHistory.t),
      orderBy: orderBy?.call(UserTranslationHistory.t),
      orderByList: orderByList?.call(UserTranslationHistory.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [UserTranslationHistory] by its [id] or null if no such row exists.
  Future<UserTranslationHistory?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<UserTranslationHistory>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [UserTranslationHistory]s in the list and returns the inserted rows.
  ///
  /// The returned [UserTranslationHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<UserTranslationHistory>> insert(
    _i1.Session session,
    List<UserTranslationHistory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserTranslationHistory>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [UserTranslationHistory] and returns the inserted row.
  ///
  /// The returned [UserTranslationHistory] will have its `id` field set.
  Future<UserTranslationHistory> insertRow(
    _i1.Session session,
    UserTranslationHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserTranslationHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserTranslationHistory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserTranslationHistory>> update(
    _i1.Session session,
    List<UserTranslationHistory> rows, {
    _i1.ColumnSelections<UserTranslationHistoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserTranslationHistory>(
      rows,
      columns: columns?.call(UserTranslationHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserTranslationHistory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserTranslationHistory> updateRow(
    _i1.Session session,
    UserTranslationHistory row, {
    _i1.ColumnSelections<UserTranslationHistoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserTranslationHistory>(
      row,
      columns: columns?.call(UserTranslationHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserTranslationHistory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserTranslationHistory?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserTranslationHistoryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserTranslationHistory>(
      id,
      columnValues: columnValues(UserTranslationHistory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserTranslationHistory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserTranslationHistory>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserTranslationHistoryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<UserTranslationHistoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserTranslationHistoryTable>? orderBy,
    _i1.OrderByListBuilder<UserTranslationHistoryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserTranslationHistory>(
      columnValues: columnValues(UserTranslationHistory.t.updateTable),
      where: where(UserTranslationHistory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserTranslationHistory.t),
      orderByList: orderByList?.call(UserTranslationHistory.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserTranslationHistory]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserTranslationHistory>> delete(
    _i1.Session session,
    List<UserTranslationHistory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserTranslationHistory>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserTranslationHistory].
  Future<UserTranslationHistory> deleteRow(
    _i1.Session session,
    UserTranslationHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserTranslationHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserTranslationHistory>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserTranslationHistoryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserTranslationHistory>(
      where: where(UserTranslationHistory.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserTranslationHistoryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserTranslationHistory>(
      where: where?.call(UserTranslationHistory.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
