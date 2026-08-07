// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_records.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSupportTicketRecordCollection on Isar {
  IsarCollection<SupportTicketRecord> get supportTicketRecords =>
      this.collection();
}

const SupportTicketRecordSchema = CollectionSchema(
  name: r'SupportTicketRecord',
  id: 2747700886041770348,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'pendingSync': PropertySchema(
      id: 1,
      name: r'pendingSync',
      type: IsarType.bool,
    ),
    r'status': PropertySchema(id: 2, name: r'status', type: IsarType.string),
    r'subject': PropertySchema(id: 3, name: r'subject', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(id: 5, name: r'userId', type: IsarType.string),
    r'uuid': PropertySchema(id: 6, name: r'uuid', type: IsarType.string),
  },
  estimateSize: _supportTicketRecordEstimateSize,
  serialize: _supportTicketRecordSerialize,
  deserialize: _supportTicketRecordDeserialize,
  deserializeProp: _supportTicketRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
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
  },
  links: {},
  embeddedSchemas: {},
  getId: _supportTicketRecordGetId,
  getLinks: _supportTicketRecordGetLinks,
  attach: _supportTicketRecordAttach,
  version: '3.1.0+1',
);

int _supportTicketRecordEstimateSize(
  SupportTicketRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.subject.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _supportTicketRecordSerialize(
  SupportTicketRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.pendingSync);
  writer.writeString(offsets[2], object.status);
  writer.writeString(offsets[3], object.subject);
  writer.writeDateTime(offsets[4], object.updatedAt);
  writer.writeString(offsets[5], object.userId);
  writer.writeString(offsets[6], object.uuid);
}

SupportTicketRecord _supportTicketRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SupportTicketRecord();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.pendingSync = reader.readBool(offsets[1]);
  object.status = reader.readString(offsets[2]);
  object.subject = reader.readString(offsets[3]);
  object.updatedAt = reader.readDateTime(offsets[4]);
  object.userId = reader.readString(offsets[5]);
  object.uuid = reader.readString(offsets[6]);
  return object;
}

P _supportTicketRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _supportTicketRecordGetId(SupportTicketRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _supportTicketRecordGetLinks(
  SupportTicketRecord object,
) {
  return [];
}

void _supportTicketRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  SupportTicketRecord object,
) {
  object.id = id;
}

