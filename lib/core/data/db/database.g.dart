// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OpsTable extends Ops with TableInfo<$OpsTable, OpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeIdMeta = const VerificationMeta('homeId');
  @override
  late final GeneratedColumn<String> homeId = GeneratedColumn<String>(
    'home_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMemberIdMeta = const VerificationMeta(
    'authorMemberId',
  );
  @override
  late final GeneratedColumn<String> authorMemberId = GeneratedColumn<String>(
    'author_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<String> changeId = GeneratedColumn<String>(
    'change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tblMeta = const VerificationMeta('tbl');
  @override
  late final GeneratedColumn<String> tbl = GeneratedColumn<String>(
    'tbl',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sigMeta = const VerificationMeta('sig');
  @override
  late final GeneratedColumn<String> sig = GeneratedColumn<String>(
    'sig',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('applied'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    homeId,
    deviceId,
    seq,
    hlc,
    authorMemberId,
    changeId,
    tbl,
    entityId,
    kind,
    field,
    valueJson,
    delta,
    sig,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('home_id')) {
      context.handle(
        _homeIdMeta,
        homeId.isAcceptableOrUnknown(data['home_id']!, _homeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_homeIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('author_member_id')) {
      context.handle(
        _authorMemberIdMeta,
        authorMemberId.isAcceptableOrUnknown(
          data['author_member_id']!,
          _authorMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorMemberIdMeta);
    }
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_changeIdMeta);
    }
    if (data.containsKey('tbl')) {
      context.handle(
        _tblMeta,
        tbl.isAcceptableOrUnknown(data['tbl']!, _tblMeta),
      );
    } else if (isInserting) {
      context.missing(_tblMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    }
    if (data.containsKey('sig')) {
      context.handle(
        _sigMeta,
        sig.isAcceptableOrUnknown(data['sig']!, _sigMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  OpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      homeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      authorMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_member_id'],
      )!,
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_id'],
      )!,
      tbl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tbl'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      ),
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      ),
      sig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sig'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $OpsTable createAlias(String alias) {
    return $OpsTable(attachedDatabase, alias);
  }
}

class OpRow extends DataClass implements Insertable<OpRow> {
  final String opId;
  final String homeId;
  final String deviceId;
  final int seq;
  final String hlc;
  final String authorMemberId;
  final String changeId;
  final String tbl;
  final String entityId;
  final String kind;
  final String field;
  final String? valueJson;
  final int? delta;
  final String sig;
  final String status;
  const OpRow({
    required this.opId,
    required this.homeId,
    required this.deviceId,
    required this.seq,
    required this.hlc,
    required this.authorMemberId,
    required this.changeId,
    required this.tbl,
    required this.entityId,
    required this.kind,
    required this.field,
    this.valueJson,
    this.delta,
    required this.sig,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['home_id'] = Variable<String>(homeId);
    map['device_id'] = Variable<String>(deviceId);
    map['seq'] = Variable<int>(seq);
    map['hlc'] = Variable<String>(hlc);
    map['author_member_id'] = Variable<String>(authorMemberId);
    map['change_id'] = Variable<String>(changeId);
    map['tbl'] = Variable<String>(tbl);
    map['entity_id'] = Variable<String>(entityId);
    map['kind'] = Variable<String>(kind);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || valueJson != null) {
      map['value_json'] = Variable<String>(valueJson);
    }
    if (!nullToAbsent || delta != null) {
      map['delta'] = Variable<int>(delta);
    }
    map['sig'] = Variable<String>(sig);
    map['status'] = Variable<String>(status);
    return map;
  }

  OpsCompanion toCompanion(bool nullToAbsent) {
    return OpsCompanion(
      opId: Value(opId),
      homeId: Value(homeId),
      deviceId: Value(deviceId),
      seq: Value(seq),
      hlc: Value(hlc),
      authorMemberId: Value(authorMemberId),
      changeId: Value(changeId),
      tbl: Value(tbl),
      entityId: Value(entityId),
      kind: Value(kind),
      field: Value(field),
      valueJson: valueJson == null && nullToAbsent
          ? const Value.absent()
          : Value(valueJson),
      delta: delta == null && nullToAbsent
          ? const Value.absent()
          : Value(delta),
      sig: Value(sig),
      status: Value(status),
    );
  }

  factory OpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpRow(
      opId: serializer.fromJson<String>(json['opId']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      seq: serializer.fromJson<int>(json['seq']),
      hlc: serializer.fromJson<String>(json['hlc']),
      authorMemberId: serializer.fromJson<String>(json['authorMemberId']),
      changeId: serializer.fromJson<String>(json['changeId']),
      tbl: serializer.fromJson<String>(json['tbl']),
      entityId: serializer.fromJson<String>(json['entityId']),
      kind: serializer.fromJson<String>(json['kind']),
      field: serializer.fromJson<String>(json['field']),
      valueJson: serializer.fromJson<String?>(json['valueJson']),
      delta: serializer.fromJson<int?>(json['delta']),
      sig: serializer.fromJson<String>(json['sig']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'homeId': serializer.toJson<String>(homeId),
      'deviceId': serializer.toJson<String>(deviceId),
      'seq': serializer.toJson<int>(seq),
      'hlc': serializer.toJson<String>(hlc),
      'authorMemberId': serializer.toJson<String>(authorMemberId),
      'changeId': serializer.toJson<String>(changeId),
      'tbl': serializer.toJson<String>(tbl),
      'entityId': serializer.toJson<String>(entityId),
      'kind': serializer.toJson<String>(kind),
      'field': serializer.toJson<String>(field),
      'valueJson': serializer.toJson<String?>(valueJson),
      'delta': serializer.toJson<int?>(delta),
      'sig': serializer.toJson<String>(sig),
      'status': serializer.toJson<String>(status),
    };
  }

  OpRow copyWith({
    String? opId,
    String? homeId,
    String? deviceId,
    int? seq,
    String? hlc,
    String? authorMemberId,
    String? changeId,
    String? tbl,
    String? entityId,
    String? kind,
    String? field,
    Value<String?> valueJson = const Value.absent(),
    Value<int?> delta = const Value.absent(),
    String? sig,
    String? status,
  }) => OpRow(
    opId: opId ?? this.opId,
    homeId: homeId ?? this.homeId,
    deviceId: deviceId ?? this.deviceId,
    seq: seq ?? this.seq,
    hlc: hlc ?? this.hlc,
    authorMemberId: authorMemberId ?? this.authorMemberId,
    changeId: changeId ?? this.changeId,
    tbl: tbl ?? this.tbl,
    entityId: entityId ?? this.entityId,
    kind: kind ?? this.kind,
    field: field ?? this.field,
    valueJson: valueJson.present ? valueJson.value : this.valueJson,
    delta: delta.present ? delta.value : this.delta,
    sig: sig ?? this.sig,
    status: status ?? this.status,
  );
  OpRow copyWithCompanion(OpsCompanion data) {
    return OpRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      seq: data.seq.present ? data.seq.value : this.seq,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      authorMemberId: data.authorMemberId.present
          ? data.authorMemberId.value
          : this.authorMemberId,
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      tbl: data.tbl.present ? data.tbl.value : this.tbl,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      kind: data.kind.present ? data.kind.value : this.kind,
      field: data.field.present ? data.field.value : this.field,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      delta: data.delta.present ? data.delta.value : this.delta,
      sig: data.sig.present ? data.sig.value : this.sig,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpRow(')
          ..write('opId: $opId, ')
          ..write('homeId: $homeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('seq: $seq, ')
          ..write('hlc: $hlc, ')
          ..write('authorMemberId: $authorMemberId, ')
          ..write('changeId: $changeId, ')
          ..write('tbl: $tbl, ')
          ..write('entityId: $entityId, ')
          ..write('kind: $kind, ')
          ..write('field: $field, ')
          ..write('valueJson: $valueJson, ')
          ..write('delta: $delta, ')
          ..write('sig: $sig, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    homeId,
    deviceId,
    seq,
    hlc,
    authorMemberId,
    changeId,
    tbl,
    entityId,
    kind,
    field,
    valueJson,
    delta,
    sig,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpRow &&
          other.opId == this.opId &&
          other.homeId == this.homeId &&
          other.deviceId == this.deviceId &&
          other.seq == this.seq &&
          other.hlc == this.hlc &&
          other.authorMemberId == this.authorMemberId &&
          other.changeId == this.changeId &&
          other.tbl == this.tbl &&
          other.entityId == this.entityId &&
          other.kind == this.kind &&
          other.field == this.field &&
          other.valueJson == this.valueJson &&
          other.delta == this.delta &&
          other.sig == this.sig &&
          other.status == this.status);
}

class OpsCompanion extends UpdateCompanion<OpRow> {
  final Value<String> opId;
  final Value<String> homeId;
  final Value<String> deviceId;
  final Value<int> seq;
  final Value<String> hlc;
  final Value<String> authorMemberId;
  final Value<String> changeId;
  final Value<String> tbl;
  final Value<String> entityId;
  final Value<String> kind;
  final Value<String> field;
  final Value<String?> valueJson;
  final Value<int?> delta;
  final Value<String> sig;
  final Value<String> status;
  final Value<int> rowid;
  const OpsCompanion({
    this.opId = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.seq = const Value.absent(),
    this.hlc = const Value.absent(),
    this.authorMemberId = const Value.absent(),
    this.changeId = const Value.absent(),
    this.tbl = const Value.absent(),
    this.entityId = const Value.absent(),
    this.kind = const Value.absent(),
    this.field = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.delta = const Value.absent(),
    this.sig = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OpsCompanion.insert({
    required String opId,
    required String homeId,
    required String deviceId,
    required int seq,
    required String hlc,
    required String authorMemberId,
    required String changeId,
    required String tbl,
    required String entityId,
    required String kind,
    required String field,
    this.valueJson = const Value.absent(),
    this.delta = const Value.absent(),
    this.sig = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       homeId = Value(homeId),
       deviceId = Value(deviceId),
       seq = Value(seq),
       hlc = Value(hlc),
       authorMemberId = Value(authorMemberId),
       changeId = Value(changeId),
       tbl = Value(tbl),
       entityId = Value(entityId),
       kind = Value(kind),
       field = Value(field);
  static Insertable<OpRow> custom({
    Expression<String>? opId,
    Expression<String>? homeId,
    Expression<String>? deviceId,
    Expression<int>? seq,
    Expression<String>? hlc,
    Expression<String>? authorMemberId,
    Expression<String>? changeId,
    Expression<String>? tbl,
    Expression<String>? entityId,
    Expression<String>? kind,
    Expression<String>? field,
    Expression<String>? valueJson,
    Expression<int>? delta,
    Expression<String>? sig,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (homeId != null) 'home_id': homeId,
      if (deviceId != null) 'device_id': deviceId,
      if (seq != null) 'seq': seq,
      if (hlc != null) 'hlc': hlc,
      if (authorMemberId != null) 'author_member_id': authorMemberId,
      if (changeId != null) 'change_id': changeId,
      if (tbl != null) 'tbl': tbl,
      if (entityId != null) 'entity_id': entityId,
      if (kind != null) 'kind': kind,
      if (field != null) 'field': field,
      if (valueJson != null) 'value_json': valueJson,
      if (delta != null) 'delta': delta,
      if (sig != null) 'sig': sig,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OpsCompanion copyWith({
    Value<String>? opId,
    Value<String>? homeId,
    Value<String>? deviceId,
    Value<int>? seq,
    Value<String>? hlc,
    Value<String>? authorMemberId,
    Value<String>? changeId,
    Value<String>? tbl,
    Value<String>? entityId,
    Value<String>? kind,
    Value<String>? field,
    Value<String?>? valueJson,
    Value<int?>? delta,
    Value<String>? sig,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return OpsCompanion(
      opId: opId ?? this.opId,
      homeId: homeId ?? this.homeId,
      deviceId: deviceId ?? this.deviceId,
      seq: seq ?? this.seq,
      hlc: hlc ?? this.hlc,
      authorMemberId: authorMemberId ?? this.authorMemberId,
      changeId: changeId ?? this.changeId,
      tbl: tbl ?? this.tbl,
      entityId: entityId ?? this.entityId,
      kind: kind ?? this.kind,
      field: field ?? this.field,
      valueJson: valueJson ?? this.valueJson,
      delta: delta ?? this.delta,
      sig: sig ?? this.sig,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<String>(homeId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (authorMemberId.present) {
      map['author_member_id'] = Variable<String>(authorMemberId.value);
    }
    if (changeId.present) {
      map['change_id'] = Variable<String>(changeId.value);
    }
    if (tbl.present) {
      map['tbl'] = Variable<String>(tbl.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (sig.present) {
      map['sig'] = Variable<String>(sig.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpsCompanion(')
          ..write('opId: $opId, ')
          ..write('homeId: $homeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('seq: $seq, ')
          ..write('hlc: $hlc, ')
          ..write('authorMemberId: $authorMemberId, ')
          ..write('changeId: $changeId, ')
          ..write('tbl: $tbl, ')
          ..write('entityId: $entityId, ')
          ..write('kind: $kind, ')
          ..write('field: $field, ')
          ..write('valueJson: $valueJson, ')
          ..write('delta: $delta, ')
          ..write('sig: $sig, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldClocksTable extends FieldClocks
    with TableInfo<$FieldClocksTable, FieldClock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldClocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tblMeta = const VerificationMeta('tbl');
  @override
  late final GeneratedColumn<String> tbl = GeneratedColumn<String>(
    'tbl',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tbl, entityId, field, hlc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_clocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldClock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tbl')) {
      context.handle(
        _tblMeta,
        tbl.isAcceptableOrUnknown(data['tbl']!, _tblMeta),
      );
    } else if (isInserting) {
      context.missing(_tblMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tbl, entityId, field};
  @override
  FieldClock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldClock(
      tbl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tbl'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
    );
  }

  @override
  $FieldClocksTable createAlias(String alias) {
    return $FieldClocksTable(attachedDatabase, alias);
  }
}

class FieldClock extends DataClass implements Insertable<FieldClock> {
  final String tbl;
  final String entityId;
  final String field;
  final String hlc;
  const FieldClock({
    required this.tbl,
    required this.entityId,
    required this.field,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tbl'] = Variable<String>(tbl);
    map['entity_id'] = Variable<String>(entityId);
    map['field'] = Variable<String>(field);
    map['hlc'] = Variable<String>(hlc);
    return map;
  }

  FieldClocksCompanion toCompanion(bool nullToAbsent) {
    return FieldClocksCompanion(
      tbl: Value(tbl),
      entityId: Value(entityId),
      field: Value(field),
      hlc: Value(hlc),
    );
  }

  factory FieldClock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldClock(
      tbl: serializer.fromJson<String>(json['tbl']),
      entityId: serializer.fromJson<String>(json['entityId']),
      field: serializer.fromJson<String>(json['field']),
      hlc: serializer.fromJson<String>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tbl': serializer.toJson<String>(tbl),
      'entityId': serializer.toJson<String>(entityId),
      'field': serializer.toJson<String>(field),
      'hlc': serializer.toJson<String>(hlc),
    };
  }

  FieldClock copyWith({
    String? tbl,
    String? entityId,
    String? field,
    String? hlc,
  }) => FieldClock(
    tbl: tbl ?? this.tbl,
    entityId: entityId ?? this.entityId,
    field: field ?? this.field,
    hlc: hlc ?? this.hlc,
  );
  FieldClock copyWithCompanion(FieldClocksCompanion data) {
    return FieldClock(
      tbl: data.tbl.present ? data.tbl.value : this.tbl,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      field: data.field.present ? data.field.value : this.field,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldClock(')
          ..write('tbl: $tbl, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tbl, entityId, field, hlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldClock &&
          other.tbl == this.tbl &&
          other.entityId == this.entityId &&
          other.field == this.field &&
          other.hlc == this.hlc);
}

class FieldClocksCompanion extends UpdateCompanion<FieldClock> {
  final Value<String> tbl;
  final Value<String> entityId;
  final Value<String> field;
  final Value<String> hlc;
  final Value<int> rowid;
  const FieldClocksCompanion({
    this.tbl = const Value.absent(),
    this.entityId = const Value.absent(),
    this.field = const Value.absent(),
    this.hlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldClocksCompanion.insert({
    required String tbl,
    required String entityId,
    required String field,
    required String hlc,
    this.rowid = const Value.absent(),
  }) : tbl = Value(tbl),
       entityId = Value(entityId),
       field = Value(field),
       hlc = Value(hlc);
  static Insertable<FieldClock> custom({
    Expression<String>? tbl,
    Expression<String>? entityId,
    Expression<String>? field,
    Expression<String>? hlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tbl != null) 'tbl': tbl,
      if (entityId != null) 'entity_id': entityId,
      if (field != null) 'field': field,
      if (hlc != null) 'hlc': hlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldClocksCompanion copyWith({
    Value<String>? tbl,
    Value<String>? entityId,
    Value<String>? field,
    Value<String>? hlc,
    Value<int>? rowid,
  }) {
    return FieldClocksCompanion(
      tbl: tbl ?? this.tbl,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      hlc: hlc ?? this.hlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tbl.present) {
      map['tbl'] = Variable<String>(tbl.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldClocksCompanion(')
          ..write('tbl: $tbl, ')
          ..write('entityId: $entityId, ')
          ..write('field: $field, ')
          ..write('hlc: $hlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevNotesTable extends DevNotes with TableInfo<$DevNotesTable, DevNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeIdMeta = const VerificationMeta('homeId');
  @override
  late final GeneratedColumn<String> homeId = GeneratedColumn<String>(
    'home_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tapsMeta = const VerificationMeta('taps');
  @override
  late final GeneratedColumn<int> taps = GeneratedColumn<int>(
    'taps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    homeId,
    deleted,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    title,
    body,
    pinned,
    taps,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dev_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('home_id')) {
      context.handle(
        _homeIdMeta,
        homeId.isAcceptableOrUnknown(data['home_id']!, _homeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_homeIdMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('taps')) {
      context.handle(
        _tapsMeta,
        taps.isAcceptableOrUnknown(data['taps']!, _tapsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      homeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_id'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      taps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taps'],
      )!,
    );
  }

  @override
  $DevNotesTable createAlias(String alias) {
    return $DevNotesTable(attachedDatabase, alias);
  }
}

class DevNote extends DataClass implements Insertable<DevNote> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? title;
  final String? body;
  final bool pinned;
  final int taps;
  const DevNote({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.title,
    this.body,
    required this.pinned,
    required this.taps,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['home_id'] = Variable<String>(homeId);
    map['deleted'] = Variable<bool>(deleted);
    map['created_at'] = Variable<int>(createdAt);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_at'] = Variable<int>(updatedAt);
    map['updated_by'] = Variable<String>(updatedBy);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['taps'] = Variable<int>(taps);
    return map;
  }

  DevNotesCompanion toCompanion(bool nullToAbsent) {
    return DevNotesCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      pinned: Value(pinned),
      taps: Value(taps),
    );
  }

  factory DevNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevNote(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      title: serializer.fromJson<String?>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      taps: serializer.fromJson<int>(json['taps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'homeId': serializer.toJson<String>(homeId),
      'deleted': serializer.toJson<bool>(deleted),
      'createdAt': serializer.toJson<int>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'title': serializer.toJson<String?>(title),
      'body': serializer.toJson<String?>(body),
      'pinned': serializer.toJson<bool>(pinned),
      'taps': serializer.toJson<int>(taps),
    };
  }

  DevNote copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    Value<String?> title = const Value.absent(),
    Value<String?> body = const Value.absent(),
    bool? pinned,
    int? taps,
  }) => DevNote(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    title: title.present ? title.value : this.title,
    body: body.present ? body.value : this.body,
    pinned: pinned ?? this.pinned,
    taps: taps ?? this.taps,
  );
  DevNote copyWithCompanion(DevNotesCompanion data) {
    return DevNote(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      taps: data.taps.present ? data.taps.value : this.taps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevNote(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('pinned: $pinned, ')
          ..write('taps: $taps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    homeId,
    deleted,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    title,
    body,
    pinned,
    taps,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevNote &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.title == this.title &&
          other.body == this.body &&
          other.pinned == this.pinned &&
          other.taps == this.taps);
}

class DevNotesCompanion extends UpdateCompanion<DevNote> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String?> title;
  final Value<String?> body;
  final Value<bool> pinned;
  final Value<int> taps;
  final Value<int> rowid;
  const DevNotesCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.pinned = const Value.absent(),
    this.taps = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevNotesCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.pinned = const Value.absent(),
    this.taps = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<DevNote> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? title,
    Expression<String>? body,
    Expression<bool>? pinned,
    Expression<int>? taps,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (homeId != null) 'home_id': homeId,
      if (deleted != null) 'deleted': deleted,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (pinned != null) 'pinned': pinned,
      if (taps != null) 'taps': taps,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String?>? title,
    Value<String?>? body,
    Value<bool>? pinned,
    Value<int>? taps,
    Value<int>? rowid,
  }) {
    return DevNotesCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      title: title ?? this.title,
      body: body ?? this.body,
      pinned: pinned ?? this.pinned,
      taps: taps ?? this.taps,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<String>(homeId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (taps.present) {
      map['taps'] = Variable<int>(taps.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevNotesCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('pinned: $pinned, ')
          ..write('taps: $taps, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$NestDatabase extends GeneratedDatabase {
  _$NestDatabase(QueryExecutor e) : super(e);
  $NestDatabaseManager get managers => $NestDatabaseManager(this);
  late final $OpsTable ops = $OpsTable(this);
  late final $FieldClocksTable fieldClocks = $FieldClocksTable(this);
  late final $DevNotesTable devNotes = $DevNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ops,
    fieldClocks,
    devNotes,
  ];
}

typedef $$OpsTableCreateCompanionBuilder = OpsCompanion Function({
  required String opId,
  required String homeId,
  required String deviceId,
  required int seq,
  required String hlc,
  required String authorMemberId,
  required String changeId,
  required String tbl,
  required String entityId,
  required String kind,
  required String field,
  Value<String?> valueJson,
  Value<int?> delta,
  Value<String> sig,
  Value<String> status,
  Value<int> rowid,
});
typedef $$OpsTableUpdateCompanionBuilder = OpsCompanion Function({
  Value<String> opId,
  Value<String> homeId,
  Value<String> deviceId,
  Value<int> seq,
  Value<String> hlc,
  Value<String> authorMemberId,
  Value<String> changeId,
  Value<String> tbl,
  Value<String> entityId,
  Value<String> kind,
  Value<String> field,
  Value<String?> valueJson,
  Value<int?> delta,
  Value<String> sig,
  Value<String> status,
  Value<int> rowid,
});

class $$OpsTableFilterComposer extends Composer<_$NestDatabase, $OpsTable> {
  $$OpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorMemberId => $composableBuilder(
    column: $table.authorMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tbl => $composableBuilder(
    column: $table.tbl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OpsTableOrderingComposer extends Composer<_$NestDatabase, $OpsTable> {
  $$OpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorMemberId => $composableBuilder(
    column: $table.authorMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tbl => $composableBuilder(
    column: $table.tbl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sig => $composableBuilder(
    column: $table.sig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpsTableAnnotationComposer extends Composer<_$NestDatabase, $OpsTable> {
  $$OpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get authorMemberId => $composableBuilder(
    column: $table.authorMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get tbl =>
      $composableBuilder(column: $table.tbl, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get sig =>
      $composableBuilder(column: $table.sig, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$OpsTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $OpsTable,
          OpRow,
          $$OpsTableFilterComposer,
          $$OpsTableOrderingComposer,
          $$OpsTableAnnotationComposer,
          $$OpsTableCreateCompanionBuilder,
          $$OpsTableUpdateCompanionBuilder,
          (OpRow, BaseReferences<_$NestDatabase, $OpsTable, OpRow>),
          OpRow,
          PrefetchHooks Function()
        > {
  $$OpsTableTableManager(_$NestDatabase db, $OpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<String> authorMemberId = const Value.absent(),
                Value<String> changeId = const Value.absent(),
                Value<String> tbl = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> valueJson = const Value.absent(),
                Value<int?> delta = const Value.absent(),
                Value<String> sig = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OpsCompanion(
                opId: opId,
                homeId: homeId,
                deviceId: deviceId,
                seq: seq,
                hlc: hlc,
                authorMemberId: authorMemberId,
                changeId: changeId,
                tbl: tbl,
                entityId: entityId,
                kind: kind,
                field: field,
                valueJson: valueJson,
                delta: delta,
                sig: sig,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String homeId,
                required String deviceId,
                required int seq,
                required String hlc,
                required String authorMemberId,
                required String changeId,
                required String tbl,
                required String entityId,
                required String kind,
                required String field,
                Value<String?> valueJson = const Value.absent(),
                Value<int?> delta = const Value.absent(),
                Value<String> sig = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OpsCompanion.insert(
                opId: opId,
                homeId: homeId,
                deviceId: deviceId,
                seq: seq,
                hlc: hlc,
                authorMemberId: authorMemberId,
                changeId: changeId,
                tbl: tbl,
                entityId: entityId,
                kind: kind,
                field: field,
                valueJson: valueJson,
                delta: delta,
                sig: sig,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpsTable, OpRow>(table),
                  BaseReferences<_$NestDatabase, $OpsTable, OpRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OpsTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $OpsTable,
      OpRow,
      $$OpsTableFilterComposer,
      $$OpsTableOrderingComposer,
      $$OpsTableAnnotationComposer,
      $$OpsTableCreateCompanionBuilder,
      $$OpsTableUpdateCompanionBuilder,
      (OpRow, BaseReferences<_$NestDatabase, $OpsTable, OpRow>),
      OpRow,
      PrefetchHooks Function()
    >;
typedef $$FieldClocksTableCreateCompanionBuilder =
    FieldClocksCompanion Function({
      required String tbl,
      required String entityId,
      required String field,
      required String hlc,
      Value<int> rowid,
    });
typedef $$FieldClocksTableUpdateCompanionBuilder =
    FieldClocksCompanion Function({
      Value<String> tbl,
      Value<String> entityId,
      Value<String> field,
      Value<String> hlc,
      Value<int> rowid,
    });

class $$FieldClocksTableFilterComposer
    extends Composer<_$NestDatabase, $FieldClocksTable> {
  $$FieldClocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tbl => $composableBuilder(
    column: $table.tbl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FieldClocksTableOrderingComposer
    extends Composer<_$NestDatabase, $FieldClocksTable> {
  $$FieldClocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tbl => $composableBuilder(
    column: $table.tbl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FieldClocksTableAnnotationComposer
    extends Composer<_$NestDatabase, $FieldClocksTable> {
  $$FieldClocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tbl =>
      $composableBuilder(column: $table.tbl, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);
}

class $$FieldClocksTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $FieldClocksTable,
          FieldClock,
          $$FieldClocksTableFilterComposer,
          $$FieldClocksTableOrderingComposer,
          $$FieldClocksTableAnnotationComposer,
          $$FieldClocksTableCreateCompanionBuilder,
          $$FieldClocksTableUpdateCompanionBuilder,
          (
            FieldClock,
            BaseReferences<_$NestDatabase, $FieldClocksTable, FieldClock>,
          ),
          FieldClock,
          PrefetchHooks Function()
        > {
  $$FieldClocksTableTableManager(_$NestDatabase db, $FieldClocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldClocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldClocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldClocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tbl = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldClocksCompanion(
                tbl: tbl,
                entityId: entityId,
                field: field,
                hlc: hlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tbl,
                required String entityId,
                required String field,
                required String hlc,
                Value<int> rowid = const Value.absent(),
              }) => FieldClocksCompanion.insert(
                tbl: tbl,
                entityId: entityId,
                field: field,
                hlc: hlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FieldClocksTable, FieldClock>(table),
                  BaseReferences<_$NestDatabase, $FieldClocksTable, FieldClock>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FieldClocksTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $FieldClocksTable,
      FieldClock,
      $$FieldClocksTableFilterComposer,
      $$FieldClocksTableOrderingComposer,
      $$FieldClocksTableAnnotationComposer,
      $$FieldClocksTableCreateCompanionBuilder,
      $$FieldClocksTableUpdateCompanionBuilder,
      (
        FieldClock,
        BaseReferences<_$NestDatabase, $FieldClocksTable, FieldClock>,
      ),
      FieldClock,
      PrefetchHooks Function()
    >;
typedef $$DevNotesTableCreateCompanionBuilder = DevNotesCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> title,
  Value<String?> body,
  Value<bool> pinned,
  Value<int> taps,
  Value<int> rowid,
});
typedef $$DevNotesTableUpdateCompanionBuilder = DevNotesCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> title,
  Value<String?> body,
  Value<bool> pinned,
  Value<int> taps,
  Value<int> rowid,
});

class $$DevNotesTableFilterComposer
    extends Composer<_$NestDatabase, $DevNotesTable> {
  $$DevNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taps => $composableBuilder(
    column: $table.taps,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevNotesTableOrderingComposer
    extends Composer<_$NestDatabase, $DevNotesTable> {
  $$DevNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taps => $composableBuilder(
    column: $table.taps,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevNotesTableAnnotationComposer
    extends Composer<_$NestDatabase, $DevNotesTable> {
  $$DevNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get taps =>
      $composableBuilder(column: $table.taps, builder: (column) => column);
}

class $$DevNotesTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $DevNotesTable,
          DevNote,
          $$DevNotesTableFilterComposer,
          $$DevNotesTableOrderingComposer,
          $$DevNotesTableAnnotationComposer,
          $$DevNotesTableCreateCompanionBuilder,
          $$DevNotesTableUpdateCompanionBuilder,
          (DevNote, BaseReferences<_$NestDatabase, $DevNotesTable, DevNote>),
          DevNote,
          PrefetchHooks Function()
        > {
  $$DevNotesTableTableManager(_$NestDatabase db, $DevNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> taps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevNotesCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                title: title,
                body: body,
                pinned: pinned,
                taps: taps,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String homeId,
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> taps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevNotesCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                title: title,
                body: body,
                pinned: pinned,
                taps: taps,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevNotesTable, DevNote>(table),
                  BaseReferences<_$NestDatabase, $DevNotesTable, DevNote>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $DevNotesTable,
      DevNote,
      $$DevNotesTableFilterComposer,
      $$DevNotesTableOrderingComposer,
      $$DevNotesTableAnnotationComposer,
      $$DevNotesTableCreateCompanionBuilder,
      $$DevNotesTableUpdateCompanionBuilder,
      (DevNote, BaseReferences<_$NestDatabase, $DevNotesTable, DevNote>),
      DevNote,
      PrefetchHooks Function()
    >;

class $NestDatabaseManager {
  final _$NestDatabase _db;
  $NestDatabaseManager(this._db);
  $$OpsTableTableManager get ops => $$OpsTableTableManager(_db, _db.ops);
  $$FieldClocksTableTableManager get fieldClocks =>
      $$FieldClocksTableTableManager(_db, _db.fieldClocks);
  $$DevNotesTableTableManager get devNotes =>
      $$DevNotesTableTableManager(_db, _db.devNotes);
}
