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

abstract class UserReviewResult
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserReviewResult._({
    this.id,
    required this.userIdentifier,
    required this.clientRecordId,
    required this.historyClientRecordId,
    required this.answerText,
    required this.grade,
    required this.reviewedAt,
    required this.updatedAt,
  });

  factory UserReviewResult({
    int? id,
    required String userIdentifier,
    required String clientRecordId,
    required String historyClientRecordId,
    required String answerText,
    required String grade,
    required DateTime reviewedAt,
    required DateTime updatedAt,
  }) = _UserReviewResultImpl;

  factory UserReviewResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserReviewResult(
      id: jsonSerialization['id'] as int?,
      userIdentifier: jsonSerialization['userIdentifier'] as String,
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

  static final t = UserReviewResultTable();

  static const db = UserReviewResultRepository._();

  @override
  int? id;

  String userIdentifier;

  String clientRecordId;

  String historyClientRecordId;

  String answerText;

  String grade;

  DateTime reviewedAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserReviewResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserReviewResult copyWith({
    int? id,
    String? userIdentifier,
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
      '__className__': 'UserReviewResult',
      if (id != null) 'id': id,
      'userIdentifier': userIdentifier,
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
    return {};
  }

  static UserReviewResultInclude include() {
    return UserReviewResultInclude._();
  }

  static UserReviewResultIncludeList includeList({
    _i1.WhereExpressionBuilder<UserReviewResultTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserReviewResultTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserReviewResultTable>? orderByList,
    UserReviewResultInclude? include,
  }) {
    return UserReviewResultIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserReviewResult.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserReviewResult.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserReviewResultImpl extends UserReviewResult {
  _UserReviewResultImpl({
    int? id,
    required String userIdentifier,
    required String clientRecordId,
    required String historyClientRecordId,
    required String answerText,
    required String grade,
    required DateTime reviewedAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userIdentifier: userIdentifier,
         clientRecordId: clientRecordId,
         historyClientRecordId: historyClientRecordId,
         answerText: answerText,
         grade: grade,
         reviewedAt: reviewedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserReviewResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserReviewResult copyWith({
    Object? id = _Undefined,
    String? userIdentifier,
    String? clientRecordId,
    String? historyClientRecordId,
    String? answerText,
    String? grade,
    DateTime? reviewedAt,
    DateTime? updatedAt,
  }) {
    return UserReviewResult(
      id: id is int? ? id : this.id,
      userIdentifier: userIdentifier ?? this.userIdentifier,
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

class UserReviewResultUpdateTable
    extends _i1.UpdateTable<UserReviewResultTable> {
  UserReviewResultUpdateTable(super.table);

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

  _i1.ColumnValue<String, String> historyClientRecordId(String value) =>
      _i1.ColumnValue(
        table.historyClientRecordId,
        value,
      );

  _i1.ColumnValue<String, String> answerText(String value) => _i1.ColumnValue(
    table.answerText,
    value,
  );

  _i1.ColumnValue<String, String> grade(String value) => _i1.ColumnValue(
    table.grade,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> reviewedAt(DateTime value) =>
      _i1.ColumnValue(
        table.reviewedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class UserReviewResultTable extends _i1.Table<int?> {
  UserReviewResultTable({super.tableRelation})
    : super(tableName: 'user_review_result') {
    updateTable = UserReviewResultUpdateTable(this);
    userIdentifier = _i1.ColumnString(
      'userIdentifier',
      this,
    );
    clientRecordId = _i1.ColumnString(
      'clientRecordId',
      this,
    );
    historyClientRecordId = _i1.ColumnString(
      'historyClientRecordId',
      this,
    );
    answerText = _i1.ColumnString(
      'answerText',
      this,
    );
    grade = _i1.ColumnString(
      'grade',
      this,
    );
    reviewedAt = _i1.ColumnDateTime(
      'reviewedAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final UserReviewResultUpdateTable updateTable;

  late final _i1.ColumnString userIdentifier;

  late final _i1.ColumnString clientRecordId;

  late final _i1.ColumnString historyClientRecordId;

  late final _i1.ColumnString answerText;

  late final _i1.ColumnString grade;

  late final _i1.ColumnDateTime reviewedAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userIdentifier,
    clientRecordId,
    historyClientRecordId,
    answerText,
    grade,
    reviewedAt,
    updatedAt,
  ];
}

class UserReviewResultInclude extends _i1.IncludeObject {
  UserReviewResultInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserReviewResult.t;
}

class UserReviewResultIncludeList extends _i1.IncludeList {
  UserReviewResultIncludeList._({
    _i1.WhereExpressionBuilder<UserReviewResultTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserReviewResult.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserReviewResult.t;
}

class UserReviewResultRepository {
  const UserReviewResultRepository._();

  /// Returns a list of [UserReviewResult]s matching the given query parameters.
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
  Future<List<UserReviewResult>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserReviewResultTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserReviewResultTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserReviewResultTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserReviewResult>(
      where: where?.call(UserReviewResult.t),
      orderBy: orderBy?.call(UserReviewResult.t),
      orderByList: orderByList?.call(UserReviewResult.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [UserReviewResult] matching the given query parameters.
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
  Future<UserReviewResult?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserReviewResultTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserReviewResultTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserReviewResultTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<UserReviewResult>(
      where: where?.call(UserReviewResult.t),
      orderBy: orderBy?.call(UserReviewResult.t),
      orderByList: orderByList?.call(UserReviewResult.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [UserReviewResult] by its [id] or null if no such row exists.
  Future<UserReviewResult?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<UserReviewResult>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [UserReviewResult]s in the list and returns the inserted rows.
  ///
  /// The returned [UserReviewResult]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<UserReviewResult>> insert(
    _i1.Session session,
    List<UserReviewResult> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserReviewResult>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [UserReviewResult] and returns the inserted row.
  ///
  /// The returned [UserReviewResult] will have its `id` field set.
  Future<UserReviewResult> insertRow(
    _i1.Session session,
    UserReviewResult row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserReviewResult>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserReviewResult]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserReviewResult>> update(
    _i1.Session session,
    List<UserReviewResult> rows, {
    _i1.ColumnSelections<UserReviewResultTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserReviewResult>(
      rows,
      columns: columns?.call(UserReviewResult.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserReviewResult]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserReviewResult> updateRow(
    _i1.Session session,
    UserReviewResult row, {
    _i1.ColumnSelections<UserReviewResultTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserReviewResult>(
      row,
      columns: columns?.call(UserReviewResult.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserReviewResult] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserReviewResult?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserReviewResultUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserReviewResult>(
      id,
      columnValues: columnValues(UserReviewResult.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserReviewResult]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserReviewResult>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserReviewResultUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<UserReviewResultTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserReviewResultTable>? orderBy,
    _i1.OrderByListBuilder<UserReviewResultTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserReviewResult>(
      columnValues: columnValues(UserReviewResult.t.updateTable),
      where: where(UserReviewResult.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserReviewResult.t),
      orderByList: orderByList?.call(UserReviewResult.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserReviewResult]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserReviewResult>> delete(
    _i1.Session session,
    List<UserReviewResult> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserReviewResult>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserReviewResult].
  Future<UserReviewResult> deleteRow(
    _i1.Session session,
    UserReviewResult row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserReviewResult>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserReviewResult>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserReviewResultTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserReviewResult>(
      where: where(UserReviewResult.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserReviewResultTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserReviewResult>(
      where: where?.call(UserReviewResult.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
