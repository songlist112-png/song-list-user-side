// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_song_edit.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPersonalSongEditRecordCollection on Isar {
  IsarCollection<PersonalSongEditRecord> get personalSongEditRecords =>
      this.collection();
}

const PersonalSongEditRecordSchema = CollectionSchema(
  name: r'PersonalSongEditRecord',
  id: 9036764736627312976,
  properties: {
    r'cacheKey': PropertySchema(
      id: 0,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'clientUpdatedAt': PropertySchema(
      id: 1,
      name: r'clientUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'deleted': PropertySchema(id: 2, name: r'deleted', type: IsarType.bool),
    r'editId': PropertySchema(id: 3, name: r'editId', type: IsarType.string),
    r'lyrics': PropertySchema(id: 4, name: r'lyrics', type: IsarType.string),
    r'serverUpdatedAt': PropertySchema(
      id: 5,
      name: r'serverUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'songId': PropertySchema(id: 6, name: r'songId', type: IsarType.string),
    r'userId': PropertySchema(id: 7, name: r'userId', type: IsarType.string),
  },

  estimateSize: _personalSongEditRecordEstimateSize,
  serialize: _personalSongEditRecordSerialize,
  deserialize: _personalSongEditRecordDeserialize,
  deserializeProp: _personalSongEditRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'cacheKey': IndexSchema(
      id: 5885332021012296610,
      name: r'cacheKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'cacheKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'songId': IndexSchema(
      id: -4588889454650216128,
      name: r'songId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'songId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _personalSongEditRecordGetId,
  getLinks: _personalSongEditRecordGetLinks,
  attach: _personalSongEditRecordAttach,
  version: '3.3.2',
);

int _personalSongEditRecordEstimateSize(
  PersonalSongEditRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cacheKey.length * 3;
  bytesCount += 3 + object.editId.length * 3;
  bytesCount += 3 + object.lyrics.length * 3;
  bytesCount += 3 + object.songId.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _personalSongEditRecordSerialize(
  PersonalSongEditRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cacheKey);
  writer.writeDateTime(offsets[1], object.clientUpdatedAt);
  writer.writeBool(offsets[2], object.deleted);
  writer.writeString(offsets[3], object.editId);
  writer.writeString(offsets[4], object.lyrics);
  writer.writeDateTime(offsets[5], object.serverUpdatedAt);
  writer.writeString(offsets[6], object.songId);
  writer.writeString(offsets[7], object.userId);
}

PersonalSongEditRecord _personalSongEditRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PersonalSongEditRecord();
  object.cacheKey = reader.readString(offsets[0]);
  object.clientUpdatedAt = reader.readDateTime(offsets[1]);
  object.deleted = reader.readBool(offsets[2]);
  object.editId = reader.readString(offsets[3]);
  object.id = id;
  object.lyrics = reader.readString(offsets[4]);
  object.serverUpdatedAt = reader.readDateTimeOrNull(offsets[5]);
  object.songId = reader.readString(offsets[6]);
  object.userId = reader.readString(offsets[7]);
  return object;
}

P _personalSongEditRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _personalSongEditRecordGetId(PersonalSongEditRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _personalSongEditRecordGetLinks(
  PersonalSongEditRecord object,
) {
  return [];
}

void _personalSongEditRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  PersonalSongEditRecord object,
) {
  object.id = id;
}

extension PersonalSongEditRecordByIndex
    on IsarCollection<PersonalSongEditRecord> {
  Future<PersonalSongEditRecord?> getByCacheKey(String cacheKey) {
    return getByIndex(r'cacheKey', [cacheKey]);
  }

  PersonalSongEditRecord? getByCacheKeySync(String cacheKey) {
    return getByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<bool> deleteByCacheKey(String cacheKey) {
    return deleteByIndex(r'cacheKey', [cacheKey]);
  }

  bool deleteByCacheKeySync(String cacheKey) {
    return deleteByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<List<PersonalSongEditRecord?>> getAllByCacheKey(
    List<String> cacheKeyValues,
  ) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'cacheKey', values);
  }

  List<PersonalSongEditRecord?> getAllByCacheKeySync(
    List<String> cacheKeyValues,
  ) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cacheKey', values);
  }

  Future<int> deleteAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cacheKey', values);
  }

  int deleteAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cacheKey', values);
  }

  Future<Id> putByCacheKey(PersonalSongEditRecord object) {
    return putByIndex(r'cacheKey', object);
  }

  Id putByCacheKeySync(PersonalSongEditRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'cacheKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCacheKey(List<PersonalSongEditRecord> objects) {
    return putAllByIndex(r'cacheKey', objects);
  }

  List<Id> putAllByCacheKeySync(
    List<PersonalSongEditRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'cacheKey', objects, saveLinks: saveLinks);
  }
}

