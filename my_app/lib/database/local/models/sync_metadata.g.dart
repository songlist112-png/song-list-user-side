// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metadata.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncMetadataCollection on Isar {
  IsarCollection<SyncMetadata> get syncMetadatas => this.collection();
}

const SyncMetadataSchema = CollectionSchema(
  name: r'SyncMetadata',
  id: 1560148770299903314,
  properties: {
    r'initialSongTotal': PropertySchema(
      id: 0,
      name: r'initialSongTotal',
      type: IsarType.long,
    ),
    r'initialSongsSynced': PropertySchema(
      id: 1,
      name: r'initialSongsSynced',
      type: IsarType.long,
    ),
    r'initialSyncComplete': PropertySchema(
      id: 2,
      name: r'initialSyncComplete',
      type: IsarType.bool,
    ),
    r'initialSyncUpperBound': PropertySchema(
      id: 3,
      name: r'initialSyncUpperBound',
      type: IsarType.dateTime,
    ),
    r'lastError': PropertySchema(
      id: 4,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'lastSuccessAt': PropertySchema(
      id: 5,
      name: r'lastSuccessAt',
      type: IsarType.dateTime,
    ),
    r'lastSync': PropertySchema(
      id: 6,
      name: r'lastSync',
      type: IsarType.dateTime,
    ),
    r'songCursorId': PropertySchema(
      id: 7,
      name: r'songCursorId',
      type: IsarType.string,
    ),
    r'songCursorUpdatedAt': PropertySchema(
      id: 8,
      name: r'songCursorUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncVersion': PropertySchema(
      id: 9,
      name: r'syncVersion',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(id: 10, name: r'userId', type: IsarType.string),
  },

  estimateSize: _syncMetadataEstimateSize,
  serialize: _syncMetadataSerialize,
  deserialize: _syncMetadataDeserialize,
  deserializeProp: _syncMetadataDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _syncMetadataGetId,
  getLinks: _syncMetadataGetLinks,
  attach: _syncMetadataAttach,
  version: '3.3.2',
);

int _syncMetadataEstimateSize(
  SyncMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.songCursorId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _syncMetadataSerialize(
  SyncMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.initialSongTotal);
  writer.writeLong(offsets[1], object.initialSongsSynced);
  writer.writeBool(offsets[2], object.initialSyncComplete);
  writer.writeDateTime(offsets[3], object.initialSyncUpperBound);
  writer.writeString(offsets[4], object.lastError);
  writer.writeDateTime(offsets[5], object.lastSuccessAt);
  writer.writeDateTime(offsets[6], object.lastSync);
  writer.writeString(offsets[7], object.songCursorId);
  writer.writeDateTime(offsets[8], object.songCursorUpdatedAt);
  writer.writeLong(offsets[9], object.syncVersion);
  writer.writeString(offsets[10], object.userId);
}

SyncMetadata _syncMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncMetadata();
  object.id = id;
  object.initialSongTotal = reader.readLongOrNull(offsets[0]);
  object.initialSongsSynced = reader.readLong(offsets[1]);
  object.initialSyncComplete = reader.readBool(offsets[2]);
  object.initialSyncUpperBound = reader.readDateTimeOrNull(offsets[3]);
  object.lastError = reader.readStringOrNull(offsets[4]);
  object.lastSuccessAt = reader.readDateTimeOrNull(offsets[5]);
  object.lastSync = reader.readDateTimeOrNull(offsets[6]);
  object.songCursorId = reader.readStringOrNull(offsets[7]);
  object.songCursorUpdatedAt = reader.readDateTimeOrNull(offsets[8]);
  object.syncVersion = reader.readLong(offsets[9]);
  object.userId = reader.readString(offsets[10]);
  return object;
}

P _syncMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncMetadataGetId(SyncMetadata object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncMetadataGetLinks(SyncMetadata object) {
  return [];
}

void _syncMetadataAttach(
  IsarCollection<dynamic> col,
  Id id,
  SyncMetadata object,
) {
  object.id = id;
}

extension SyncMetadataByIndex on IsarCollection<SyncMetadata> {
  Future<SyncMetadata?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  SyncMetadata? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<SyncMetadata?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<SyncMetadata?> getAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(SyncMetadata object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(SyncMetadata object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<SyncMetadata> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(
    List<SyncMetadata> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension SyncMetadataQueryWhereSort
    on QueryBuilder<SyncMetadata, SyncMetadata, QWhere> {
  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncMetadataQueryWhere
    on QueryBuilder<SyncMetadata, SyncMetadata, QWhereClause> {
  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhereClause> userIdEqualTo(
    String userId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'userId', value: [userId]),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterWhereClause> userIdNotEqualTo(
    String userId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SyncMetadataQueryFilter
    on QueryBuilder<SyncMetadata, SyncMetadata, QFilterCondition> {
  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'initialSongTotal'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'initialSongTotal'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongTotalEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'initialSongTotal', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongTotalGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'initialSongTotal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongTotalLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'initialSongTotal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongTotalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'initialSongTotal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongsSyncedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'initialSongsSynced', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongsSyncedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'initialSongsSynced',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongsSyncedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'initialSongsSynced',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSongsSyncedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'initialSongsSynced',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSyncCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'initialSyncComplete', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSyncUpperBoundIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'initialSyncUpperBound'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSyncUpperBoundIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'initialSyncUpperBound'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSyncUpperBoundEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'initialSyncUpperBound',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSyncUpperBoundGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'initialSyncUpperBound',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSyncUpperBoundLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'initialSyncUpperBound',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  initialSyncUpperBoundBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'initialSyncUpperBound',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSuccessAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSuccessAt'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSuccessAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSuccessAt'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSuccessAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSuccessAt', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSuccessAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSuccessAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSuccessAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSuccessAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSuccessAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSuccessAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSyncIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSync'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSyncIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSync'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSyncEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSync', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSyncGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSync',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSyncLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSync',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  lastSyncBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSync',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'songCursorId'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'songCursorId'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'songCursorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'songCursorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'songCursorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'songCursorId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'songCursorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'songCursorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'songCursorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'songCursorId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'songCursorId', value: ''),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'songCursorId', value: ''),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'songCursorUpdatedAt'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'songCursorUpdatedAt'),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'songCursorUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorUpdatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'songCursorUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorUpdatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'songCursorUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  songCursorUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'songCursorUpdatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  syncVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncVersion', value: value),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  syncVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  syncVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  syncVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  userIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  userIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition> userIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterFilterCondition>
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }
}

extension SyncMetadataQueryObject
    on QueryBuilder<SyncMetadata, SyncMetadata, QFilterCondition> {}

extension SyncMetadataQueryLinks
    on QueryBuilder<SyncMetadata, SyncMetadata, QFilterCondition> {}

extension SyncMetadataQuerySortBy
    on QueryBuilder<SyncMetadata, SyncMetadata, QSortBy> {
  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSongTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongTotal', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSongTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongTotal', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSongsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongsSynced', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSongsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongsSynced', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSyncComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncComplete', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSyncCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncComplete', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSyncUpperBound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncUpperBound', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByInitialSyncUpperBoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncUpperBound', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortByLastSuccessAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortByLastSuccessAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortByLastSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortByLastSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortBySongCursorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorId', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortBySongCursorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorId', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortBySongCursorUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortBySongCursorUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortBySyncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  sortBySyncVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncVersion', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SyncMetadataQuerySortThenBy
    on QueryBuilder<SyncMetadata, SyncMetadata, QSortThenBy> {
  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSongTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongTotal', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSongTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongTotal', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSongsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongsSynced', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSongsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSongsSynced', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSyncComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncComplete', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSyncCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncComplete', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSyncUpperBound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncUpperBound', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByInitialSyncUpperBoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialSyncUpperBound', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByLastSuccessAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenByLastSuccessAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSuccessAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByLastSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByLastSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenBySongCursorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorId', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenBySongCursorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorId', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenBySongCursorUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenBySongCursorUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCursorUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenBySyncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncVersion', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy>
  thenBySyncVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncVersion', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SyncMetadataQueryWhereDistinct
    on QueryBuilder<SyncMetadata, SyncMetadata, QDistinct> {
  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct>
  distinctByInitialSongTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialSongTotal');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct>
  distinctByInitialSongsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialSongsSynced');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct>
  distinctByInitialSyncComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialSyncComplete');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct>
  distinctByInitialSyncUpperBound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialSyncUpperBound');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct> distinctByLastError({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct>
  distinctByLastSuccessAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSuccessAt');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct> distinctByLastSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSync');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct> distinctBySongCursorId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songCursorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct>
  distinctBySongCursorUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songCursorUpdatedAt');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct> distinctBySyncVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncVersion');
    });
  }

  QueryBuilder<SyncMetadata, SyncMetadata, QDistinct> distinctByUserId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SyncMetadataQueryProperty
    on QueryBuilder<SyncMetadata, SyncMetadata, QQueryProperty> {
  QueryBuilder<SyncMetadata, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncMetadata, int?, QQueryOperations>
  initialSongTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialSongTotal');
    });
  }

  QueryBuilder<SyncMetadata, int, QQueryOperations>
  initialSongsSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialSongsSynced');
    });
  }

  QueryBuilder<SyncMetadata, bool, QQueryOperations>
  initialSyncCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialSyncComplete');
    });
  }

  QueryBuilder<SyncMetadata, DateTime?, QQueryOperations>
  initialSyncUpperBoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialSyncUpperBound');
    });
  }

  QueryBuilder<SyncMetadata, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<SyncMetadata, DateTime?, QQueryOperations>
  lastSuccessAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSuccessAt');
    });
  }

  QueryBuilder<SyncMetadata, DateTime?, QQueryOperations> lastSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSync');
    });
  }

  QueryBuilder<SyncMetadata, String?, QQueryOperations> songCursorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songCursorId');
    });
  }

  QueryBuilder<SyncMetadata, DateTime?, QQueryOperations>
  songCursorUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songCursorUpdatedAt');
    });
  }

  QueryBuilder<SyncMetadata, int, QQueryOperations> syncVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncVersion');
    });
  }

  QueryBuilder<SyncMetadata, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
