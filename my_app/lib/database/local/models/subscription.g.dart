// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubscriptionCollection on Isar {
  IsarCollection<Subscription> get subscriptions => this.collection();
}

const SubscriptionSchema = CollectionSchema(
  name: r'Subscription',
  id: -3426239935225026138,
  properties: {
    r'expiresAt': PropertySchema(
      id: 0,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'lastValidatedAt': PropertySchema(
      id: 1,
      name: r'lastValidatedAt',
      type: IsarType.dateTime,
    ),
    r'offlineGraceUntil': PropertySchema(
      id: 2,
      name: r'offlineGraceUntil',
      type: IsarType.dateTime,
    ),
    r'plan': PropertySchema(id: 3, name: r'plan', type: IsarType.string),
    r'status': PropertySchema(id: 4, name: r'status', type: IsarType.string),
    r'syncedAt': PropertySchema(
      id: 5,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'trialLimitSeconds': PropertySchema(
      id: 6,
      name: r'trialLimitSeconds',
      type: IsarType.long,
    ),
    r'trialUsedSeconds': PropertySchema(
      id: 7,
      name: r'trialUsedSeconds',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(id: 8, name: r'userId', type: IsarType.string),
  },

  estimateSize: _subscriptionEstimateSize,
  serialize: _subscriptionSerialize,
  deserialize: _subscriptionDeserialize,
  deserializeProp: _subscriptionDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
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

  getId: _subscriptionGetId,
  getLinks: _subscriptionGetLinks,
  attach: _subscriptionAttach,
  version: '3.3.2',
);

int _subscriptionEstimateSize(
  Subscription object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.plan.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _subscriptionSerialize(
  Subscription object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.expiresAt);
  writer.writeDateTime(offsets[1], object.lastValidatedAt);
  writer.writeDateTime(offsets[2], object.offlineGraceUntil);
  writer.writeString(offsets[3], object.plan);
  writer.writeString(offsets[4], object.status);
  writer.writeDateTime(offsets[5], object.syncedAt);
  writer.writeLong(offsets[6], object.trialLimitSeconds);
  writer.writeLong(offsets[7], object.trialUsedSeconds);
  writer.writeString(offsets[8], object.userId);
}

Subscription _subscriptionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Subscription();
  object.expiresAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.lastValidatedAt = reader.readDateTimeOrNull(offsets[1]);
  object.offlineGraceUntil = reader.readDateTimeOrNull(offsets[2]);
  object.plan = reader.readString(offsets[3]);
  object.status = reader.readString(offsets[4]);
  object.syncedAt = reader.readDateTimeOrNull(offsets[5]);
  object.trialLimitSeconds = reader.readLong(offsets[6]);
  object.trialUsedSeconds = reader.readLong(offsets[7]);
  object.userId = reader.readString(offsets[8]);
  return object;
}

P _subscriptionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subscriptionGetId(Subscription object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subscriptionGetLinks(Subscription object) {
  return [];
}

void _subscriptionAttach(
  IsarCollection<dynamic> col,
  Id id,
  Subscription object,
) {
  object.id = id;
}

extension SubscriptionByIndex on IsarCollection<Subscription> {
  Future<Subscription?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  Subscription? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<Subscription?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<Subscription?> getAllByUserIdSync(List<String> userIdValues) {
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

  Future<Id> putByUserId(Subscription object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(Subscription object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<Subscription> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(
    List<Subscription> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension SubscriptionQueryWhereSort
    on QueryBuilder<Subscription, Subscription, QWhere> {
  QueryBuilder<Subscription, Subscription, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubscriptionQueryWhere
    on QueryBuilder<Subscription, Subscription, QWhereClause> {
  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> idBetween(
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

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> userIdEqualTo(
    String userId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'userId', value: [userId]),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterWhereClause> userIdNotEqualTo(
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

extension SubscriptionQueryFilter
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {
  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  expiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  expiresAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  expiresAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastValidatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastValidatedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastValidatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastValidatedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastValidatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastValidatedAt', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastValidatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastValidatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastValidatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastValidatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  lastValidatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastValidatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  offlineGraceUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'offlineGraceUntil'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  offlineGraceUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'offlineGraceUntil'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  offlineGraceUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'offlineGraceUntil', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  offlineGraceUntilGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'offlineGraceUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  offlineGraceUntilLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'offlineGraceUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  offlineGraceUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'offlineGraceUntil',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> planEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'plan',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  planGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plan',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> planLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plan',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> planBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plan',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  planStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'plan',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> planEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'plan',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> planContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'plan',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> planMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'plan',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  planIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'plan', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  planIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'plan', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncedAt'),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncedAt', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  syncedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  syncedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialLimitSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialLimitSeconds', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialLimitSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialLimitSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialLimitSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialLimitSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialLimitSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialLimitSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialUsedSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trialUsedSeconds', value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialUsedSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trialUsedSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialUsedSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trialUsedSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  trialUsedSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trialUsedSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> userIdMatches(
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

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }
}

extension SubscriptionQueryObject
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {}

extension SubscriptionQueryLinks
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {}

extension SubscriptionQuerySortBy
    on QueryBuilder<Subscription, Subscription, QSortBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByLastValidatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidatedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByLastValidatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidatedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByOfflineGraceUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineGraceUntil', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByOfflineGraceUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineGraceUntil', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByPlan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByPlanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByTrialLimitSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialLimitSeconds', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByTrialLimitSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialLimitSeconds', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByTrialUsedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsedSeconds', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByTrialUsedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsedSeconds', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SubscriptionQuerySortThenBy
    on QueryBuilder<Subscription, Subscription, QSortThenBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByLastValidatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidatedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByLastValidatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidatedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByOfflineGraceUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineGraceUntil', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByOfflineGraceUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineGraceUntil', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByPlan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByPlanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByTrialLimitSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialLimitSeconds', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByTrialLimitSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialLimitSeconds', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByTrialUsedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsedSeconds', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByTrialUsedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsedSeconds', Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SubscriptionQueryWhereDistinct
    on QueryBuilder<Subscription, Subscription, QDistinct> {
  QueryBuilder<Subscription, Subscription, QDistinct> distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
  distinctByLastValidatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastValidatedAt');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
  distinctByOfflineGraceUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offlineGraceUntil');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByPlan({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plan', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
  distinctByTrialLimitSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialLimitSeconds');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct>
  distinctByTrialUsedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialUsedSeconds');
    });
  }

  QueryBuilder<Subscription, Subscription, QDistinct> distinctByUserId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SubscriptionQueryProperty
    on QueryBuilder<Subscription, Subscription, QQueryProperty> {
  QueryBuilder<Subscription, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations> expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations>
  lastValidatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastValidatedAt');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations>
  offlineGraceUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offlineGraceUntil');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> planProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plan');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Subscription, DateTime?, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<Subscription, int, QQueryOperations>
  trialLimitSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialLimitSeconds');
    });
  }

  QueryBuilder<Subscription, int, QQueryOperations> trialUsedSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialUsedSeconds');
    });
  }

  QueryBuilder<Subscription, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