extension PersonalSongEditRecordQueryWhereSort
    on QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QWhere> {
  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PersonalSongEditRecordQueryWhere
    on
        QueryBuilder<
          PersonalSongEditRecord,
          PersonalSongEditRecord,
          QWhereClause
        > {
  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  idBetween(
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  cacheKeyEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'cacheKey', value: [cacheKey]),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  cacheKeyNotEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cacheKey',
                lower: [],
                upper: [cacheKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cacheKey',
                lower: [cacheKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cacheKey',
                lower: [cacheKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'cacheKey',
                lower: [],
                upper: [cacheKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'userId', value: [userId]),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  userIdNotEqualTo(String userId) {
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  songIdEqualTo(String songId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'songId', value: [songId]),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterWhereClause
  >
  songIdNotEqualTo(String songId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [],
                upper: [songId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [songId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [songId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'songId',
                lower: [],
                upper: [songId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PersonalSongEditRecordQueryFilter
    on
        QueryBuilder<
          PersonalSongEditRecord,
          PersonalSongEditRecord,
          QFilterCondition
        > {
  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cacheKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cacheKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cacheKey', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cacheKey', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  clientUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'clientUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  clientUpdatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'clientUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  clientUpdatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'clientUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  clientUpdatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'clientUpdatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  deletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deleted', value: value),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'editId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'editId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'editId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'editId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'editId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'editId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'editId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'editId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'editId', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  editIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'editId', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  idBetween(
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lyrics',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lyrics',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lyrics',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lyrics',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lyrics',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lyrics',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lyrics',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lyrics',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lyrics', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  lyricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lyrics', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  serverUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'serverUpdatedAt'),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  serverUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'serverUpdatedAt'),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  serverUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serverUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  serverUpdatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serverUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  serverUpdatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serverUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  serverUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serverUpdatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'songId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'songId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'songId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'songId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'songId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'songId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'songId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'songId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'songId', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  songIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'songId', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  userIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  userIdBetween(
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  userIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<
    PersonalSongEditRecord,
    PersonalSongEditRecord,
    QAfterFilterCondition
  >
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }
}

extension PersonalSongEditRecordQueryObject
    on
        QueryBuilder<
          PersonalSongEditRecord,
          PersonalSongEditRecord,
          QFilterCondition
        > {}

extension PersonalSongEditRecordQueryLinks
    on
        QueryBuilder<
          PersonalSongEditRecord,
          PersonalSongEditRecord,
          QFilterCondition
        > {}

extension PersonalSongEditRecordQuerySortBy
    on QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QSortBy> {
  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByClientUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByClientUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByEditId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editId', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByEditIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editId', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByServerUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByServerUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PersonalSongEditRecordQuerySortThenBy
    on
        QueryBuilder<
          PersonalSongEditRecord,
          PersonalSongEditRecord,
          QSortThenBy
        > {
  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByClientUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByClientUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByEditId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editId', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByEditIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'editId', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByLyrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByLyricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lyrics', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByServerUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByServerUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QAfterSortBy>
  thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PersonalSongEditRecordQueryWhereDistinct
    on QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct> {
  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctByCacheKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctByClientUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientUpdatedAt');
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctByEditId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'editId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctByLyrics({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lyrics', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctByServerUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverUpdatedAt');
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctBySongId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSongEditRecord, PersonalSongEditRecord, QDistinct>
  distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension PersonalSongEditRecordQueryProperty
    on
        QueryBuilder<
          PersonalSongEditRecord,
          PersonalSongEditRecord,
          QQueryProperty
        > {
  QueryBuilder<PersonalSongEditRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PersonalSongEditRecord, String, QQueryOperations>
  cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<PersonalSongEditRecord, DateTime, QQueryOperations>
  clientUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientUpdatedAt');
    });
  }

  QueryBuilder<PersonalSongEditRecord, bool, QQueryOperations>
  deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<PersonalSongEditRecord, String, QQueryOperations>
  editIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'editId');
    });
  }

  QueryBuilder<PersonalSongEditRecord, String, QQueryOperations>
  lyricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lyrics');
    });
  }

  QueryBuilder<PersonalSongEditRecord, DateTime?, QQueryOperations>
  serverUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverUpdatedAt');
    });
  }

  QueryBuilder<PersonalSongEditRecord, String, QQueryOperations>
  songIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songId');
    });
  }

  QueryBuilder<PersonalSongEditRecord, String, QQueryOperations>
  userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