extension SupportTicketRecordByIndex on IsarCollection<SupportTicketRecord> {
  Future<SupportTicketRecord?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  SupportTicketRecord? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<SupportTicketRecord?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<SupportTicketRecord?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(SupportTicketRecord object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(SupportTicketRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<SupportTicketRecord> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<SupportTicketRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension SupportTicketRecordQueryWhereSort
    on QueryBuilder<SupportTicketRecord, SupportTicketRecord, QWhere> {
  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SupportTicketRecordQueryWhere
    on QueryBuilder<SupportTicketRecord, SupportTicketRecord, QWhereClause> {
  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
  uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
  userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'userId', value: [userId]),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterWhereClause>
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
}

extension SupportTicketRecordQueryFilter
    on
        QueryBuilder<
          SupportTicketRecord,
          SupportTicketRecord,
          QFilterCondition
        > {
  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  pendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pendingSync', value: value),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subject',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'subject',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subject', value: ''),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'subject', value: ''),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
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

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension SupportTicketRecordQueryObject
    on
        QueryBuilder<
          SupportTicketRecord,
          SupportTicketRecord,
          QFilterCondition
        > {}

extension SupportTicketRecordQueryLinks
    on
        QueryBuilder<
          SupportTicketRecord,
          SupportTicketRecord,
          QFilterCondition
        > {}

extension SupportTicketRecordQuerySortBy
    on QueryBuilder<SupportTicketRecord, SupportTicketRecord, QSortBy> {
  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension SupportTicketRecordQuerySortThenBy
    on QueryBuilder<SupportTicketRecord, SupportTicketRecord, QSortThenBy> {
  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension SupportTicketRecordQueryWhereDistinct
    on QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct> {
  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct>
  distinctByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingSync');
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct>
  distinctBySubject({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct>
  distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SupportTicketRecord, SupportTicketRecord, QDistinct>
  distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension SupportTicketRecordQueryProperty
    on QueryBuilder<SupportTicketRecord, SupportTicketRecord, QQueryProperty> {
  QueryBuilder<SupportTicketRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SupportTicketRecord, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SupportTicketRecord, bool, QQueryOperations>
  pendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingSync');
    });
  }

  QueryBuilder<SupportTicketRecord, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SupportTicketRecord, String, QQueryOperations>
  subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<SupportTicketRecord, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SupportTicketRecord, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<SupportTicketRecord, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSupportMessageRecordCollection on Isar {
  IsarCollection<SupportMessageRecord> get supportMessageRecords =>
      this.collection();
}

const SupportMessageRecordSchema = CollectionSchema(
  name: r'SupportMessageRecord',
  id: -5085970759434796936,
  properties: {
    r'attachmentLocalPath': PropertySchema(
      id: 0,
      name: r'attachmentLocalPath',
      type: IsarType.string,
    ),
    r'attachmentName': PropertySchema(
      id: 1,
      name: r'attachmentName',
      type: IsarType.string,
    ),
    r'attachmentRemotePath': PropertySchema(
      id: 2,
      name: r'attachmentRemotePath',
      type: IsarType.string,
    ),
    r'attachmentSize': PropertySchema(
      id: 3,
      name: r'attachmentSize',
      type: IsarType.long,
    ),
    r'attachmentType': PropertySchema(
      id: 4,
      name: r'attachmentType',
      type: IsarType.string,
    ),
    r'body': PropertySchema(id: 5, name: r'body', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isFromSupport': PropertySchema(
      id: 7,
      name: r'isFromSupport',
      type: IsarType.bool,
    ),
    r'pendingSync': PropertySchema(
      id: 8,
      name: r'pendingSync',
      type: IsarType.bool,
    ),
    r'ticketId': PropertySchema(
      id: 9,
      name: r'ticketId',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(id: 10, name: r'userId', type: IsarType.string),
    r'uuid': PropertySchema(id: 11, name: r'uuid', type: IsarType.string),
  },
  estimateSize: _supportMessageRecordEstimateSize,
  serialize: _supportMessageRecordSerialize,
  deserialize: _supportMessageRecordDeserialize,
  deserializeProp: _supportMessageRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'ticketId': IndexSchema(
      id: -6483959237056329942,
      name: r'ticketId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ticketId',
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
  },
  links: {},
  embeddedSchemas: {},
  getId: _supportMessageRecordGetId,
  getLinks: _supportMessageRecordGetLinks,
  attach: _supportMessageRecordAttach,
  version: '3.1.0+1',
);

int _supportMessageRecordEstimateSize(
  SupportMessageRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.attachmentLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.attachmentName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.attachmentRemotePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.attachmentType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.body.length * 3;
  bytesCount += 3 + object.ticketId.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _supportMessageRecordSerialize(
  SupportMessageRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.attachmentLocalPath);
  writer.writeString(offsets[1], object.attachmentName);
  writer.writeString(offsets[2], object.attachmentRemotePath);
  writer.writeLong(offsets[3], object.attachmentSize);
  writer.writeString(offsets[4], object.attachmentType);
  writer.writeString(offsets[5], object.body);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeBool(offsets[7], object.isFromSupport);
  writer.writeBool(offsets[8], object.pendingSync);
  writer.writeString(offsets[9], object.ticketId);
  writer.writeString(offsets[10], object.userId);
  writer.writeString(offsets[11], object.uuid);
}

SupportMessageRecord _supportMessageRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SupportMessageRecord();
  object.attachmentLocalPath = reader.readStringOrNull(offsets[0]);
  object.attachmentName = reader.readStringOrNull(offsets[1]);
  object.attachmentRemotePath = reader.readStringOrNull(offsets[2]);
  object.attachmentSize = reader.readLongOrNull(offsets[3]);
  object.attachmentType = reader.readStringOrNull(offsets[4]);
  object.body = reader.readString(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.id = id;
  object.isFromSupport = reader.readBool(offsets[7]);
  object.pendingSync = reader.readBool(offsets[8]);
  object.ticketId = reader.readString(offsets[9]);
  object.userId = reader.readString(offsets[10]);
  object.uuid = reader.readString(offsets[11]);
  return object;
}

P _supportMessageRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _supportMessageRecordGetId(SupportMessageRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _supportMessageRecordGetLinks(
  SupportMessageRecord object,
) {
  return [];
}

void _supportMessageRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  SupportMessageRecord object,
) {
  object.id = id;
}

extension SupportMessageRecordByIndex on IsarCollection<SupportMessageRecord> {
  Future<SupportMessageRecord?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  SupportMessageRecord? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<SupportMessageRecord?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<SupportMessageRecord?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(SupportMessageRecord object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(SupportMessageRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<SupportMessageRecord> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<SupportMessageRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension SupportMessageRecordQueryWhereSort
    on QueryBuilder<SupportMessageRecord, SupportMessageRecord, QWhere> {
  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SupportMessageRecordQueryWhere
    on QueryBuilder<SupportMessageRecord, SupportMessageRecord, QWhereClause> {
  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
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

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
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

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  ticketIdEqualTo(String ticketId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ticketId', value: [ticketId]),
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  ticketIdNotEqualTo(String ticketId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ticketId',
                lower: [],
                upper: [ticketId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ticketId',
                lower: [ticketId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ticketId',
                lower: [ticketId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ticketId',
                lower: [],
                upper: [ticketId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
  userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'userId', value: [userId]),
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterWhereClause>
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
}

extension SupportMessageRecordQueryFilter
    on
        QueryBuilder<
          SupportMessageRecord,
          SupportMessageRecord,
          QFilterCondition
        > {
  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'attachmentLocalPath'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'attachmentLocalPath'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'attachmentLocalPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attachmentLocalPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attachmentLocalPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attachmentLocalPath',
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'attachmentLocalPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'attachmentLocalPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'attachmentLocalPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'attachmentLocalPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attachmentLocalPath', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'attachmentLocalPath',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'attachmentName'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'attachmentName'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'attachmentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attachmentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attachmentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attachmentName',
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'attachmentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'attachmentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'attachmentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'attachmentName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attachmentName', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'attachmentName', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'attachmentRemotePath'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'attachmentRemotePath'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'attachmentRemotePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attachmentRemotePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attachmentRemotePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attachmentRemotePath',
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'attachmentRemotePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'attachmentRemotePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'attachmentRemotePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'attachmentRemotePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attachmentRemotePath', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentRemotePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'attachmentRemotePath',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'attachmentSize'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'attachmentSize'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentSizeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attachmentSize', value: value),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentSizeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attachmentSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentSizeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attachmentSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentSizeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attachmentSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'attachmentType'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'attachmentType'),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'attachmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attachmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attachmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attachmentType',
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'attachmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'attachmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'attachmentType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'attachmentType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attachmentType', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  attachmentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'attachmentType', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'body',
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'body',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'body',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'body', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'body', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  isFromSupportEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFromSupport', value: value),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  pendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pendingSync', value: value),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ticketId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ticketId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ticketId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ticketId',
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ticketId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ticketId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ticketId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ticketId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ticketId', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  ticketIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ticketId', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
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
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<
    SupportMessageRecord,
    SupportMessageRecord,
    QAfterFilterCondition
  >
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension SupportMessageRecordQueryObject
    on
        QueryBuilder<
          SupportMessageRecord,
          SupportMessageRecord,
          QFilterCondition
        > {}

extension SupportMessageRecordQueryLinks
    on
        QueryBuilder<
          SupportMessageRecord,
          SupportMessageRecord,
          QFilterCondition
        > {}

extension SupportMessageRecordQuerySortBy
    on QueryBuilder<SupportMessageRecord, SupportMessageRecord, QSortBy> {
  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentLocalPath', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentLocalPath', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentName', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentName', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentRemotePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentRemotePath', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentRemotePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentRemotePath', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentSize', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentSize', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentType', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByAttachmentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentType', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByIsFromSupport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFromSupport', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByIsFromSupportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFromSupport', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByTicketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ticketId', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByTicketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ticketId', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension SupportMessageRecordQuerySortThenBy
    on QueryBuilder<SupportMessageRecord, SupportMessageRecord, QSortThenBy> {
  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentLocalPath', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentLocalPath', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentName', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentName', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentRemotePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentRemotePath', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentRemotePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentRemotePath', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentSize', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentSize', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentType', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByAttachmentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentType', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByIsFromSupport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFromSupport', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByIsFromSupportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFromSupport', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByTicketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ticketId', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByTicketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ticketId', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension SupportMessageRecordQueryWhereDistinct
    on QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct> {
  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByAttachmentLocalPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'attachmentLocalPath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByAttachmentName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'attachmentName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByAttachmentRemotePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'attachmentRemotePath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByAttachmentSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachmentSize');
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByAttachmentType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'attachmentType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByBody({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByIsFromSupport() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFromSupport');
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingSync');
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByTicketId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ticketId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SupportMessageRecord, SupportMessageRecord, QDistinct>
  distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension SupportMessageRecordQueryProperty
    on
        QueryBuilder<
          SupportMessageRecord,
          SupportMessageRecord,
          QQueryProperty
        > {
  QueryBuilder<SupportMessageRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SupportMessageRecord, String?, QQueryOperations>
  attachmentLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentLocalPath');
    });
  }

  QueryBuilder<SupportMessageRecord, String?, QQueryOperations>
  attachmentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentName');
    });
  }

  QueryBuilder<SupportMessageRecord, String?, QQueryOperations>
  attachmentRemotePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentRemotePath');
    });
  }

  QueryBuilder<SupportMessageRecord, int?, QQueryOperations>
  attachmentSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentSize');
    });
  }

  QueryBuilder<SupportMessageRecord, String?, QQueryOperations>
  attachmentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentType');
    });
  }

  QueryBuilder<SupportMessageRecord, String, QQueryOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<SupportMessageRecord, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SupportMessageRecord, bool, QQueryOperations>
  isFromSupportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFromSupport');
    });
  }

  QueryBuilder<SupportMessageRecord, bool, QQueryOperations>
  pendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingSync');
    });
  }

  QueryBuilder<SupportMessageRecord, String, QQueryOperations>
  ticketIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ticketId');
    });
  }

  QueryBuilder<SupportMessageRecord, String, QQueryOperations>
  userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<SupportMessageRecord, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
