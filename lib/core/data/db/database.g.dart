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

class $HomesTable extends Homes with TableInfo<$HomesTable, Home> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetMonthlyPaiseMeta =
      const VerificationMeta('budgetMonthlyPaise');
  @override
  late final GeneratedColumn<int> budgetMonthlyPaise = GeneratedColumn<int>(
    'budget_monthly_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  @override
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genesisJsonMeta = const VerificationMeta(
    'genesisJson',
  );
  @override
  late final GeneratedColumn<String> genesisJson = GeneratedColumn<String>(
    'genesis_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeKeyIdMeta = const VerificationMeta(
    'homeKeyId',
  );
  @override
  late final GeneratedColumn<String> homeKeyId = GeneratedColumn<String>(
    'home_key_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    name,
    budgetMonthlyPaise,
    vaultId,
    genesisJson,
    homeKeyId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'homes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Home> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('budget_monthly_paise')) {
      context.handle(
        _budgetMonthlyPaiseMeta,
        budgetMonthlyPaise.isAcceptableOrUnknown(
          data['budget_monthly_paise']!,
          _budgetMonthlyPaiseMeta,
        ),
      );
    }
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    }
    if (data.containsKey('genesis_json')) {
      context.handle(
        _genesisJsonMeta,
        genesisJson.isAcceptableOrUnknown(
          data['genesis_json']!,
          _genesisJsonMeta,
        ),
      );
    }
    if (data.containsKey('home_key_id')) {
      context.handle(
        _homeKeyIdMeta,
        homeKeyId.isAcceptableOrUnknown(data['home_key_id']!, _homeKeyIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Home map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Home(
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
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      budgetMonthlyPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_monthly_paise'],
      ),
      vaultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_id'],
      ),
      genesisJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genesis_json'],
      ),
      homeKeyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_key_id'],
      ),
    );
  }

  @override
  $HomesTable createAlias(String alias) {
    return $HomesTable(attachedDatabase, alias);
  }
}

class Home extends DataClass implements Insertable<Home> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? name;
  final int? budgetMonthlyPaise;
  final String? vaultId;
  final String? genesisJson;
  final String? homeKeyId;
  const Home({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.name,
    this.budgetMonthlyPaise,
    this.vaultId,
    this.genesisJson,
    this.homeKeyId,
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
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || budgetMonthlyPaise != null) {
      map['budget_monthly_paise'] = Variable<int>(budgetMonthlyPaise);
    }
    if (!nullToAbsent || vaultId != null) {
      map['vault_id'] = Variable<String>(vaultId);
    }
    if (!nullToAbsent || genesisJson != null) {
      map['genesis_json'] = Variable<String>(genesisJson);
    }
    if (!nullToAbsent || homeKeyId != null) {
      map['home_key_id'] = Variable<String>(homeKeyId);
    }
    return map;
  }

  HomesCompanion toCompanion(bool nullToAbsent) {
    return HomesCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      budgetMonthlyPaise: budgetMonthlyPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetMonthlyPaise),
      vaultId: vaultId == null && nullToAbsent
          ? const Value.absent()
          : Value(vaultId),
      genesisJson: genesisJson == null && nullToAbsent
          ? const Value.absent()
          : Value(genesisJson),
      homeKeyId: homeKeyId == null && nullToAbsent
          ? const Value.absent()
          : Value(homeKeyId),
    );
  }

  factory Home.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Home(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      name: serializer.fromJson<String?>(json['name']),
      budgetMonthlyPaise: serializer.fromJson<int?>(json['budgetMonthlyPaise']),
      vaultId: serializer.fromJson<String?>(json['vaultId']),
      genesisJson: serializer.fromJson<String?>(json['genesisJson']),
      homeKeyId: serializer.fromJson<String?>(json['homeKeyId']),
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
      'name': serializer.toJson<String?>(name),
      'budgetMonthlyPaise': serializer.toJson<int?>(budgetMonthlyPaise),
      'vaultId': serializer.toJson<String?>(vaultId),
      'genesisJson': serializer.toJson<String?>(genesisJson),
      'homeKeyId': serializer.toJson<String?>(homeKeyId),
    };
  }

  Home copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    Value<String?> name = const Value.absent(),
    Value<int?> budgetMonthlyPaise = const Value.absent(),
    Value<String?> vaultId = const Value.absent(),
    Value<String?> genesisJson = const Value.absent(),
    Value<String?> homeKeyId = const Value.absent(),
  }) => Home(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    name: name.present ? name.value : this.name,
    budgetMonthlyPaise: budgetMonthlyPaise.present
        ? budgetMonthlyPaise.value
        : this.budgetMonthlyPaise,
    vaultId: vaultId.present ? vaultId.value : this.vaultId,
    genesisJson: genesisJson.present ? genesisJson.value : this.genesisJson,
    homeKeyId: homeKeyId.present ? homeKeyId.value : this.homeKeyId,
  );
  Home copyWithCompanion(HomesCompanion data) {
    return Home(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      name: data.name.present ? data.name.value : this.name,
      budgetMonthlyPaise: data.budgetMonthlyPaise.present
          ? data.budgetMonthlyPaise.value
          : this.budgetMonthlyPaise,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      genesisJson: data.genesisJson.present
          ? data.genesisJson.value
          : this.genesisJson,
      homeKeyId: data.homeKeyId.present ? data.homeKeyId.value : this.homeKeyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Home(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('budgetMonthlyPaise: $budgetMonthlyPaise, ')
          ..write('vaultId: $vaultId, ')
          ..write('genesisJson: $genesisJson, ')
          ..write('homeKeyId: $homeKeyId')
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
    name,
    budgetMonthlyPaise,
    vaultId,
    genesisJson,
    homeKeyId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Home &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.name == this.name &&
          other.budgetMonthlyPaise == this.budgetMonthlyPaise &&
          other.vaultId == this.vaultId &&
          other.genesisJson == this.genesisJson &&
          other.homeKeyId == this.homeKeyId);
}

class HomesCompanion extends UpdateCompanion<Home> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String?> name;
  final Value<int?> budgetMonthlyPaise;
  final Value<String?> vaultId;
  final Value<String?> genesisJson;
  final Value<String?> homeKeyId;
  final Value<int> rowid;
  const HomesCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.budgetMonthlyPaise = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.genesisJson = const Value.absent(),
    this.homeKeyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HomesCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.budgetMonthlyPaise = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.genesisJson = const Value.absent(),
    this.homeKeyId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<Home> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? name,
    Expression<int>? budgetMonthlyPaise,
    Expression<String>? vaultId,
    Expression<String>? genesisJson,
    Expression<String>? homeKeyId,
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
      if (name != null) 'name': name,
      if (budgetMonthlyPaise != null)
        'budget_monthly_paise': budgetMonthlyPaise,
      if (vaultId != null) 'vault_id': vaultId,
      if (genesisJson != null) 'genesis_json': genesisJson,
      if (homeKeyId != null) 'home_key_id': homeKeyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HomesCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String?>? name,
    Value<int?>? budgetMonthlyPaise,
    Value<String?>? vaultId,
    Value<String?>? genesisJson,
    Value<String?>? homeKeyId,
    Value<int>? rowid,
  }) {
    return HomesCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      name: name ?? this.name,
      budgetMonthlyPaise: budgetMonthlyPaise ?? this.budgetMonthlyPaise,
      vaultId: vaultId ?? this.vaultId,
      genesisJson: genesisJson ?? this.genesisJson,
      homeKeyId: homeKeyId ?? this.homeKeyId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (budgetMonthlyPaise.present) {
      map['budget_monthly_paise'] = Variable<int>(budgetMonthlyPaise.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (genesisJson.present) {
      map['genesis_json'] = Variable<String>(genesisJson.value);
    }
    if (homeKeyId.present) {
      map['home_key_id'] = Variable<String>(homeKeyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomesCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('budgetMonthlyPaise: $budgetMonthlyPaise, ')
          ..write('vaultId: $vaultId, ')
          ..write('genesisJson: $genesisJson, ')
          ..write('homeKeyId: $homeKeyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceModelMeta = const VerificationMeta(
    'deviceModel',
  );
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
    'device_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedViaMeta = const VerificationMeta(
    'joinedVia',
  );
  @override
  late final GeneratedColumn<String> joinedVia = GeneratedColumn<String>(
    'joined_via',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invitedByMeta = const VerificationMeta(
    'invitedBy',
  );
  @override
  late final GeneratedColumn<String> invitedBy = GeneratedColumn<String>(
    'invited_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    fullName,
    firstName,
    role,
    status,
    color,
    deviceModel,
    joinedAt,
    joinedVia,
    invitedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<Member> instance, {
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
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('device_model')) {
      context.handle(
        _deviceModelMeta,
        deviceModel.isAcceptableOrUnknown(
          data['device_model']!,
          _deviceModelMeta,
        ),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('joined_via')) {
      context.handle(
        _joinedViaMeta,
        joinedVia.isAcceptableOrUnknown(data['joined_via']!, _joinedViaMeta),
      );
    }
    if (data.containsKey('invited_by')) {
      context.handle(
        _invitedByMeta,
        invitedBy.isAcceptableOrUnknown(data['invited_by']!, _invitedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
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
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      deviceModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_model'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}joined_at'],
      ),
      joinedVia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}joined_via'],
      ),
      invitedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invited_by'],
      ),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? fullName;
  final String? firstName;
  final String role;
  final String status;
  final String? color;
  final String? deviceModel;
  final int? joinedAt;
  final String? joinedVia;
  final String? invitedBy;
  const Member({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.fullName,
    this.firstName,
    required this.role,
    required this.status,
    this.color,
    this.deviceModel,
    this.joinedAt,
    this.joinedVia,
    this.invitedBy,
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
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    map['role'] = Variable<String>(role);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<int>(joinedAt);
    }
    if (!nullToAbsent || joinedVia != null) {
      map['joined_via'] = Variable<String>(joinedVia);
    }
    if (!nullToAbsent || invitedBy != null) {
      map['invited_by'] = Variable<String>(invitedBy);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      role: Value(role),
      status: Value(status),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      deviceModel: deviceModel == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModel),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
      joinedVia: joinedVia == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedVia),
      invitedBy: invitedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(invitedBy),
    );
  }

  factory Member.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      role: serializer.fromJson<String>(json['role']),
      status: serializer.fromJson<String>(json['status']),
      color: serializer.fromJson<String?>(json['color']),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
      joinedAt: serializer.fromJson<int?>(json['joinedAt']),
      joinedVia: serializer.fromJson<String?>(json['joinedVia']),
      invitedBy: serializer.fromJson<String?>(json['invitedBy']),
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
      'fullName': serializer.toJson<String?>(fullName),
      'firstName': serializer.toJson<String?>(firstName),
      'role': serializer.toJson<String>(role),
      'status': serializer.toJson<String>(status),
      'color': serializer.toJson<String?>(color),
      'deviceModel': serializer.toJson<String?>(deviceModel),
      'joinedAt': serializer.toJson<int?>(joinedAt),
      'joinedVia': serializer.toJson<String?>(joinedVia),
      'invitedBy': serializer.toJson<String?>(invitedBy),
    };
  }

  Member copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    Value<String?> fullName = const Value.absent(),
    Value<String?> firstName = const Value.absent(),
    String? role,
    String? status,
    Value<String?> color = const Value.absent(),
    Value<String?> deviceModel = const Value.absent(),
    Value<int?> joinedAt = const Value.absent(),
    Value<String?> joinedVia = const Value.absent(),
    Value<String?> invitedBy = const Value.absent(),
  }) => Member(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    fullName: fullName.present ? fullName.value : this.fullName,
    firstName: firstName.present ? firstName.value : this.firstName,
    role: role ?? this.role,
    status: status ?? this.status,
    color: color.present ? color.value : this.color,
    deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    joinedVia: joinedVia.present ? joinedVia.value : this.joinedVia,
    invitedBy: invitedBy.present ? invitedBy.value : this.invitedBy,
  );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      color: data.color.present ? data.color.value : this.color,
      deviceModel: data.deviceModel.present
          ? data.deviceModel.value
          : this.deviceModel,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      joinedVia: data.joinedVia.present ? data.joinedVia.value : this.joinedVia,
      invitedBy: data.invitedBy.present ? data.invitedBy.value : this.invitedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('fullName: $fullName, ')
          ..write('firstName: $firstName, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('joinedVia: $joinedVia, ')
          ..write('invitedBy: $invitedBy')
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
    fullName,
    firstName,
    role,
    status,
    color,
    deviceModel,
    joinedAt,
    joinedVia,
    invitedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.fullName == this.fullName &&
          other.firstName == this.firstName &&
          other.role == this.role &&
          other.status == this.status &&
          other.color == this.color &&
          other.deviceModel == this.deviceModel &&
          other.joinedAt == this.joinedAt &&
          other.joinedVia == this.joinedVia &&
          other.invitedBy == this.invitedBy);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String?> fullName;
  final Value<String?> firstName;
  final Value<String> role;
  final Value<String> status;
  final Value<String?> color;
  final Value<String?> deviceModel;
  final Value<int?> joinedAt;
  final Value<String?> joinedVia;
  final Value<String?> invitedBy;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.fullName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.color = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.joinedVia = const Value.absent(),
    this.invitedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.fullName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.color = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.joinedVia = const Value.absent(),
    this.invitedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<Member> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? fullName,
    Expression<String>? firstName,
    Expression<String>? role,
    Expression<String>? status,
    Expression<String>? color,
    Expression<String>? deviceModel,
    Expression<int>? joinedAt,
    Expression<String>? joinedVia,
    Expression<String>? invitedBy,
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
      if (fullName != null) 'full_name': fullName,
      if (firstName != null) 'first_name': firstName,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (color != null) 'color': color,
      if (deviceModel != null) 'device_model': deviceModel,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (joinedVia != null) 'joined_via': joinedVia,
      if (invitedBy != null) 'invited_by': invitedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String?>? fullName,
    Value<String?>? firstName,
    Value<String>? role,
    Value<String>? status,
    Value<String?>? color,
    Value<String?>? deviceModel,
    Value<int?>? joinedAt,
    Value<String?>? joinedVia,
    Value<String?>? invitedBy,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      role: role ?? this.role,
      status: status ?? this.status,
      color: color ?? this.color,
      deviceModel: deviceModel ?? this.deviceModel,
      joinedAt: joinedAt ?? this.joinedAt,
      joinedVia: joinedVia ?? this.joinedVia,
      invitedBy: invitedBy ?? this.invitedBy,
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
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (joinedVia.present) {
      map['joined_via'] = Variable<String>(joinedVia.value);
    }
    if (invitedBy.present) {
      map['invited_by'] = Variable<String>(invitedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('fullName: $fullName, ')
          ..write('firstName: $firstName, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('joinedVia: $joinedVia, ')
          ..write('invitedBy: $invitedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffTable extends Staff with TableInfo<$StaffTable, StaffData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneE164Meta = const VerificationMeta(
    'phoneE164',
  );
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
    'phone_e164',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
    'upi_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workDaysMeta = const VerificationMeta(
    'workDays',
  );
  @override
  late final GeneratedColumn<String> workDays = GeneratedColumn<String>(
    'work_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6'),
  );
  static const VerificationMeta _expectedTimesMeta = const VerificationMeta(
    'expectedTimes',
  );
  @override
  late final GeneratedColumn<String> expectedTimes = GeneratedColumn<String>(
    'expected_times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('09:00'),
  );
  static const VerificationMeta _usualEndTimeMeta = const VerificationMeta(
    'usualEndTime',
  );
  @override
  late final GeneratedColumn<String> usualEndTime = GeneratedColumn<String>(
    'usual_end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _initialPayTypeMeta = const VerificationMeta(
    'initialPayType',
  );
  @override
  late final GeneratedColumn<String> initialPayType = GeneratedColumn<String>(
    'initial_pay_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialPayPaiseMeta = const VerificationMeta(
    'initialPayPaise',
  );
  @override
  late final GeneratedColumn<int> initialPayPaise = GeneratedColumn<int>(
    'initial_pay_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    name,
    role,
    phoneE164,
    upiId,
    color,
    workDays,
    expectedTimes,
    usualEndTime,
    startDate,
    endDate,
    active,
    initialPayType,
    initialPayPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffData> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('phone_e164')) {
      context.handle(
        _phoneE164Meta,
        phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta),
      );
    }
    if (data.containsKey('upi_id')) {
      context.handle(
        _upiIdMeta,
        upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('work_days')) {
      context.handle(
        _workDaysMeta,
        workDays.isAcceptableOrUnknown(data['work_days']!, _workDaysMeta),
      );
    }
    if (data.containsKey('expected_times')) {
      context.handle(
        _expectedTimesMeta,
        expectedTimes.isAcceptableOrUnknown(
          data['expected_times']!,
          _expectedTimesMeta,
        ),
      );
    }
    if (data.containsKey('usual_end_time')) {
      context.handle(
        _usualEndTimeMeta,
        usualEndTime.isAcceptableOrUnknown(
          data['usual_end_time']!,
          _usualEndTimeMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('initial_pay_type')) {
      context.handle(
        _initialPayTypeMeta,
        initialPayType.isAcceptableOrUnknown(
          data['initial_pay_type']!,
          _initialPayTypeMeta,
        ),
      );
    }
    if (data.containsKey('initial_pay_paise')) {
      context.handle(
        _initialPayPaiseMeta,
        initialPayPaise.isAcceptableOrUnknown(
          data['initial_pay_paise']!,
          _initialPayPaiseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffData(
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
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      phoneE164: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_e164'],
      ),
      upiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      workDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_days'],
      )!,
      expectedTimes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_times'],
      )!,
      usualEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usual_end_time'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      initialPayType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initial_pay_type'],
      ),
      initialPayPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_pay_paise'],
      ),
    );
  }

  @override
  $StaffTable createAlias(String alias) {
    return $StaffTable(attachedDatabase, alias);
  }
}

class StaffData extends DataClass implements Insertable<StaffData> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? name;
  final String? role;
  final String? phoneE164;
  final String? upiId;
  final String? color;
  final String workDays;
  final String expectedTimes;
  final String? usualEndTime;
  final String? startDate;
  final String? endDate;
  final bool active;
  final String? initialPayType;
  final int? initialPayPaise;
  const StaffData({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.name,
    this.role,
    this.phoneE164,
    this.upiId,
    this.color,
    required this.workDays,
    required this.expectedTimes,
    this.usualEndTime,
    this.startDate,
    this.endDate,
    required this.active,
    this.initialPayType,
    this.initialPayPaise,
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
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || phoneE164 != null) {
      map['phone_e164'] = Variable<String>(phoneE164);
    }
    if (!nullToAbsent || upiId != null) {
      map['upi_id'] = Variable<String>(upiId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['work_days'] = Variable<String>(workDays);
    map['expected_times'] = Variable<String>(expectedTimes);
    if (!nullToAbsent || usualEndTime != null) {
      map['usual_end_time'] = Variable<String>(usualEndTime);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || initialPayType != null) {
      map['initial_pay_type'] = Variable<String>(initialPayType);
    }
    if (!nullToAbsent || initialPayPaise != null) {
      map['initial_pay_paise'] = Variable<int>(initialPayPaise);
    }
    return map;
  }

  StaffCompanion toCompanion(bool nullToAbsent) {
    return StaffCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      phoneE164: phoneE164 == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneE164),
      upiId: upiId == null && nullToAbsent
          ? const Value.absent()
          : Value(upiId),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      workDays: Value(workDays),
      expectedTimes: Value(expectedTimes),
      usualEndTime: usualEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(usualEndTime),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      active: Value(active),
      initialPayType: initialPayType == null && nullToAbsent
          ? const Value.absent()
          : Value(initialPayType),
      initialPayPaise: initialPayPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(initialPayPaise),
    );
  }

  factory StaffData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffData(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      name: serializer.fromJson<String?>(json['name']),
      role: serializer.fromJson<String?>(json['role']),
      phoneE164: serializer.fromJson<String?>(json['phoneE164']),
      upiId: serializer.fromJson<String?>(json['upiId']),
      color: serializer.fromJson<String?>(json['color']),
      workDays: serializer.fromJson<String>(json['workDays']),
      expectedTimes: serializer.fromJson<String>(json['expectedTimes']),
      usualEndTime: serializer.fromJson<String?>(json['usualEndTime']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      active: serializer.fromJson<bool>(json['active']),
      initialPayType: serializer.fromJson<String?>(json['initialPayType']),
      initialPayPaise: serializer.fromJson<int?>(json['initialPayPaise']),
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
      'name': serializer.toJson<String?>(name),
      'role': serializer.toJson<String?>(role),
      'phoneE164': serializer.toJson<String?>(phoneE164),
      'upiId': serializer.toJson<String?>(upiId),
      'color': serializer.toJson<String?>(color),
      'workDays': serializer.toJson<String>(workDays),
      'expectedTimes': serializer.toJson<String>(expectedTimes),
      'usualEndTime': serializer.toJson<String?>(usualEndTime),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'active': serializer.toJson<bool>(active),
      'initialPayType': serializer.toJson<String?>(initialPayType),
      'initialPayPaise': serializer.toJson<int?>(initialPayPaise),
    };
  }

  StaffData copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    Value<String?> name = const Value.absent(),
    Value<String?> role = const Value.absent(),
    Value<String?> phoneE164 = const Value.absent(),
    Value<String?> upiId = const Value.absent(),
    Value<String?> color = const Value.absent(),
    String? workDays,
    String? expectedTimes,
    Value<String?> usualEndTime = const Value.absent(),
    Value<String?> startDate = const Value.absent(),
    Value<String?> endDate = const Value.absent(),
    bool? active,
    Value<String?> initialPayType = const Value.absent(),
    Value<int?> initialPayPaise = const Value.absent(),
  }) => StaffData(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    name: name.present ? name.value : this.name,
    role: role.present ? role.value : this.role,
    phoneE164: phoneE164.present ? phoneE164.value : this.phoneE164,
    upiId: upiId.present ? upiId.value : this.upiId,
    color: color.present ? color.value : this.color,
    workDays: workDays ?? this.workDays,
    expectedTimes: expectedTimes ?? this.expectedTimes,
    usualEndTime: usualEndTime.present ? usualEndTime.value : this.usualEndTime,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    active: active ?? this.active,
    initialPayType: initialPayType.present
        ? initialPayType.value
        : this.initialPayType,
    initialPayPaise: initialPayPaise.present
        ? initialPayPaise.value
        : this.initialPayPaise,
  );
  StaffData copyWithCompanion(StaffCompanion data) {
    return StaffData(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      color: data.color.present ? data.color.value : this.color,
      workDays: data.workDays.present ? data.workDays.value : this.workDays,
      expectedTimes: data.expectedTimes.present
          ? data.expectedTimes.value
          : this.expectedTimes,
      usualEndTime: data.usualEndTime.present
          ? data.usualEndTime.value
          : this.usualEndTime,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      active: data.active.present ? data.active.value : this.active,
      initialPayType: data.initialPayType.present
          ? data.initialPayType.value
          : this.initialPayType,
      initialPayPaise: data.initialPayPaise.present
          ? data.initialPayPaise.value
          : this.initialPayPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffData(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('upiId: $upiId, ')
          ..write('color: $color, ')
          ..write('workDays: $workDays, ')
          ..write('expectedTimes: $expectedTimes, ')
          ..write('usualEndTime: $usualEndTime, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active, ')
          ..write('initialPayType: $initialPayType, ')
          ..write('initialPayPaise: $initialPayPaise')
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
    name,
    role,
    phoneE164,
    upiId,
    color,
    workDays,
    expectedTimes,
    usualEndTime,
    startDate,
    endDate,
    active,
    initialPayType,
    initialPayPaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffData &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.name == this.name &&
          other.role == this.role &&
          other.phoneE164 == this.phoneE164 &&
          other.upiId == this.upiId &&
          other.color == this.color &&
          other.workDays == this.workDays &&
          other.expectedTimes == this.expectedTimes &&
          other.usualEndTime == this.usualEndTime &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.active == this.active &&
          other.initialPayType == this.initialPayType &&
          other.initialPayPaise == this.initialPayPaise);
}

class StaffCompanion extends UpdateCompanion<StaffData> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String?> name;
  final Value<String?> role;
  final Value<String?> phoneE164;
  final Value<String?> upiId;
  final Value<String?> color;
  final Value<String> workDays;
  final Value<String> expectedTimes;
  final Value<String?> usualEndTime;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<bool> active;
  final Value<String?> initialPayType;
  final Value<int?> initialPayPaise;
  final Value<int> rowid;
  const StaffCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.upiId = const Value.absent(),
    this.color = const Value.absent(),
    this.workDays = const Value.absent(),
    this.expectedTimes = const Value.absent(),
    this.usualEndTime = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
    this.initialPayType = const Value.absent(),
    this.initialPayPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.upiId = const Value.absent(),
    this.color = const Value.absent(),
    this.workDays = const Value.absent(),
    this.expectedTimes = const Value.absent(),
    this.usualEndTime = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.active = const Value.absent(),
    this.initialPayType = const Value.absent(),
    this.initialPayPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<StaffData> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? phoneE164,
    Expression<String>? upiId,
    Expression<String>? color,
    Expression<String>? workDays,
    Expression<String>? expectedTimes,
    Expression<String>? usualEndTime,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<bool>? active,
    Expression<String>? initialPayType,
    Expression<int>? initialPayPaise,
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
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (upiId != null) 'upi_id': upiId,
      if (color != null) 'color': color,
      if (workDays != null) 'work_days': workDays,
      if (expectedTimes != null) 'expected_times': expectedTimes,
      if (usualEndTime != null) 'usual_end_time': usualEndTime,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (active != null) 'active': active,
      if (initialPayType != null) 'initial_pay_type': initialPayType,
      if (initialPayPaise != null) 'initial_pay_paise': initialPayPaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String?>? name,
    Value<String?>? role,
    Value<String?>? phoneE164,
    Value<String?>? upiId,
    Value<String?>? color,
    Value<String>? workDays,
    Value<String>? expectedTimes,
    Value<String?>? usualEndTime,
    Value<String?>? startDate,
    Value<String?>? endDate,
    Value<bool>? active,
    Value<String?>? initialPayType,
    Value<int?>? initialPayPaise,
    Value<int>? rowid,
  }) {
    return StaffCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneE164: phoneE164 ?? this.phoneE164,
      upiId: upiId ?? this.upiId,
      color: color ?? this.color,
      workDays: workDays ?? this.workDays,
      expectedTimes: expectedTimes ?? this.expectedTimes,
      usualEndTime: usualEndTime ?? this.usualEndTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      initialPayType: initialPayType ?? this.initialPayType,
      initialPayPaise: initialPayPaise ?? this.initialPayPaise,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (workDays.present) {
      map['work_days'] = Variable<String>(workDays.value);
    }
    if (expectedTimes.present) {
      map['expected_times'] = Variable<String>(expectedTimes.value);
    }
    if (usualEndTime.present) {
      map['usual_end_time'] = Variable<String>(usualEndTime.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (initialPayType.present) {
      map['initial_pay_type'] = Variable<String>(initialPayType.value);
    }
    if (initialPayPaise.present) {
      map['initial_pay_paise'] = Variable<int>(initialPayPaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('upiId: $upiId, ')
          ..write('color: $color, ')
          ..write('workDays: $workDays, ')
          ..write('expectedTimes: $expectedTimes, ')
          ..write('usualEndTime: $usualEndTime, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('active: $active, ')
          ..write('initialPayType: $initialPayType, ')
          ..write('initialPayPaise: $initialPayPaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inAtMeta = const VerificationMeta('inAt');
  @override
  late final GeneratedColumn<int> inAt = GeneratedColumn<int>(
    'in_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outAtMeta = const VerificationMeta('outAt');
  @override
  late final GeneratedColumn<int> outAt = GeneratedColumn<int>(
    'out_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inByMeta = const VerificationMeta('inBy');
  @override
  late final GeneratedColumn<String> inBy = GeneratedColumn<String>(
    'in_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outByMeta = const VerificationMeta('outBy');
  @override
  late final GeneratedColumn<String> outBy = GeneratedColumn<String>(
    'out_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    staffId,
    date,
    inAt,
    outAt,
    inBy,
    outBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Visit> instance, {
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('in_at')) {
      context.handle(
        _inAtMeta,
        inAt.isAcceptableOrUnknown(data['in_at']!, _inAtMeta),
      );
    }
    if (data.containsKey('out_at')) {
      context.handle(
        _outAtMeta,
        outAt.isAcceptableOrUnknown(data['out_at']!, _outAtMeta),
      );
    }
    if (data.containsKey('in_by')) {
      context.handle(
        _inByMeta,
        inBy.isAcceptableOrUnknown(data['in_by']!, _inByMeta),
      );
    }
    if (data.containsKey('out_by')) {
      context.handle(
        _outByMeta,
        outBy.isAcceptableOrUnknown(data['out_by']!, _outByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
      inAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}in_at'],
      ),
      outAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}out_at'],
      ),
      inBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}in_by'],
      ),
      outBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}out_by'],
      ),
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class Visit extends DataClass implements Insertable<Visit> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? staffId;
  final String? date;
  final int? inAt;
  final int? outAt;
  final String? inBy;
  final String? outBy;
  const Visit({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.staffId,
    this.date,
    this.inAt,
    this.outAt,
    this.inBy,
    this.outBy,
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
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    if (!nullToAbsent || inAt != null) {
      map['in_at'] = Variable<int>(inAt);
    }
    if (!nullToAbsent || outAt != null) {
      map['out_at'] = Variable<int>(outAt);
    }
    if (!nullToAbsent || inBy != null) {
      map['in_by'] = Variable<String>(inBy);
    }
    if (!nullToAbsent || outBy != null) {
      map['out_by'] = Variable<String>(outBy);
    }
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      inAt: inAt == null && nullToAbsent ? const Value.absent() : Value(inAt),
      outAt: outAt == null && nullToAbsent
          ? const Value.absent()
          : Value(outAt),
      inBy: inBy == null && nullToAbsent ? const Value.absent() : Value(inBy),
      outBy: outBy == null && nullToAbsent
          ? const Value.absent()
          : Value(outBy),
    );
  }

  factory Visit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      staffId: serializer.fromJson<String?>(json['staffId']),
      date: serializer.fromJson<String?>(json['date']),
      inAt: serializer.fromJson<int?>(json['inAt']),
      outAt: serializer.fromJson<int?>(json['outAt']),
      inBy: serializer.fromJson<String?>(json['inBy']),
      outBy: serializer.fromJson<String?>(json['outBy']),
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
      'staffId': serializer.toJson<String?>(staffId),
      'date': serializer.toJson<String?>(date),
      'inAt': serializer.toJson<int?>(inAt),
      'outAt': serializer.toJson<int?>(outAt),
      'inBy': serializer.toJson<String?>(inBy),
      'outBy': serializer.toJson<String?>(outBy),
    };
  }

  Visit copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    Value<String?> staffId = const Value.absent(),
    Value<String?> date = const Value.absent(),
    Value<int?> inAt = const Value.absent(),
    Value<int?> outAt = const Value.absent(),
    Value<String?> inBy = const Value.absent(),
    Value<String?> outBy = const Value.absent(),
  }) => Visit(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    staffId: staffId.present ? staffId.value : this.staffId,
    date: date.present ? date.value : this.date,
    inAt: inAt.present ? inAt.value : this.inAt,
    outAt: outAt.present ? outAt.value : this.outAt,
    inBy: inBy.present ? inBy.value : this.inBy,
    outBy: outBy.present ? outBy.value : this.outBy,
  );
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      date: data.date.present ? data.date.value : this.date,
      inAt: data.inAt.present ? data.inAt.value : this.inAt,
      outAt: data.outAt.present ? data.outAt.value : this.outAt,
      inBy: data.inBy.present ? data.inBy.value : this.inBy,
      outBy: data.outBy.present ? data.outBy.value : this.outBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('date: $date, ')
          ..write('inAt: $inAt, ')
          ..write('outAt: $outAt, ')
          ..write('inBy: $inBy, ')
          ..write('outBy: $outBy')
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
    staffId,
    date,
    inAt,
    outAt,
    inBy,
    outBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Visit &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.staffId == this.staffId &&
          other.date == this.date &&
          other.inAt == this.inAt &&
          other.outAt == this.outAt &&
          other.inBy == this.inBy &&
          other.outBy == this.outBy);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String?> staffId;
  final Value<String?> date;
  final Value<int?> inAt;
  final Value<int?> outAt;
  final Value<String?> inBy;
  final Value<String?> outBy;
  final Value<int> rowid;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.date = const Value.absent(),
    this.inAt = const Value.absent(),
    this.outAt = const Value.absent(),
    this.inBy = const Value.absent(),
    this.outBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.date = const Value.absent(),
    this.inAt = const Value.absent(),
    this.outAt = const Value.absent(),
    this.inBy = const Value.absent(),
    this.outBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<Visit> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? staffId,
    Expression<String>? date,
    Expression<int>? inAt,
    Expression<int>? outAt,
    Expression<String>? inBy,
    Expression<String>? outBy,
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
      if (staffId != null) 'staff_id': staffId,
      if (date != null) 'date': date,
      if (inAt != null) 'in_at': inAt,
      if (outAt != null) 'out_at': outAt,
      if (inBy != null) 'in_by': inBy,
      if (outBy != null) 'out_by': outBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String?>? staffId,
    Value<String?>? date,
    Value<int?>? inAt,
    Value<int?>? outAt,
    Value<String?>? inBy,
    Value<String?>? outBy,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      inAt: inAt ?? this.inAt,
      outAt: outAt ?? this.outAt,
      inBy: inBy ?? this.inBy,
      outBy: outBy ?? this.outBy,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (inAt.present) {
      map['in_at'] = Variable<int>(inAt.value);
    }
    if (outAt.present) {
      map['out_at'] = Variable<int>(outAt.value);
    }
    if (inBy.present) {
      map['in_by'] = Variable<String>(inBy.value);
    }
    if (outBy.present) {
      map['out_by'] = Variable<String>(outBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('date: $date, ')
          ..write('inAt: $inAt, ')
          ..write('outAt: $outAt, ')
          ..write('inBy: $inBy, ')
          ..write('outBy: $outBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeavesTable extends Leaves with TableInfo<$LeavesTable, Leave> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeavesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedByMeta = const VerificationMeta(
    'markedBy',
  );
  @override
  late final GeneratedColumn<String> markedBy = GeneratedColumn<String>(
    'marked_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    staffId,
    date,
    markedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaves';
  @override
  VerificationContext validateIntegrity(
    Insertable<Leave> instance, {
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('marked_by')) {
      context.handle(
        _markedByMeta,
        markedBy.isAcceptableOrUnknown(data['marked_by']!, _markedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Leave map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Leave(
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
      markedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_by'],
      ),
    );
  }

  @override
  $LeavesTable createAlias(String alias) {
    return $LeavesTable(attachedDatabase, alias);
  }
}

class Leave extends DataClass implements Insertable<Leave> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String? staffId;
  final String? date;
  final String? markedBy;
  const Leave({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.staffId,
    this.date,
    this.markedBy,
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
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    if (!nullToAbsent || markedBy != null) {
      map['marked_by'] = Variable<String>(markedBy);
    }
    return map;
  }

  LeavesCompanion toCompanion(bool nullToAbsent) {
    return LeavesCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      markedBy: markedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(markedBy),
    );
  }

  factory Leave.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Leave(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      staffId: serializer.fromJson<String?>(json['staffId']),
      date: serializer.fromJson<String?>(json['date']),
      markedBy: serializer.fromJson<String?>(json['markedBy']),
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
      'staffId': serializer.toJson<String?>(staffId),
      'date': serializer.toJson<String?>(date),
      'markedBy': serializer.toJson<String?>(markedBy),
    };
  }

  Leave copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    Value<String?> staffId = const Value.absent(),
    Value<String?> date = const Value.absent(),
    Value<String?> markedBy = const Value.absent(),
  }) => Leave(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    staffId: staffId.present ? staffId.value : this.staffId,
    date: date.present ? date.value : this.date,
    markedBy: markedBy.present ? markedBy.value : this.markedBy,
  );
  Leave copyWithCompanion(LeavesCompanion data) {
    return Leave(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      date: data.date.present ? data.date.value : this.date,
      markedBy: data.markedBy.present ? data.markedBy.value : this.markedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Leave(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('date: $date, ')
          ..write('markedBy: $markedBy')
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
    staffId,
    date,
    markedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Leave &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.staffId == this.staffId &&
          other.date == this.date &&
          other.markedBy == this.markedBy);
}

class LeavesCompanion extends UpdateCompanion<Leave> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String?> staffId;
  final Value<String?> date;
  final Value<String?> markedBy;
  final Value<int> rowid;
  const LeavesCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.date = const Value.absent(),
    this.markedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeavesCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.date = const Value.absent(),
    this.markedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<Leave> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? staffId,
    Expression<String>? date,
    Expression<String>? markedBy,
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
      if (staffId != null) 'staff_id': staffId,
      if (date != null) 'date': date,
      if (markedBy != null) 'marked_by': markedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeavesCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String?>? staffId,
    Value<String?>? date,
    Value<String?>? markedBy,
    Value<int>? rowid,
  }) {
    return LeavesCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      markedBy: markedBy ?? this.markedBy,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (markedBy.present) {
      map['marked_by'] = Variable<String>(markedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeavesCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('date: $date, ')
          ..write('markedBy: $markedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayRulesTable extends PayRules
    with TableInfo<$PayRulesTable, PayRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _effectiveMonthMeta = const VerificationMeta(
    'effectiveMonth',
  );
  @override
  late final GeneratedColumn<String> effectiveMonth = GeneratedColumn<String>(
    'effective_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _workDaysMeta = const VerificationMeta(
    'workDays',
  );
  @override
  late final GeneratedColumn<String> workDays = GeneratedColumn<String>(
    'work_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6'),
  );
  static const VerificationMeta _payTypeMeta = const VerificationMeta(
    'payType',
  );
  @override
  late final GeneratedColumn<String> payType = GeneratedColumn<String>(
    'pay_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('hourly'),
  );
  static const VerificationMeta _ratePerHourPaiseMeta = const VerificationMeta(
    'ratePerHourPaise',
  );
  @override
  late final GeneratedColumn<int> ratePerHourPaise = GeneratedColumn<int>(
    'rate_per_hour_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roundingMinMeta = const VerificationMeta(
    'roundingMin',
  );
  @override
  late final GeneratedColumn<int> roundingMin = GeneratedColumn<int>(
    'rounding_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _minHoursPerVisitMeta = const VerificationMeta(
    'minHoursPerVisit',
  );
  @override
  late final GeneratedColumn<int> minHoursPerVisit = GeneratedColumn<int>(
    'min_hours_per_visit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountPerMonthPaiseMeta =
      const VerificationMeta('amountPerMonthPaise');
  @override
  late final GeneratedColumn<int> amountPerMonthPaise = GeneratedColumn<int>(
    'amount_per_month_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidLeavesPerMonthMeta =
      const VerificationMeta('paidLeavesPerMonth');
  @override
  late final GeneratedColumn<int> paidLeavesPerMonth = GeneratedColumn<int>(
    'paid_leaves_per_month',
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
    staffId,
    effectiveMonth,
    workDays,
    payType,
    ratePerHourPaise,
    roundingMin,
    minHoursPerVisit,
    amountPerMonthPaise,
    paidLeavesPerMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pay_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayRuleRow> instance, {
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('effective_month')) {
      context.handle(
        _effectiveMonthMeta,
        effectiveMonth.isAcceptableOrUnknown(
          data['effective_month']!,
          _effectiveMonthMeta,
        ),
      );
    }
    if (data.containsKey('work_days')) {
      context.handle(
        _workDaysMeta,
        workDays.isAcceptableOrUnknown(data['work_days']!, _workDaysMeta),
      );
    }
    if (data.containsKey('pay_type')) {
      context.handle(
        _payTypeMeta,
        payType.isAcceptableOrUnknown(data['pay_type']!, _payTypeMeta),
      );
    }
    if (data.containsKey('rate_per_hour_paise')) {
      context.handle(
        _ratePerHourPaiseMeta,
        ratePerHourPaise.isAcceptableOrUnknown(
          data['rate_per_hour_paise']!,
          _ratePerHourPaiseMeta,
        ),
      );
    }
    if (data.containsKey('rounding_min')) {
      context.handle(
        _roundingMinMeta,
        roundingMin.isAcceptableOrUnknown(
          data['rounding_min']!,
          _roundingMinMeta,
        ),
      );
    }
    if (data.containsKey('min_hours_per_visit')) {
      context.handle(
        _minHoursPerVisitMeta,
        minHoursPerVisit.isAcceptableOrUnknown(
          data['min_hours_per_visit']!,
          _minHoursPerVisitMeta,
        ),
      );
    }
    if (data.containsKey('amount_per_month_paise')) {
      context.handle(
        _amountPerMonthPaiseMeta,
        amountPerMonthPaise.isAcceptableOrUnknown(
          data['amount_per_month_paise']!,
          _amountPerMonthPaiseMeta,
        ),
      );
    }
    if (data.containsKey('paid_leaves_per_month')) {
      context.handle(
        _paidLeavesPerMonthMeta,
        paidLeavesPerMonth.isAcceptableOrUnknown(
          data['paid_leaves_per_month']!,
          _paidLeavesPerMonthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayRuleRow(
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      effectiveMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_month'],
      )!,
      workDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_days'],
      )!,
      payType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pay_type'],
      )!,
      ratePerHourPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_per_hour_paise'],
      )!,
      roundingMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounding_min'],
      )!,
      minHoursPerVisit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_hours_per_visit'],
      )!,
      amountPerMonthPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_per_month_paise'],
      )!,
      paidLeavesPerMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_leaves_per_month'],
      )!,
    );
  }

  @override
  $PayRulesTable createAlias(String alias) {
    return $PayRulesTable(attachedDatabase, alias);
  }
}

class PayRuleRow extends DataClass implements Insertable<PayRuleRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String staffId;
  final String effectiveMonth;
  final String workDays;
  final String payType;
  final int ratePerHourPaise;
  final int roundingMin;
  final int minHoursPerVisit;
  final int amountPerMonthPaise;
  final int paidLeavesPerMonth;
  const PayRuleRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.staffId,
    required this.effectiveMonth,
    required this.workDays,
    required this.payType,
    required this.ratePerHourPaise,
    required this.roundingMin,
    required this.minHoursPerVisit,
    required this.amountPerMonthPaise,
    required this.paidLeavesPerMonth,
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
    map['staff_id'] = Variable<String>(staffId);
    map['effective_month'] = Variable<String>(effectiveMonth);
    map['work_days'] = Variable<String>(workDays);
    map['pay_type'] = Variable<String>(payType);
    map['rate_per_hour_paise'] = Variable<int>(ratePerHourPaise);
    map['rounding_min'] = Variable<int>(roundingMin);
    map['min_hours_per_visit'] = Variable<int>(minHoursPerVisit);
    map['amount_per_month_paise'] = Variable<int>(amountPerMonthPaise);
    map['paid_leaves_per_month'] = Variable<int>(paidLeavesPerMonth);
    return map;
  }

  PayRulesCompanion toCompanion(bool nullToAbsent) {
    return PayRulesCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      staffId: Value(staffId),
      effectiveMonth: Value(effectiveMonth),
      workDays: Value(workDays),
      payType: Value(payType),
      ratePerHourPaise: Value(ratePerHourPaise),
      roundingMin: Value(roundingMin),
      minHoursPerVisit: Value(minHoursPerVisit),
      amountPerMonthPaise: Value(amountPerMonthPaise),
      paidLeavesPerMonth: Value(paidLeavesPerMonth),
    );
  }

  factory PayRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayRuleRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      staffId: serializer.fromJson<String>(json['staffId']),
      effectiveMonth: serializer.fromJson<String>(json['effectiveMonth']),
      workDays: serializer.fromJson<String>(json['workDays']),
      payType: serializer.fromJson<String>(json['payType']),
      ratePerHourPaise: serializer.fromJson<int>(json['ratePerHourPaise']),
      roundingMin: serializer.fromJson<int>(json['roundingMin']),
      minHoursPerVisit: serializer.fromJson<int>(json['minHoursPerVisit']),
      amountPerMonthPaise: serializer.fromJson<int>(
        json['amountPerMonthPaise'],
      ),
      paidLeavesPerMonth: serializer.fromJson<int>(json['paidLeavesPerMonth']),
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
      'staffId': serializer.toJson<String>(staffId),
      'effectiveMonth': serializer.toJson<String>(effectiveMonth),
      'workDays': serializer.toJson<String>(workDays),
      'payType': serializer.toJson<String>(payType),
      'ratePerHourPaise': serializer.toJson<int>(ratePerHourPaise),
      'roundingMin': serializer.toJson<int>(roundingMin),
      'minHoursPerVisit': serializer.toJson<int>(minHoursPerVisit),
      'amountPerMonthPaise': serializer.toJson<int>(amountPerMonthPaise),
      'paidLeavesPerMonth': serializer.toJson<int>(paidLeavesPerMonth),
    };
  }

  PayRuleRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    String? staffId,
    String? effectiveMonth,
    String? workDays,
    String? payType,
    int? ratePerHourPaise,
    int? roundingMin,
    int? minHoursPerVisit,
    int? amountPerMonthPaise,
    int? paidLeavesPerMonth,
  }) => PayRuleRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    staffId: staffId ?? this.staffId,
    effectiveMonth: effectiveMonth ?? this.effectiveMonth,
    workDays: workDays ?? this.workDays,
    payType: payType ?? this.payType,
    ratePerHourPaise: ratePerHourPaise ?? this.ratePerHourPaise,
    roundingMin: roundingMin ?? this.roundingMin,
    minHoursPerVisit: minHoursPerVisit ?? this.minHoursPerVisit,
    amountPerMonthPaise: amountPerMonthPaise ?? this.amountPerMonthPaise,
    paidLeavesPerMonth: paidLeavesPerMonth ?? this.paidLeavesPerMonth,
  );
  PayRuleRow copyWithCompanion(PayRulesCompanion data) {
    return PayRuleRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      effectiveMonth: data.effectiveMonth.present
          ? data.effectiveMonth.value
          : this.effectiveMonth,
      workDays: data.workDays.present ? data.workDays.value : this.workDays,
      payType: data.payType.present ? data.payType.value : this.payType,
      ratePerHourPaise: data.ratePerHourPaise.present
          ? data.ratePerHourPaise.value
          : this.ratePerHourPaise,
      roundingMin: data.roundingMin.present
          ? data.roundingMin.value
          : this.roundingMin,
      minHoursPerVisit: data.minHoursPerVisit.present
          ? data.minHoursPerVisit.value
          : this.minHoursPerVisit,
      amountPerMonthPaise: data.amountPerMonthPaise.present
          ? data.amountPerMonthPaise.value
          : this.amountPerMonthPaise,
      paidLeavesPerMonth: data.paidLeavesPerMonth.present
          ? data.paidLeavesPerMonth.value
          : this.paidLeavesPerMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayRuleRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('effectiveMonth: $effectiveMonth, ')
          ..write('workDays: $workDays, ')
          ..write('payType: $payType, ')
          ..write('ratePerHourPaise: $ratePerHourPaise, ')
          ..write('roundingMin: $roundingMin, ')
          ..write('minHoursPerVisit: $minHoursPerVisit, ')
          ..write('amountPerMonthPaise: $amountPerMonthPaise, ')
          ..write('paidLeavesPerMonth: $paidLeavesPerMonth')
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
    staffId,
    effectiveMonth,
    workDays,
    payType,
    ratePerHourPaise,
    roundingMin,
    minHoursPerVisit,
    amountPerMonthPaise,
    paidLeavesPerMonth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayRuleRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.staffId == this.staffId &&
          other.effectiveMonth == this.effectiveMonth &&
          other.workDays == this.workDays &&
          other.payType == this.payType &&
          other.ratePerHourPaise == this.ratePerHourPaise &&
          other.roundingMin == this.roundingMin &&
          other.minHoursPerVisit == this.minHoursPerVisit &&
          other.amountPerMonthPaise == this.amountPerMonthPaise &&
          other.paidLeavesPerMonth == this.paidLeavesPerMonth);
}

class PayRulesCompanion extends UpdateCompanion<PayRuleRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String> staffId;
  final Value<String> effectiveMonth;
  final Value<String> workDays;
  final Value<String> payType;
  final Value<int> ratePerHourPaise;
  final Value<int> roundingMin;
  final Value<int> minHoursPerVisit;
  final Value<int> amountPerMonthPaise;
  final Value<int> paidLeavesPerMonth;
  final Value<int> rowid;
  const PayRulesCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.effectiveMonth = const Value.absent(),
    this.workDays = const Value.absent(),
    this.payType = const Value.absent(),
    this.ratePerHourPaise = const Value.absent(),
    this.roundingMin = const Value.absent(),
    this.minHoursPerVisit = const Value.absent(),
    this.amountPerMonthPaise = const Value.absent(),
    this.paidLeavesPerMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayRulesCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.effectiveMonth = const Value.absent(),
    this.workDays = const Value.absent(),
    this.payType = const Value.absent(),
    this.ratePerHourPaise = const Value.absent(),
    this.roundingMin = const Value.absent(),
    this.minHoursPerVisit = const Value.absent(),
    this.amountPerMonthPaise = const Value.absent(),
    this.paidLeavesPerMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<PayRuleRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? staffId,
    Expression<String>? effectiveMonth,
    Expression<String>? workDays,
    Expression<String>? payType,
    Expression<int>? ratePerHourPaise,
    Expression<int>? roundingMin,
    Expression<int>? minHoursPerVisit,
    Expression<int>? amountPerMonthPaise,
    Expression<int>? paidLeavesPerMonth,
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
      if (staffId != null) 'staff_id': staffId,
      if (effectiveMonth != null) 'effective_month': effectiveMonth,
      if (workDays != null) 'work_days': workDays,
      if (payType != null) 'pay_type': payType,
      if (ratePerHourPaise != null) 'rate_per_hour_paise': ratePerHourPaise,
      if (roundingMin != null) 'rounding_min': roundingMin,
      if (minHoursPerVisit != null) 'min_hours_per_visit': minHoursPerVisit,
      if (amountPerMonthPaise != null)
        'amount_per_month_paise': amountPerMonthPaise,
      if (paidLeavesPerMonth != null)
        'paid_leaves_per_month': paidLeavesPerMonth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String>? staffId,
    Value<String>? effectiveMonth,
    Value<String>? workDays,
    Value<String>? payType,
    Value<int>? ratePerHourPaise,
    Value<int>? roundingMin,
    Value<int>? minHoursPerVisit,
    Value<int>? amountPerMonthPaise,
    Value<int>? paidLeavesPerMonth,
    Value<int>? rowid,
  }) {
    return PayRulesCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      staffId: staffId ?? this.staffId,
      effectiveMonth: effectiveMonth ?? this.effectiveMonth,
      workDays: workDays ?? this.workDays,
      payType: payType ?? this.payType,
      ratePerHourPaise: ratePerHourPaise ?? this.ratePerHourPaise,
      roundingMin: roundingMin ?? this.roundingMin,
      minHoursPerVisit: minHoursPerVisit ?? this.minHoursPerVisit,
      amountPerMonthPaise: amountPerMonthPaise ?? this.amountPerMonthPaise,
      paidLeavesPerMonth: paidLeavesPerMonth ?? this.paidLeavesPerMonth,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (effectiveMonth.present) {
      map['effective_month'] = Variable<String>(effectiveMonth.value);
    }
    if (workDays.present) {
      map['work_days'] = Variable<String>(workDays.value);
    }
    if (payType.present) {
      map['pay_type'] = Variable<String>(payType.value);
    }
    if (ratePerHourPaise.present) {
      map['rate_per_hour_paise'] = Variable<int>(ratePerHourPaise.value);
    }
    if (roundingMin.present) {
      map['rounding_min'] = Variable<int>(roundingMin.value);
    }
    if (minHoursPerVisit.present) {
      map['min_hours_per_visit'] = Variable<int>(minHoursPerVisit.value);
    }
    if (amountPerMonthPaise.present) {
      map['amount_per_month_paise'] = Variable<int>(amountPerMonthPaise.value);
    }
    if (paidLeavesPerMonth.present) {
      map['paid_leaves_per_month'] = Variable<int>(paidLeavesPerMonth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayRulesCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('effectiveMonth: $effectiveMonth, ')
          ..write('workDays: $workDays, ')
          ..write('payType: $payType, ')
          ..write('ratePerHourPaise: $ratePerHourPaise, ')
          ..write('roundingMin: $roundingMin, ')
          ..write('minHoursPerVisit: $minHoursPerVisit, ')
          ..write('amountPerMonthPaise: $amountPerMonthPaise, ')
          ..write('paidLeavesPerMonth: $paidLeavesPerMonth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayAdjustmentsTable extends PayAdjustments
    with TableInfo<$PayAdjustmentsTable, PayAdjustmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayAdjustmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('extra'),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _settlementAttemptIdMeta =
      const VerificationMeta('settlementAttemptId');
  @override
  late final GeneratedColumn<String> settlementAttemptId =
      GeneratedColumn<String>(
        'settlement_attempt_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    staffId,
    month,
    kind,
    amountPaise,
    note,
    settlementAttemptId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pay_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayAdjustmentRow> instance, {
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('settlement_attempt_id')) {
      context.handle(
        _settlementAttemptIdMeta,
        settlementAttemptId.isAcceptableOrUnknown(
          data['settlement_attempt_id']!,
          _settlementAttemptIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayAdjustmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayAdjustmentRow(
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      settlementAttemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_attempt_id'],
      ),
    );
  }

  @override
  $PayAdjustmentsTable createAlias(String alias) {
    return $PayAdjustmentsTable(attachedDatabase, alias);
  }
}

class PayAdjustmentRow extends DataClass
    implements Insertable<PayAdjustmentRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String staffId;
  final String month;
  final String kind;
  final int amountPaise;
  final String note;
  final String? settlementAttemptId;
  const PayAdjustmentRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.staffId,
    required this.month,
    required this.kind,
    required this.amountPaise,
    required this.note,
    this.settlementAttemptId,
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
    map['staff_id'] = Variable<String>(staffId);
    map['month'] = Variable<String>(month);
    map['kind'] = Variable<String>(kind);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || settlementAttemptId != null) {
      map['settlement_attempt_id'] = Variable<String>(settlementAttemptId);
    }
    return map;
  }

  PayAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return PayAdjustmentsCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      staffId: Value(staffId),
      month: Value(month),
      kind: Value(kind),
      amountPaise: Value(amountPaise),
      note: Value(note),
      settlementAttemptId: settlementAttemptId == null && nullToAbsent
          ? const Value.absent()
          : Value(settlementAttemptId),
    );
  }

  factory PayAdjustmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayAdjustmentRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      staffId: serializer.fromJson<String>(json['staffId']),
      month: serializer.fromJson<String>(json['month']),
      kind: serializer.fromJson<String>(json['kind']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      note: serializer.fromJson<String>(json['note']),
      settlementAttemptId: serializer.fromJson<String?>(
        json['settlementAttemptId'],
      ),
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
      'staffId': serializer.toJson<String>(staffId),
      'month': serializer.toJson<String>(month),
      'kind': serializer.toJson<String>(kind),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'note': serializer.toJson<String>(note),
      'settlementAttemptId': serializer.toJson<String?>(settlementAttemptId),
    };
  }

  PayAdjustmentRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    String? staffId,
    String? month,
    String? kind,
    int? amountPaise,
    String? note,
    Value<String?> settlementAttemptId = const Value.absent(),
  }) => PayAdjustmentRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    staffId: staffId ?? this.staffId,
    month: month ?? this.month,
    kind: kind ?? this.kind,
    amountPaise: amountPaise ?? this.amountPaise,
    note: note ?? this.note,
    settlementAttemptId: settlementAttemptId.present
        ? settlementAttemptId.value
        : this.settlementAttemptId,
  );
  PayAdjustmentRow copyWithCompanion(PayAdjustmentsCompanion data) {
    return PayAdjustmentRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      month: data.month.present ? data.month.value : this.month,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      note: data.note.present ? data.note.value : this.note,
      settlementAttemptId: data.settlementAttemptId.present
          ? data.settlementAttemptId.value
          : this.settlementAttemptId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayAdjustmentRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('month: $month, ')
          ..write('kind: $kind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('note: $note, ')
          ..write('settlementAttemptId: $settlementAttemptId')
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
    staffId,
    month,
    kind,
    amountPaise,
    note,
    settlementAttemptId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayAdjustmentRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.staffId == this.staffId &&
          other.month == this.month &&
          other.kind == this.kind &&
          other.amountPaise == this.amountPaise &&
          other.note == this.note &&
          other.settlementAttemptId == this.settlementAttemptId);
}

class PayAdjustmentsCompanion extends UpdateCompanion<PayAdjustmentRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String> staffId;
  final Value<String> month;
  final Value<String> kind;
  final Value<int> amountPaise;
  final Value<String> note;
  final Value<String?> settlementAttemptId;
  final Value<int> rowid;
  const PayAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.month = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.note = const Value.absent(),
    this.settlementAttemptId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayAdjustmentsCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.month = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.note = const Value.absent(),
    this.settlementAttemptId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<PayAdjustmentRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? staffId,
    Expression<String>? month,
    Expression<String>? kind,
    Expression<int>? amountPaise,
    Expression<String>? note,
    Expression<String>? settlementAttemptId,
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
      if (staffId != null) 'staff_id': staffId,
      if (month != null) 'month': month,
      if (kind != null) 'kind': kind,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (note != null) 'note': note,
      if (settlementAttemptId != null)
        'settlement_attempt_id': settlementAttemptId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayAdjustmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String>? staffId,
    Value<String>? month,
    Value<String>? kind,
    Value<int>? amountPaise,
    Value<String>? note,
    Value<String?>? settlementAttemptId,
    Value<int>? rowid,
  }) {
    return PayAdjustmentsCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      staffId: staffId ?? this.staffId,
      month: month ?? this.month,
      kind: kind ?? this.kind,
      amountPaise: amountPaise ?? this.amountPaise,
      note: note ?? this.note,
      settlementAttemptId: settlementAttemptId ?? this.settlementAttemptId,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (settlementAttemptId.present) {
      map['settlement_attempt_id'] = Variable<String>(
        settlementAttemptId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('month: $month, ')
          ..write('kind: $kind, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('note: $note, ')
          ..write('settlementAttemptId: $settlementAttemptId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementAttemptsTable extends SettlementAttempts
    with TableInfo<$SettlementAttemptsTable, SettlementAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementAttemptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('settle'),
  );
  static const VerificationMeta _refAttemptIdMeta = const VerificationMeta(
    'refAttemptId',
  );
  @override
  late final GeneratedColumn<String> refAttemptId = GeneratedColumn<String>(
    'ref_attempt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netPaiseMeta = const VerificationMeta(
    'netPaise',
  );
  @override
  late final GeneratedColumn<int> netPaise = GeneratedColumn<int>(
    'net_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _breakdownJsonMeta = const VerificationMeta(
    'breakdownJson',
  );
  @override
  late final GeneratedColumn<String> breakdownJson = GeneratedColumn<String>(
    'breakdown_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deltaPaiseMeta = const VerificationMeta(
    'deltaPaise',
  );
  @override
  late final GeneratedColumn<int> deltaPaise = GeneratedColumn<int>(
    'delta_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _prevTransferIdsMeta = const VerificationMeta(
    'prevTransferIds',
  );
  @override
  late final GeneratedColumn<String> prevTransferIds = GeneratedColumn<String>(
    'prev_transfer_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byMemberMeta = const VerificationMeta(
    'byMember',
  );
  @override
  late final GeneratedColumn<String> byMember = GeneratedColumn<String>(
    'by_member',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    staffId,
    month,
    kind,
    refAttemptId,
    amountPaise,
    method,
    netPaise,
    breakdownJson,
    deltaPaise,
    prevTransferIds,
    expenseId,
    byMember,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlement_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettlementAttemptRow> instance, {
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('ref_attempt_id')) {
      context.handle(
        _refAttemptIdMeta,
        refAttemptId.isAcceptableOrUnknown(
          data['ref_attempt_id']!,
          _refAttemptIdMeta,
        ),
      );
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('net_paise')) {
      context.handle(
        _netPaiseMeta,
        netPaise.isAcceptableOrUnknown(data['net_paise']!, _netPaiseMeta),
      );
    }
    if (data.containsKey('breakdown_json')) {
      context.handle(
        _breakdownJsonMeta,
        breakdownJson.isAcceptableOrUnknown(
          data['breakdown_json']!,
          _breakdownJsonMeta,
        ),
      );
    }
    if (data.containsKey('delta_paise')) {
      context.handle(
        _deltaPaiseMeta,
        deltaPaise.isAcceptableOrUnknown(data['delta_paise']!, _deltaPaiseMeta),
      );
    }
    if (data.containsKey('prev_transfer_ids')) {
      context.handle(
        _prevTransferIdsMeta,
        prevTransferIds.isAcceptableOrUnknown(
          data['prev_transfer_ids']!,
          _prevTransferIdsMeta,
        ),
      );
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    }
    if (data.containsKey('by_member')) {
      context.handle(
        _byMemberMeta,
        byMember.isAcceptableOrUnknown(data['by_member']!, _byMemberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettlementAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettlementAttemptRow(
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
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      refAttemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_attempt_id'],
      ),
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      ),
      netPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_paise'],
      )!,
      breakdownJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breakdown_json'],
      ),
      deltaPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta_paise'],
      )!,
      prevTransferIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_transfer_ids'],
      ),
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      ),
      byMember: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}by_member'],
      )!,
    );
  }

  @override
  $SettlementAttemptsTable createAlias(String alias) {
    return $SettlementAttemptsTable(attachedDatabase, alias);
  }
}

class SettlementAttemptRow extends DataClass
    implements Insertable<SettlementAttemptRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String staffId;
  final String month;
  final String kind;
  final String? refAttemptId;
  final int amountPaise;
  final String? method;
  final int netPaise;
  final String? breakdownJson;
  final int deltaPaise;
  final String? prevTransferIds;
  final String? expenseId;
  final String byMember;
  const SettlementAttemptRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.staffId,
    required this.month,
    required this.kind,
    this.refAttemptId,
    required this.amountPaise,
    this.method,
    required this.netPaise,
    this.breakdownJson,
    required this.deltaPaise,
    this.prevTransferIds,
    this.expenseId,
    required this.byMember,
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
    map['staff_id'] = Variable<String>(staffId);
    map['month'] = Variable<String>(month);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || refAttemptId != null) {
      map['ref_attempt_id'] = Variable<String>(refAttemptId);
    }
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    map['net_paise'] = Variable<int>(netPaise);
    if (!nullToAbsent || breakdownJson != null) {
      map['breakdown_json'] = Variable<String>(breakdownJson);
    }
    map['delta_paise'] = Variable<int>(deltaPaise);
    if (!nullToAbsent || prevTransferIds != null) {
      map['prev_transfer_ids'] = Variable<String>(prevTransferIds);
    }
    if (!nullToAbsent || expenseId != null) {
      map['expense_id'] = Variable<String>(expenseId);
    }
    map['by_member'] = Variable<String>(byMember);
    return map;
  }

  SettlementAttemptsCompanion toCompanion(bool nullToAbsent) {
    return SettlementAttemptsCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      staffId: Value(staffId),
      month: Value(month),
      kind: Value(kind),
      refAttemptId: refAttemptId == null && nullToAbsent
          ? const Value.absent()
          : Value(refAttemptId),
      amountPaise: Value(amountPaise),
      method: method == null && nullToAbsent
          ? const Value.absent()
          : Value(method),
      netPaise: Value(netPaise),
      breakdownJson: breakdownJson == null && nullToAbsent
          ? const Value.absent()
          : Value(breakdownJson),
      deltaPaise: Value(deltaPaise),
      prevTransferIds: prevTransferIds == null && nullToAbsent
          ? const Value.absent()
          : Value(prevTransferIds),
      expenseId: expenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseId),
      byMember: Value(byMember),
    );
  }

  factory SettlementAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettlementAttemptRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      staffId: serializer.fromJson<String>(json['staffId']),
      month: serializer.fromJson<String>(json['month']),
      kind: serializer.fromJson<String>(json['kind']),
      refAttemptId: serializer.fromJson<String?>(json['refAttemptId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      method: serializer.fromJson<String?>(json['method']),
      netPaise: serializer.fromJson<int>(json['netPaise']),
      breakdownJson: serializer.fromJson<String?>(json['breakdownJson']),
      deltaPaise: serializer.fromJson<int>(json['deltaPaise']),
      prevTransferIds: serializer.fromJson<String?>(json['prevTransferIds']),
      expenseId: serializer.fromJson<String?>(json['expenseId']),
      byMember: serializer.fromJson<String>(json['byMember']),
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
      'staffId': serializer.toJson<String>(staffId),
      'month': serializer.toJson<String>(month),
      'kind': serializer.toJson<String>(kind),
      'refAttemptId': serializer.toJson<String?>(refAttemptId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'method': serializer.toJson<String?>(method),
      'netPaise': serializer.toJson<int>(netPaise),
      'breakdownJson': serializer.toJson<String?>(breakdownJson),
      'deltaPaise': serializer.toJson<int>(deltaPaise),
      'prevTransferIds': serializer.toJson<String?>(prevTransferIds),
      'expenseId': serializer.toJson<String?>(expenseId),
      'byMember': serializer.toJson<String>(byMember),
    };
  }

  SettlementAttemptRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    String? staffId,
    String? month,
    String? kind,
    Value<String?> refAttemptId = const Value.absent(),
    int? amountPaise,
    Value<String?> method = const Value.absent(),
    int? netPaise,
    Value<String?> breakdownJson = const Value.absent(),
    int? deltaPaise,
    Value<String?> prevTransferIds = const Value.absent(),
    Value<String?> expenseId = const Value.absent(),
    String? byMember,
  }) => SettlementAttemptRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    staffId: staffId ?? this.staffId,
    month: month ?? this.month,
    kind: kind ?? this.kind,
    refAttemptId: refAttemptId.present ? refAttemptId.value : this.refAttemptId,
    amountPaise: amountPaise ?? this.amountPaise,
    method: method.present ? method.value : this.method,
    netPaise: netPaise ?? this.netPaise,
    breakdownJson: breakdownJson.present
        ? breakdownJson.value
        : this.breakdownJson,
    deltaPaise: deltaPaise ?? this.deltaPaise,
    prevTransferIds: prevTransferIds.present
        ? prevTransferIds.value
        : this.prevTransferIds,
    expenseId: expenseId.present ? expenseId.value : this.expenseId,
    byMember: byMember ?? this.byMember,
  );
  SettlementAttemptRow copyWithCompanion(SettlementAttemptsCompanion data) {
    return SettlementAttemptRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      month: data.month.present ? data.month.value : this.month,
      kind: data.kind.present ? data.kind.value : this.kind,
      refAttemptId: data.refAttemptId.present
          ? data.refAttemptId.value
          : this.refAttemptId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      method: data.method.present ? data.method.value : this.method,
      netPaise: data.netPaise.present ? data.netPaise.value : this.netPaise,
      breakdownJson: data.breakdownJson.present
          ? data.breakdownJson.value
          : this.breakdownJson,
      deltaPaise: data.deltaPaise.present
          ? data.deltaPaise.value
          : this.deltaPaise,
      prevTransferIds: data.prevTransferIds.present
          ? data.prevTransferIds.value
          : this.prevTransferIds,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      byMember: data.byMember.present ? data.byMember.value : this.byMember,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettlementAttemptRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('month: $month, ')
          ..write('kind: $kind, ')
          ..write('refAttemptId: $refAttemptId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('method: $method, ')
          ..write('netPaise: $netPaise, ')
          ..write('breakdownJson: $breakdownJson, ')
          ..write('deltaPaise: $deltaPaise, ')
          ..write('prevTransferIds: $prevTransferIds, ')
          ..write('expenseId: $expenseId, ')
          ..write('byMember: $byMember')
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
    staffId,
    month,
    kind,
    refAttemptId,
    amountPaise,
    method,
    netPaise,
    breakdownJson,
    deltaPaise,
    prevTransferIds,
    expenseId,
    byMember,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettlementAttemptRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.staffId == this.staffId &&
          other.month == this.month &&
          other.kind == this.kind &&
          other.refAttemptId == this.refAttemptId &&
          other.amountPaise == this.amountPaise &&
          other.method == this.method &&
          other.netPaise == this.netPaise &&
          other.breakdownJson == this.breakdownJson &&
          other.deltaPaise == this.deltaPaise &&
          other.prevTransferIds == this.prevTransferIds &&
          other.expenseId == this.expenseId &&
          other.byMember == this.byMember);
}

class SettlementAttemptsCompanion
    extends UpdateCompanion<SettlementAttemptRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String> staffId;
  final Value<String> month;
  final Value<String> kind;
  final Value<String?> refAttemptId;
  final Value<int> amountPaise;
  final Value<String?> method;
  final Value<int> netPaise;
  final Value<String?> breakdownJson;
  final Value<int> deltaPaise;
  final Value<String?> prevTransferIds;
  final Value<String?> expenseId;
  final Value<String> byMember;
  final Value<int> rowid;
  const SettlementAttemptsCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.month = const Value.absent(),
    this.kind = const Value.absent(),
    this.refAttemptId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.method = const Value.absent(),
    this.netPaise = const Value.absent(),
    this.breakdownJson = const Value.absent(),
    this.deltaPaise = const Value.absent(),
    this.prevTransferIds = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.byMember = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementAttemptsCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.staffId = const Value.absent(),
    this.month = const Value.absent(),
    this.kind = const Value.absent(),
    this.refAttemptId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.method = const Value.absent(),
    this.netPaise = const Value.absent(),
    this.breakdownJson = const Value.absent(),
    this.deltaPaise = const Value.absent(),
    this.prevTransferIds = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.byMember = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<SettlementAttemptRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? staffId,
    Expression<String>? month,
    Expression<String>? kind,
    Expression<String>? refAttemptId,
    Expression<int>? amountPaise,
    Expression<String>? method,
    Expression<int>? netPaise,
    Expression<String>? breakdownJson,
    Expression<int>? deltaPaise,
    Expression<String>? prevTransferIds,
    Expression<String>? expenseId,
    Expression<String>? byMember,
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
      if (staffId != null) 'staff_id': staffId,
      if (month != null) 'month': month,
      if (kind != null) 'kind': kind,
      if (refAttemptId != null) 'ref_attempt_id': refAttemptId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (method != null) 'method': method,
      if (netPaise != null) 'net_paise': netPaise,
      if (breakdownJson != null) 'breakdown_json': breakdownJson,
      if (deltaPaise != null) 'delta_paise': deltaPaise,
      if (prevTransferIds != null) 'prev_transfer_ids': prevTransferIds,
      if (expenseId != null) 'expense_id': expenseId,
      if (byMember != null) 'by_member': byMember,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String>? staffId,
    Value<String>? month,
    Value<String>? kind,
    Value<String?>? refAttemptId,
    Value<int>? amountPaise,
    Value<String?>? method,
    Value<int>? netPaise,
    Value<String?>? breakdownJson,
    Value<int>? deltaPaise,
    Value<String?>? prevTransferIds,
    Value<String?>? expenseId,
    Value<String>? byMember,
    Value<int>? rowid,
  }) {
    return SettlementAttemptsCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      staffId: staffId ?? this.staffId,
      month: month ?? this.month,
      kind: kind ?? this.kind,
      refAttemptId: refAttemptId ?? this.refAttemptId,
      amountPaise: amountPaise ?? this.amountPaise,
      method: method ?? this.method,
      netPaise: netPaise ?? this.netPaise,
      breakdownJson: breakdownJson ?? this.breakdownJson,
      deltaPaise: deltaPaise ?? this.deltaPaise,
      prevTransferIds: prevTransferIds ?? this.prevTransferIds,
      expenseId: expenseId ?? this.expenseId,
      byMember: byMember ?? this.byMember,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (refAttemptId.present) {
      map['ref_attempt_id'] = Variable<String>(refAttemptId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (netPaise.present) {
      map['net_paise'] = Variable<int>(netPaise.value);
    }
    if (breakdownJson.present) {
      map['breakdown_json'] = Variable<String>(breakdownJson.value);
    }
    if (deltaPaise.present) {
      map['delta_paise'] = Variable<int>(deltaPaise.value);
    }
    if (prevTransferIds.present) {
      map['prev_transfer_ids'] = Variable<String>(prevTransferIds.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (byMember.present) {
      map['by_member'] = Variable<String>(byMember.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('staffId: $staffId, ')
          ..write('month: $month, ')
          ..write('kind: $kind, ')
          ..write('refAttemptId: $refAttemptId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('method: $method, ')
          ..write('netPaise: $netPaise, ')
          ..write('breakdownJson: $breakdownJson, ')
          ..write('deltaPaise: $deltaPaise, ')
          ..write('prevTransferIds: $prevTransferIds, ')
          ..write('expenseId: $expenseId, ')
          ..write('byMember: $byMember, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _merchantKeyMeta = const VerificationMeta(
    'merchantKey',
  );
  @override
  late final GeneratedColumn<String> merchantKey = GeneratedColumn<String>(
    'merchant_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Other'),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('upi'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _docMonthMeta = const VerificationMeta(
    'docMonth',
  );
  @override
  late final GeneratedColumn<String> docMonth = GeneratedColumn<String>(
    'doc_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _forMonthMeta = const VerificationMeta(
    'forMonth',
  );
  @override
  late final GeneratedColumn<String> forMonth = GeneratedColumn<String>(
    'for_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidByMeta = const VerificationMeta('paidBy');
  @override
  late final GeneratedColumn<String> paidBy = GeneratedColumn<String>(
    'paid_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addedByMeta = const VerificationMeta(
    'addedBy',
  );
  @override
  late final GeneratedColumn<String> addedBy = GeneratedColumn<String>(
    'added_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderChannelMeta = const VerificationMeta(
    'orderChannel',
  );
  @override
  late final GeneratedColumn<String> orderChannel = GeneratedColumn<String>(
    'order_channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settlementAttemptIdMeta =
      const VerificationMeta('settlementAttemptId');
  @override
  late final GeneratedColumn<String> settlementAttemptId =
      GeneratedColumn<String>(
        'settlement_attempt_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    amountPaise,
    merchant,
    merchantKey,
    category,
    method,
    date,
    docMonth,
    forMonth,
    paidBy,
    addedBy,
    source,
    billId,
    orderChannel,
    staffId,
    settlementAttemptId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
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
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('merchant_key')) {
      context.handle(
        _merchantKeyMeta,
        merchantKey.isAcceptableOrUnknown(
          data['merchant_key']!,
          _merchantKeyMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('doc_month')) {
      context.handle(
        _docMonthMeta,
        docMonth.isAcceptableOrUnknown(data['doc_month']!, _docMonthMeta),
      );
    }
    if (data.containsKey('for_month')) {
      context.handle(
        _forMonthMeta,
        forMonth.isAcceptableOrUnknown(data['for_month']!, _forMonthMeta),
      );
    }
    if (data.containsKey('paid_by')) {
      context.handle(
        _paidByMeta,
        paidBy.isAcceptableOrUnknown(data['paid_by']!, _paidByMeta),
      );
    }
    if (data.containsKey('added_by')) {
      context.handle(
        _addedByMeta,
        addedBy.isAcceptableOrUnknown(data['added_by']!, _addedByMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    }
    if (data.containsKey('order_channel')) {
      context.handle(
        _orderChannelMeta,
        orderChannel.isAcceptableOrUnknown(
          data['order_channel']!,
          _orderChannelMeta,
        ),
      );
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('settlement_attempt_id')) {
      context.handle(
        _settlementAttemptIdMeta,
        settlementAttemptId.isAcceptableOrUnknown(
          data['settlement_attempt_id']!,
          _settlementAttemptIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
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
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      merchantKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_key'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      docMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_month'],
      )!,
      forMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}for_month'],
      ),
      paidBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by'],
      )!,
      addedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_by'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      ),
      orderChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_channel'],
      ),
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
      settlementAttemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_attempt_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final int amountPaise;
  final String merchant;
  final String merchantKey;
  final String category;
  final String method;
  final String date;
  final String docMonth;
  final String? forMonth;
  final String paidBy;
  final String addedBy;
  final String source;
  final String? billId;
  final String? orderChannel;
  final String? staffId;
  final String? settlementAttemptId;
  final String? note;
  const ExpenseRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.amountPaise,
    required this.merchant,
    required this.merchantKey,
    required this.category,
    required this.method,
    required this.date,
    required this.docMonth,
    this.forMonth,
    required this.paidBy,
    required this.addedBy,
    required this.source,
    this.billId,
    this.orderChannel,
    this.staffId,
    this.settlementAttemptId,
    this.note,
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
    map['amount_paise'] = Variable<int>(amountPaise);
    map['merchant'] = Variable<String>(merchant);
    map['merchant_key'] = Variable<String>(merchantKey);
    map['category'] = Variable<String>(category);
    map['method'] = Variable<String>(method);
    map['date'] = Variable<String>(date);
    map['doc_month'] = Variable<String>(docMonth);
    if (!nullToAbsent || forMonth != null) {
      map['for_month'] = Variable<String>(forMonth);
    }
    map['paid_by'] = Variable<String>(paidBy);
    map['added_by'] = Variable<String>(addedBy);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || billId != null) {
      map['bill_id'] = Variable<String>(billId);
    }
    if (!nullToAbsent || orderChannel != null) {
      map['order_channel'] = Variable<String>(orderChannel);
    }
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    if (!nullToAbsent || settlementAttemptId != null) {
      map['settlement_attempt_id'] = Variable<String>(settlementAttemptId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      amountPaise: Value(amountPaise),
      merchant: Value(merchant),
      merchantKey: Value(merchantKey),
      category: Value(category),
      method: Value(method),
      date: Value(date),
      docMonth: Value(docMonth),
      forMonth: forMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(forMonth),
      paidBy: Value(paidBy),
      addedBy: Value(addedBy),
      source: Value(source),
      billId: billId == null && nullToAbsent
          ? const Value.absent()
          : Value(billId),
      orderChannel: orderChannel == null && nullToAbsent
          ? const Value.absent()
          : Value(orderChannel),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
      settlementAttemptId: settlementAttemptId == null && nullToAbsent
          ? const Value.absent()
          : Value(settlementAttemptId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      merchant: serializer.fromJson<String>(json['merchant']),
      merchantKey: serializer.fromJson<String>(json['merchantKey']),
      category: serializer.fromJson<String>(json['category']),
      method: serializer.fromJson<String>(json['method']),
      date: serializer.fromJson<String>(json['date']),
      docMonth: serializer.fromJson<String>(json['docMonth']),
      forMonth: serializer.fromJson<String?>(json['forMonth']),
      paidBy: serializer.fromJson<String>(json['paidBy']),
      addedBy: serializer.fromJson<String>(json['addedBy']),
      source: serializer.fromJson<String>(json['source']),
      billId: serializer.fromJson<String?>(json['billId']),
      orderChannel: serializer.fromJson<String?>(json['orderChannel']),
      staffId: serializer.fromJson<String?>(json['staffId']),
      settlementAttemptId: serializer.fromJson<String?>(
        json['settlementAttemptId'],
      ),
      note: serializer.fromJson<String?>(json['note']),
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
      'amountPaise': serializer.toJson<int>(amountPaise),
      'merchant': serializer.toJson<String>(merchant),
      'merchantKey': serializer.toJson<String>(merchantKey),
      'category': serializer.toJson<String>(category),
      'method': serializer.toJson<String>(method),
      'date': serializer.toJson<String>(date),
      'docMonth': serializer.toJson<String>(docMonth),
      'forMonth': serializer.toJson<String?>(forMonth),
      'paidBy': serializer.toJson<String>(paidBy),
      'addedBy': serializer.toJson<String>(addedBy),
      'source': serializer.toJson<String>(source),
      'billId': serializer.toJson<String?>(billId),
      'orderChannel': serializer.toJson<String?>(orderChannel),
      'staffId': serializer.toJson<String?>(staffId),
      'settlementAttemptId': serializer.toJson<String?>(settlementAttemptId),
      'note': serializer.toJson<String?>(note),
    };
  }

  ExpenseRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    int? amountPaise,
    String? merchant,
    String? merchantKey,
    String? category,
    String? method,
    String? date,
    String? docMonth,
    Value<String?> forMonth = const Value.absent(),
    String? paidBy,
    String? addedBy,
    String? source,
    Value<String?> billId = const Value.absent(),
    Value<String?> orderChannel = const Value.absent(),
    Value<String?> staffId = const Value.absent(),
    Value<String?> settlementAttemptId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => ExpenseRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    amountPaise: amountPaise ?? this.amountPaise,
    merchant: merchant ?? this.merchant,
    merchantKey: merchantKey ?? this.merchantKey,
    category: category ?? this.category,
    method: method ?? this.method,
    date: date ?? this.date,
    docMonth: docMonth ?? this.docMonth,
    forMonth: forMonth.present ? forMonth.value : this.forMonth,
    paidBy: paidBy ?? this.paidBy,
    addedBy: addedBy ?? this.addedBy,
    source: source ?? this.source,
    billId: billId.present ? billId.value : this.billId,
    orderChannel: orderChannel.present ? orderChannel.value : this.orderChannel,
    staffId: staffId.present ? staffId.value : this.staffId,
    settlementAttemptId: settlementAttemptId.present
        ? settlementAttemptId.value
        : this.settlementAttemptId,
    note: note.present ? note.value : this.note,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      merchantKey: data.merchantKey.present
          ? data.merchantKey.value
          : this.merchantKey,
      category: data.category.present ? data.category.value : this.category,
      method: data.method.present ? data.method.value : this.method,
      date: data.date.present ? data.date.value : this.date,
      docMonth: data.docMonth.present ? data.docMonth.value : this.docMonth,
      forMonth: data.forMonth.present ? data.forMonth.value : this.forMonth,
      paidBy: data.paidBy.present ? data.paidBy.value : this.paidBy,
      addedBy: data.addedBy.present ? data.addedBy.value : this.addedBy,
      source: data.source.present ? data.source.value : this.source,
      billId: data.billId.present ? data.billId.value : this.billId,
      orderChannel: data.orderChannel.present
          ? data.orderChannel.value
          : this.orderChannel,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      settlementAttemptId: data.settlementAttemptId.present
          ? data.settlementAttemptId.value
          : this.settlementAttemptId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('merchantKey: $merchantKey, ')
          ..write('category: $category, ')
          ..write('method: $method, ')
          ..write('date: $date, ')
          ..write('docMonth: $docMonth, ')
          ..write('forMonth: $forMonth, ')
          ..write('paidBy: $paidBy, ')
          ..write('addedBy: $addedBy, ')
          ..write('source: $source, ')
          ..write('billId: $billId, ')
          ..write('orderChannel: $orderChannel, ')
          ..write('staffId: $staffId, ')
          ..write('settlementAttemptId: $settlementAttemptId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    homeId,
    deleted,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    amountPaise,
    merchant,
    merchantKey,
    category,
    method,
    date,
    docMonth,
    forMonth,
    paidBy,
    addedBy,
    source,
    billId,
    orderChannel,
    staffId,
    settlementAttemptId,
    note,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.amountPaise == this.amountPaise &&
          other.merchant == this.merchant &&
          other.merchantKey == this.merchantKey &&
          other.category == this.category &&
          other.method == this.method &&
          other.date == this.date &&
          other.docMonth == this.docMonth &&
          other.forMonth == this.forMonth &&
          other.paidBy == this.paidBy &&
          other.addedBy == this.addedBy &&
          other.source == this.source &&
          other.billId == this.billId &&
          other.orderChannel == this.orderChannel &&
          other.staffId == this.staffId &&
          other.settlementAttemptId == this.settlementAttemptId &&
          other.note == this.note);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<int> amountPaise;
  final Value<String> merchant;
  final Value<String> merchantKey;
  final Value<String> category;
  final Value<String> method;
  final Value<String> date;
  final Value<String> docMonth;
  final Value<String?> forMonth;
  final Value<String> paidBy;
  final Value<String> addedBy;
  final Value<String> source;
  final Value<String?> billId;
  final Value<String?> orderChannel;
  final Value<String?> staffId;
  final Value<String?> settlementAttemptId;
  final Value<String?> note;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.merchant = const Value.absent(),
    this.merchantKey = const Value.absent(),
    this.category = const Value.absent(),
    this.method = const Value.absent(),
    this.date = const Value.absent(),
    this.docMonth = const Value.absent(),
    this.forMonth = const Value.absent(),
    this.paidBy = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.source = const Value.absent(),
    this.billId = const Value.absent(),
    this.orderChannel = const Value.absent(),
    this.staffId = const Value.absent(),
    this.settlementAttemptId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.merchant = const Value.absent(),
    this.merchantKey = const Value.absent(),
    this.category = const Value.absent(),
    this.method = const Value.absent(),
    this.date = const Value.absent(),
    this.docMonth = const Value.absent(),
    this.forMonth = const Value.absent(),
    this.paidBy = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.source = const Value.absent(),
    this.billId = const Value.absent(),
    this.orderChannel = const Value.absent(),
    this.staffId = const Value.absent(),
    this.settlementAttemptId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? amountPaise,
    Expression<String>? merchant,
    Expression<String>? merchantKey,
    Expression<String>? category,
    Expression<String>? method,
    Expression<String>? date,
    Expression<String>? docMonth,
    Expression<String>? forMonth,
    Expression<String>? paidBy,
    Expression<String>? addedBy,
    Expression<String>? source,
    Expression<String>? billId,
    Expression<String>? orderChannel,
    Expression<String>? staffId,
    Expression<String>? settlementAttemptId,
    Expression<String>? note,
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
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (merchant != null) 'merchant': merchant,
      if (merchantKey != null) 'merchant_key': merchantKey,
      if (category != null) 'category': category,
      if (method != null) 'method': method,
      if (date != null) 'date': date,
      if (docMonth != null) 'doc_month': docMonth,
      if (forMonth != null) 'for_month': forMonth,
      if (paidBy != null) 'paid_by': paidBy,
      if (addedBy != null) 'added_by': addedBy,
      if (source != null) 'source': source,
      if (billId != null) 'bill_id': billId,
      if (orderChannel != null) 'order_channel': orderChannel,
      if (staffId != null) 'staff_id': staffId,
      if (settlementAttemptId != null)
        'settlement_attempt_id': settlementAttemptId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<int>? amountPaise,
    Value<String>? merchant,
    Value<String>? merchantKey,
    Value<String>? category,
    Value<String>? method,
    Value<String>? date,
    Value<String>? docMonth,
    Value<String?>? forMonth,
    Value<String>? paidBy,
    Value<String>? addedBy,
    Value<String>? source,
    Value<String?>? billId,
    Value<String?>? orderChannel,
    Value<String?>? staffId,
    Value<String?>? settlementAttemptId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      amountPaise: amountPaise ?? this.amountPaise,
      merchant: merchant ?? this.merchant,
      merchantKey: merchantKey ?? this.merchantKey,
      category: category ?? this.category,
      method: method ?? this.method,
      date: date ?? this.date,
      docMonth: docMonth ?? this.docMonth,
      forMonth: forMonth ?? this.forMonth,
      paidBy: paidBy ?? this.paidBy,
      addedBy: addedBy ?? this.addedBy,
      source: source ?? this.source,
      billId: billId ?? this.billId,
      orderChannel: orderChannel ?? this.orderChannel,
      staffId: staffId ?? this.staffId,
      settlementAttemptId: settlementAttemptId ?? this.settlementAttemptId,
      note: note ?? this.note,
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
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (merchantKey.present) {
      map['merchant_key'] = Variable<String>(merchantKey.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (docMonth.present) {
      map['doc_month'] = Variable<String>(docMonth.value);
    }
    if (forMonth.present) {
      map['for_month'] = Variable<String>(forMonth.value);
    }
    if (paidBy.present) {
      map['paid_by'] = Variable<String>(paidBy.value);
    }
    if (addedBy.present) {
      map['added_by'] = Variable<String>(addedBy.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (orderChannel.present) {
      map['order_channel'] = Variable<String>(orderChannel.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (settlementAttemptId.present) {
      map['settlement_attempt_id'] = Variable<String>(
        settlementAttemptId.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('merchant: $merchant, ')
          ..write('merchantKey: $merchantKey, ')
          ..write('category: $category, ')
          ..write('method: $method, ')
          ..write('date: $date, ')
          ..write('docMonth: $docMonth, ')
          ..write('forMonth: $forMonth, ')
          ..write('paidBy: $paidBy, ')
          ..write('addedBy: $addedBy, ')
          ..write('source: $source, ')
          ..write('billId: $billId, ')
          ..write('orderChannel: $orderChannel, ')
          ..write('staffId: $staffId, ')
          ..write('settlementAttemptId: $settlementAttemptId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _listMeta = const VerificationMeta('list');
  @override
  late final GeneratedColumn<String> list = GeneratedColumn<String>(
    'list',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('grocery'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _qtyMilliMeta = const VerificationMeta(
    'qtyMilli',
  );
  @override
  late final GeneratedColumn<int> qtyMilli = GeneratedColumn<int>(
    'qty_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('zepto'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Other'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<int> doneAt = GeneratedColumn<int>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneByMeta = const VerificationMeta('doneBy');
  @override
  late final GeneratedColumn<String> doneBy = GeneratedColumn<String>(
    'done_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
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
    list,
    name,
    nameKey,
    qtyMilli,
    unit,
    channel,
    category,
    note,
    done,
    doneAt,
    doneBy,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
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
    if (data.containsKey('list')) {
      context.handle(
        _listMeta,
        list.isAcceptableOrUnknown(data['list']!, _listMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    }
    if (data.containsKey('qty_milli')) {
      context.handle(
        _qtyMilliMeta,
        qtyMilli.isAcceptableOrUnknown(data['qty_milli']!, _qtyMilliMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('done_by')) {
      context.handle(
        _doneByMeta,
        doneBy.isAcceptableOrUnknown(data['done_by']!, _doneByMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
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
      list: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      qtyMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_milli'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_at'],
      ),
      doneBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_by'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String list;
  final String name;
  final String nameKey;
  final int qtyMilli;
  final String unit;
  final String channel;
  final String category;
  final String? note;
  final bool done;
  final int? doneAt;
  final String? doneBy;
  final String source;
  const ItemRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.list,
    required this.name,
    required this.nameKey,
    required this.qtyMilli,
    required this.unit,
    required this.channel,
    required this.category,
    this.note,
    required this.done,
    this.doneAt,
    this.doneBy,
    required this.source,
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
    map['list'] = Variable<String>(list);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    map['qty_milli'] = Variable<int>(qtyMilli);
    map['unit'] = Variable<String>(unit);
    map['channel'] = Variable<String>(channel);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<int>(doneAt);
    }
    if (!nullToAbsent || doneBy != null) {
      map['done_by'] = Variable<String>(doneBy);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      list: Value(list),
      name: Value(name),
      nameKey: Value(nameKey),
      qtyMilli: Value(qtyMilli),
      unit: Value(unit),
      channel: Value(channel),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      done: Value(done),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      doneBy: doneBy == null && nullToAbsent
          ? const Value.absent()
          : Value(doneBy),
      source: Value(source),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      list: serializer.fromJson<String>(json['list']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      qtyMilli: serializer.fromJson<int>(json['qtyMilli']),
      unit: serializer.fromJson<String>(json['unit']),
      channel: serializer.fromJson<String>(json['channel']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      done: serializer.fromJson<bool>(json['done']),
      doneAt: serializer.fromJson<int?>(json['doneAt']),
      doneBy: serializer.fromJson<String?>(json['doneBy']),
      source: serializer.fromJson<String>(json['source']),
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
      'list': serializer.toJson<String>(list),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'qtyMilli': serializer.toJson<int>(qtyMilli),
      'unit': serializer.toJson<String>(unit),
      'channel': serializer.toJson<String>(channel),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String?>(note),
      'done': serializer.toJson<bool>(done),
      'doneAt': serializer.toJson<int?>(doneAt),
      'doneBy': serializer.toJson<String?>(doneBy),
      'source': serializer.toJson<String>(source),
    };
  }

  ItemRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    String? list,
    String? name,
    String? nameKey,
    int? qtyMilli,
    String? unit,
    String? channel,
    String? category,
    Value<String?> note = const Value.absent(),
    bool? done,
    Value<int?> doneAt = const Value.absent(),
    Value<String?> doneBy = const Value.absent(),
    String? source,
  }) => ItemRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    list: list ?? this.list,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    unit: unit ?? this.unit,
    channel: channel ?? this.channel,
    category: category ?? this.category,
    note: note.present ? note.value : this.note,
    done: done ?? this.done,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    doneBy: doneBy.present ? doneBy.value : this.doneBy,
    source: source ?? this.source,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      list: data.list.present ? data.list.value : this.list,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      qtyMilli: data.qtyMilli.present ? data.qtyMilli.value : this.qtyMilli,
      unit: data.unit.present ? data.unit.value : this.unit,
      channel: data.channel.present ? data.channel.value : this.channel,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      done: data.done.present ? data.done.value : this.done,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      doneBy: data.doneBy.present ? data.doneBy.value : this.doneBy,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('list: $list, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unit: $unit, ')
          ..write('channel: $channel, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('doneBy: $doneBy, ')
          ..write('source: $source')
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
    list,
    name,
    nameKey,
    qtyMilli,
    unit,
    channel,
    category,
    note,
    done,
    doneAt,
    doneBy,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.list == this.list &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.qtyMilli == this.qtyMilli &&
          other.unit == this.unit &&
          other.channel == this.channel &&
          other.category == this.category &&
          other.note == this.note &&
          other.done == this.done &&
          other.doneAt == this.doneAt &&
          other.doneBy == this.doneBy &&
          other.source == this.source);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String> list;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<int> qtyMilli;
  final Value<String> unit;
  final Value<String> channel;
  final Value<String> category;
  final Value<String?> note;
  final Value<bool> done;
  final Value<int?> doneAt;
  final Value<String?> doneBy;
  final Value<String> source;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.list = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.qtyMilli = const Value.absent(),
    this.unit = const Value.absent(),
    this.channel = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.doneBy = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.list = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.qtyMilli = const Value.absent(),
    this.unit = const Value.absent(),
    this.channel = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.doneBy = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? list,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<int>? qtyMilli,
    Expression<String>? unit,
    Expression<String>? channel,
    Expression<String>? category,
    Expression<String>? note,
    Expression<bool>? done,
    Expression<int>? doneAt,
    Expression<String>? doneBy,
    Expression<String>? source,
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
      if (list != null) 'list': list,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (qtyMilli != null) 'qty_milli': qtyMilli,
      if (unit != null) 'unit': unit,
      if (channel != null) 'channel': channel,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (done != null) 'done': done,
      if (doneAt != null) 'done_at': doneAt,
      if (doneBy != null) 'done_by': doneBy,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String>? list,
    Value<String>? name,
    Value<String>? nameKey,
    Value<int>? qtyMilli,
    Value<String>? unit,
    Value<String>? channel,
    Value<String>? category,
    Value<String?>? note,
    Value<bool>? done,
    Value<int?>? doneAt,
    Value<String?>? doneBy,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      list: list ?? this.list,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      qtyMilli: qtyMilli ?? this.qtyMilli,
      unit: unit ?? this.unit,
      channel: channel ?? this.channel,
      category: category ?? this.category,
      note: note ?? this.note,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      doneBy: doneBy ?? this.doneBy,
      source: source ?? this.source,
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
    if (list.present) {
      map['list'] = Variable<String>(list.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (qtyMilli.present) {
      map['qty_milli'] = Variable<int>(qtyMilli.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<int>(doneAt.value);
    }
    if (doneBy.present) {
      map['done_by'] = Variable<String>(doneBy.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('list: $list, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unit: $unit, ')
          ..write('channel: $channel, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('doneBy: $doneBy, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemHistoryTable extends ItemHistory
    with TableInfo<$ItemHistoryTable, ItemHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _listMeta = const VerificationMeta('list');
  @override
  late final GeneratedColumn<String> list = GeneratedColumn<String>(
    'list',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('grocery'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usualChannelMeta = const VerificationMeta(
    'usualChannel',
  );
  @override
  late final GeneratedColumn<String> usualChannel = GeneratedColumn<String>(
    'usual_channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastBoughtAtMeta = const VerificationMeta(
    'lastBoughtAt',
  );
  @override
  late final GeneratedColumn<int> lastBoughtAt = GeneratedColumn<int>(
    'last_bought_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesBoughtMeta = const VerificationMeta(
    'timesBought',
  );
  @override
  late final GeneratedColumn<int> timesBought = GeneratedColumn<int>(
    'times_bought',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastQtyMilliMeta = const VerificationMeta(
    'lastQtyMilli',
  );
  @override
  late final GeneratedColumn<int> lastQtyMilli = GeneratedColumn<int>(
    'last_qty_milli',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUnitMeta = const VerificationMeta(
    'lastUnit',
  );
  @override
  late final GeneratedColumn<String> lastUnit = GeneratedColumn<String>(
    'last_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    list,
    name,
    nameKey,
    usualChannel,
    lastBoughtAt,
    timesBought,
    lastQtyMilli,
    lastUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemHistoryRow> instance, {
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
    if (data.containsKey('list')) {
      context.handle(
        _listMeta,
        list.isAcceptableOrUnknown(data['list']!, _listMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    }
    if (data.containsKey('usual_channel')) {
      context.handle(
        _usualChannelMeta,
        usualChannel.isAcceptableOrUnknown(
          data['usual_channel']!,
          _usualChannelMeta,
        ),
      );
    }
    if (data.containsKey('last_bought_at')) {
      context.handle(
        _lastBoughtAtMeta,
        lastBoughtAt.isAcceptableOrUnknown(
          data['last_bought_at']!,
          _lastBoughtAtMeta,
        ),
      );
    }
    if (data.containsKey('times_bought')) {
      context.handle(
        _timesBoughtMeta,
        timesBought.isAcceptableOrUnknown(
          data['times_bought']!,
          _timesBoughtMeta,
        ),
      );
    }
    if (data.containsKey('last_qty_milli')) {
      context.handle(
        _lastQtyMilliMeta,
        lastQtyMilli.isAcceptableOrUnknown(
          data['last_qty_milli']!,
          _lastQtyMilliMeta,
        ),
      );
    }
    if (data.containsKey('last_unit')) {
      context.handle(
        _lastUnitMeta,
        lastUnit.isAcceptableOrUnknown(data['last_unit']!, _lastUnitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemHistoryRow(
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
      list: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      usualChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usual_channel'],
      ),
      lastBoughtAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_bought_at'],
      ),
      timesBought: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_bought'],
      )!,
      lastQtyMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_qty_milli'],
      ),
      lastUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_unit'],
      ),
    );
  }

  @override
  $ItemHistoryTable createAlias(String alias) {
    return $ItemHistoryTable(attachedDatabase, alias);
  }
}

class ItemHistoryRow extends DataClass implements Insertable<ItemHistoryRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String list;
  final String name;
  final String nameKey;
  final String? usualChannel;
  final int? lastBoughtAt;
  final int timesBought;
  final int? lastQtyMilli;
  final String? lastUnit;
  const ItemHistoryRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.list,
    required this.name,
    required this.nameKey,
    this.usualChannel,
    this.lastBoughtAt,
    required this.timesBought,
    this.lastQtyMilli,
    this.lastUnit,
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
    map['list'] = Variable<String>(list);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    if (!nullToAbsent || usualChannel != null) {
      map['usual_channel'] = Variable<String>(usualChannel);
    }
    if (!nullToAbsent || lastBoughtAt != null) {
      map['last_bought_at'] = Variable<int>(lastBoughtAt);
    }
    map['times_bought'] = Variable<int>(timesBought);
    if (!nullToAbsent || lastQtyMilli != null) {
      map['last_qty_milli'] = Variable<int>(lastQtyMilli);
    }
    if (!nullToAbsent || lastUnit != null) {
      map['last_unit'] = Variable<String>(lastUnit);
    }
    return map;
  }

  ItemHistoryCompanion toCompanion(bool nullToAbsent) {
    return ItemHistoryCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      list: Value(list),
      name: Value(name),
      nameKey: Value(nameKey),
      usualChannel: usualChannel == null && nullToAbsent
          ? const Value.absent()
          : Value(usualChannel),
      lastBoughtAt: lastBoughtAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBoughtAt),
      timesBought: Value(timesBought),
      lastQtyMilli: lastQtyMilli == null && nullToAbsent
          ? const Value.absent()
          : Value(lastQtyMilli),
      lastUnit: lastUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUnit),
    );
  }

  factory ItemHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      list: serializer.fromJson<String>(json['list']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      usualChannel: serializer.fromJson<String?>(json['usualChannel']),
      lastBoughtAt: serializer.fromJson<int?>(json['lastBoughtAt']),
      timesBought: serializer.fromJson<int>(json['timesBought']),
      lastQtyMilli: serializer.fromJson<int?>(json['lastQtyMilli']),
      lastUnit: serializer.fromJson<String?>(json['lastUnit']),
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
      'list': serializer.toJson<String>(list),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'usualChannel': serializer.toJson<String?>(usualChannel),
      'lastBoughtAt': serializer.toJson<int?>(lastBoughtAt),
      'timesBought': serializer.toJson<int>(timesBought),
      'lastQtyMilli': serializer.toJson<int?>(lastQtyMilli),
      'lastUnit': serializer.toJson<String?>(lastUnit),
    };
  }

  ItemHistoryRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    String? list,
    String? name,
    String? nameKey,
    Value<String?> usualChannel = const Value.absent(),
    Value<int?> lastBoughtAt = const Value.absent(),
    int? timesBought,
    Value<int?> lastQtyMilli = const Value.absent(),
    Value<String?> lastUnit = const Value.absent(),
  }) => ItemHistoryRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    list: list ?? this.list,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    usualChannel: usualChannel.present ? usualChannel.value : this.usualChannel,
    lastBoughtAt: lastBoughtAt.present ? lastBoughtAt.value : this.lastBoughtAt,
    timesBought: timesBought ?? this.timesBought,
    lastQtyMilli: lastQtyMilli.present ? lastQtyMilli.value : this.lastQtyMilli,
    lastUnit: lastUnit.present ? lastUnit.value : this.lastUnit,
  );
  ItemHistoryRow copyWithCompanion(ItemHistoryCompanion data) {
    return ItemHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      list: data.list.present ? data.list.value : this.list,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      usualChannel: data.usualChannel.present
          ? data.usualChannel.value
          : this.usualChannel,
      lastBoughtAt: data.lastBoughtAt.present
          ? data.lastBoughtAt.value
          : this.lastBoughtAt,
      timesBought: data.timesBought.present
          ? data.timesBought.value
          : this.timesBought,
      lastQtyMilli: data.lastQtyMilli.present
          ? data.lastQtyMilli.value
          : this.lastQtyMilli,
      lastUnit: data.lastUnit.present ? data.lastUnit.value : this.lastUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemHistoryRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('list: $list, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('usualChannel: $usualChannel, ')
          ..write('lastBoughtAt: $lastBoughtAt, ')
          ..write('timesBought: $timesBought, ')
          ..write('lastQtyMilli: $lastQtyMilli, ')
          ..write('lastUnit: $lastUnit')
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
    list,
    name,
    nameKey,
    usualChannel,
    lastBoughtAt,
    timesBought,
    lastQtyMilli,
    lastUnit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemHistoryRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.list == this.list &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.usualChannel == this.usualChannel &&
          other.lastBoughtAt == this.lastBoughtAt &&
          other.timesBought == this.timesBought &&
          other.lastQtyMilli == this.lastQtyMilli &&
          other.lastUnit == this.lastUnit);
}

class ItemHistoryCompanion extends UpdateCompanion<ItemHistoryRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String> list;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<String?> usualChannel;
  final Value<int?> lastBoughtAt;
  final Value<int> timesBought;
  final Value<int?> lastQtyMilli;
  final Value<String?> lastUnit;
  final Value<int> rowid;
  const ItemHistoryCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.list = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.usualChannel = const Value.absent(),
    this.lastBoughtAt = const Value.absent(),
    this.timesBought = const Value.absent(),
    this.lastQtyMilli = const Value.absent(),
    this.lastUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemHistoryCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.list = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.usualChannel = const Value.absent(),
    this.lastBoughtAt = const Value.absent(),
    this.timesBought = const Value.absent(),
    this.lastQtyMilli = const Value.absent(),
    this.lastUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<ItemHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? list,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<String>? usualChannel,
    Expression<int>? lastBoughtAt,
    Expression<int>? timesBought,
    Expression<int>? lastQtyMilli,
    Expression<String>? lastUnit,
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
      if (list != null) 'list': list,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (usualChannel != null) 'usual_channel': usualChannel,
      if (lastBoughtAt != null) 'last_bought_at': lastBoughtAt,
      if (timesBought != null) 'times_bought': timesBought,
      if (lastQtyMilli != null) 'last_qty_milli': lastQtyMilli,
      if (lastUnit != null) 'last_unit': lastUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String>? list,
    Value<String>? name,
    Value<String>? nameKey,
    Value<String?>? usualChannel,
    Value<int?>? lastBoughtAt,
    Value<int>? timesBought,
    Value<int?>? lastQtyMilli,
    Value<String?>? lastUnit,
    Value<int>? rowid,
  }) {
    return ItemHistoryCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      list: list ?? this.list,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      usualChannel: usualChannel ?? this.usualChannel,
      lastBoughtAt: lastBoughtAt ?? this.lastBoughtAt,
      timesBought: timesBought ?? this.timesBought,
      lastQtyMilli: lastQtyMilli ?? this.lastQtyMilli,
      lastUnit: lastUnit ?? this.lastUnit,
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
    if (list.present) {
      map['list'] = Variable<String>(list.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (usualChannel.present) {
      map['usual_channel'] = Variable<String>(usualChannel.value);
    }
    if (lastBoughtAt.present) {
      map['last_bought_at'] = Variable<int>(lastBoughtAt.value);
    }
    if (timesBought.present) {
      map['times_bought'] = Variable<int>(timesBought.value);
    }
    if (lastQtyMilli.present) {
      map['last_qty_milli'] = Variable<int>(lastQtyMilli.value);
    }
    if (lastUnit.present) {
      map['last_unit'] = Variable<String>(lastUnit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemHistoryCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('list: $list, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('usualChannel: $usualChannel, ')
          ..write('lastBoughtAt: $lastBoughtAt, ')
          ..write('timesBought: $timesBought, ')
          ..write('lastQtyMilli: $lastQtyMilli, ')
          ..write('lastUnit: $lastUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Kitchen'),
  );
  static const VerificationMeta _everyDaysMeta = const VerificationMeta(
    'everyDays',
  );
  @override
  late final GeneratedColumn<int> everyDays = GeneratedColumn<int>(
    'every_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _assigneeTypeMeta = const VerificationMeta(
    'assigneeType',
  );
  @override
  late final GeneratedColumn<String> assigneeType = GeneratedColumn<String>(
    'assignee_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _assigneeMeta = const VerificationMeta(
    'assignee',
  );
  @override
  late final GeneratedColumn<String> assignee = GeneratedColumn<String>(
    'assignee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastDoneMeta = const VerificationMeta(
    'lastDone',
  );
  @override
  late final GeneratedColumn<String> lastDone = GeneratedColumn<String>(
    'last_done',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastDoneByMeta = const VerificationMeta(
    'lastDoneBy',
  );
  @override
  late final GeneratedColumn<String> lastDoneBy = GeneratedColumn<String>(
    'last_done_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    name,
    room,
    everyDays,
    assigneeType,
    assignee,
    lastDone,
    lastDoneBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    if (data.containsKey('every_days')) {
      context.handle(
        _everyDaysMeta,
        everyDays.isAcceptableOrUnknown(data['every_days']!, _everyDaysMeta),
      );
    }
    if (data.containsKey('assignee_type')) {
      context.handle(
        _assigneeTypeMeta,
        assigneeType.isAcceptableOrUnknown(
          data['assignee_type']!,
          _assigneeTypeMeta,
        ),
      );
    }
    if (data.containsKey('assignee')) {
      context.handle(
        _assigneeMeta,
        assignee.isAcceptableOrUnknown(data['assignee']!, _assigneeMeta),
      );
    }
    if (data.containsKey('last_done')) {
      context.handle(
        _lastDoneMeta,
        lastDone.isAcceptableOrUnknown(data['last_done']!, _lastDoneMeta),
      );
    }
    if (data.containsKey('last_done_by')) {
      context.handle(
        _lastDoneByMeta,
        lastDoneBy.isAcceptableOrUnknown(
          data['last_done_by']!,
          _lastDoneByMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
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
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      )!,
      everyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}every_days'],
      )!,
      assigneeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee_type'],
      )!,
      assignee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee'],
      )!,
      lastDone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_done'],
      )!,
      lastDoneBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_done_by'],
      ),
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String name;
  final String room;
  final int everyDays;
  final String assigneeType;
  final String assignee;
  final String lastDone;
  final String? lastDoneBy;
  const RoutineRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.name,
    required this.room,
    required this.everyDays,
    required this.assigneeType,
    required this.assignee,
    required this.lastDone,
    this.lastDoneBy,
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
    map['name'] = Variable<String>(name);
    map['room'] = Variable<String>(room);
    map['every_days'] = Variable<int>(everyDays);
    map['assignee_type'] = Variable<String>(assigneeType);
    map['assignee'] = Variable<String>(assignee);
    map['last_done'] = Variable<String>(lastDone);
    if (!nullToAbsent || lastDoneBy != null) {
      map['last_done_by'] = Variable<String>(lastDoneBy);
    }
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      name: Value(name),
      room: Value(room),
      everyDays: Value(everyDays),
      assigneeType: Value(assigneeType),
      assignee: Value(assignee),
      lastDone: Value(lastDone),
      lastDoneBy: lastDoneBy == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDoneBy),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      name: serializer.fromJson<String>(json['name']),
      room: serializer.fromJson<String>(json['room']),
      everyDays: serializer.fromJson<int>(json['everyDays']),
      assigneeType: serializer.fromJson<String>(json['assigneeType']),
      assignee: serializer.fromJson<String>(json['assignee']),
      lastDone: serializer.fromJson<String>(json['lastDone']),
      lastDoneBy: serializer.fromJson<String?>(json['lastDoneBy']),
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
      'name': serializer.toJson<String>(name),
      'room': serializer.toJson<String>(room),
      'everyDays': serializer.toJson<int>(everyDays),
      'assigneeType': serializer.toJson<String>(assigneeType),
      'assignee': serializer.toJson<String>(assignee),
      'lastDone': serializer.toJson<String>(lastDone),
      'lastDoneBy': serializer.toJson<String?>(lastDoneBy),
    };
  }

  RoutineRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    String? name,
    String? room,
    int? everyDays,
    String? assigneeType,
    String? assignee,
    String? lastDone,
    Value<String?> lastDoneBy = const Value.absent(),
  }) => RoutineRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    name: name ?? this.name,
    room: room ?? this.room,
    everyDays: everyDays ?? this.everyDays,
    assigneeType: assigneeType ?? this.assigneeType,
    assignee: assignee ?? this.assignee,
    lastDone: lastDone ?? this.lastDone,
    lastDoneBy: lastDoneBy.present ? lastDoneBy.value : this.lastDoneBy,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      name: data.name.present ? data.name.value : this.name,
      room: data.room.present ? data.room.value : this.room,
      everyDays: data.everyDays.present ? data.everyDays.value : this.everyDays,
      assigneeType: data.assigneeType.present
          ? data.assigneeType.value
          : this.assigneeType,
      assignee: data.assignee.present ? data.assignee.value : this.assignee,
      lastDone: data.lastDone.present ? data.lastDone.value : this.lastDone,
      lastDoneBy: data.lastDoneBy.present
          ? data.lastDoneBy.value
          : this.lastDoneBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('room: $room, ')
          ..write('everyDays: $everyDays, ')
          ..write('assigneeType: $assigneeType, ')
          ..write('assignee: $assignee, ')
          ..write('lastDone: $lastDone, ')
          ..write('lastDoneBy: $lastDoneBy')
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
    name,
    room,
    everyDays,
    assigneeType,
    assignee,
    lastDone,
    lastDoneBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.name == this.name &&
          other.room == this.room &&
          other.everyDays == this.everyDays &&
          other.assigneeType == this.assigneeType &&
          other.assignee == this.assignee &&
          other.lastDone == this.lastDone &&
          other.lastDoneBy == this.lastDoneBy);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String> name;
  final Value<String> room;
  final Value<int> everyDays;
  final Value<String> assigneeType;
  final Value<String> assignee;
  final Value<String> lastDone;
  final Value<String?> lastDoneBy;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.room = const Value.absent(),
    this.everyDays = const Value.absent(),
    this.assigneeType = const Value.absent(),
    this.assignee = const Value.absent(),
    this.lastDone = const Value.absent(),
    this.lastDoneBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.name = const Value.absent(),
    this.room = const Value.absent(),
    this.everyDays = const Value.absent(),
    this.assigneeType = const Value.absent(),
    this.assignee = const Value.absent(),
    this.lastDone = const Value.absent(),
    this.lastDoneBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? name,
    Expression<String>? room,
    Expression<int>? everyDays,
    Expression<String>? assigneeType,
    Expression<String>? assignee,
    Expression<String>? lastDone,
    Expression<String>? lastDoneBy,
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
      if (name != null) 'name': name,
      if (room != null) 'room': room,
      if (everyDays != null) 'every_days': everyDays,
      if (assigneeType != null) 'assignee_type': assigneeType,
      if (assignee != null) 'assignee': assignee,
      if (lastDone != null) 'last_done': lastDone,
      if (lastDoneBy != null) 'last_done_by': lastDoneBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String>? name,
    Value<String>? room,
    Value<int>? everyDays,
    Value<String>? assigneeType,
    Value<String>? assignee,
    Value<String>? lastDone,
    Value<String?>? lastDoneBy,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      name: name ?? this.name,
      room: room ?? this.room,
      everyDays: everyDays ?? this.everyDays,
      assigneeType: assigneeType ?? this.assigneeType,
      assignee: assignee ?? this.assignee,
      lastDone: lastDone ?? this.lastDone,
      lastDoneBy: lastDoneBy ?? this.lastDoneBy,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (everyDays.present) {
      map['every_days'] = Variable<int>(everyDays.value);
    }
    if (assigneeType.present) {
      map['assignee_type'] = Variable<String>(assigneeType.value);
    }
    if (assignee.present) {
      map['assignee'] = Variable<String>(assignee.value);
    }
    if (lastDone.present) {
      map['last_done'] = Variable<String>(lastDone.value);
    }
    if (lastDoneBy.present) {
      map['last_done_by'] = Variable<String>(lastDoneBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('name: $name, ')
          ..write('room: $room, ')
          ..write('everyDays: $everyDays, ')
          ..write('assigneeType: $assigneeType, ')
          ..write('assignee: $assignee, ')
          ..write('lastDone: $lastDone, ')
          ..write('lastDoneBy: $lastDoneBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with TableInfo<$TodosTable, TodoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<String> due = GeneratedColumn<String>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _assigneeTypeMeta = const VerificationMeta(
    'assigneeType',
  );
  @override
  late final GeneratedColumn<String> assigneeType = GeneratedColumn<String>(
    'assignee_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
  );
  static const VerificationMeta _assigneeMeta = const VerificationMeta(
    'assignee',
  );
  @override
  late final GeneratedColumn<String> assignee = GeneratedColumn<String>(
    'assignee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<int> doneAt = GeneratedColumn<int>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneByMeta = const VerificationMeta('doneBy');
  @override
  late final GeneratedColumn<String> doneBy = GeneratedColumn<String>(
    'done_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    due,
    assigneeType,
    assignee,
    done,
    doneAt,
    doneBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoRow> instance, {
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
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    }
    if (data.containsKey('assignee_type')) {
      context.handle(
        _assigneeTypeMeta,
        assigneeType.isAcceptableOrUnknown(
          data['assignee_type']!,
          _assigneeTypeMeta,
        ),
      );
    }
    if (data.containsKey('assignee')) {
      context.handle(
        _assigneeMeta,
        assignee.isAcceptableOrUnknown(data['assignee']!, _assigneeMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('done_by')) {
      context.handle(
        _doneByMeta,
        doneBy.isAcceptableOrUnknown(data['done_by']!, _doneByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoRow(
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
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due'],
      )!,
      assigneeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee_type'],
      )!,
      assignee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_at'],
      ),
      doneBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_by'],
      ),
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class TodoRow extends DataClass implements Insertable<TodoRow> {
  final String id;
  final String homeId;
  final bool deleted;
  final int createdAt;
  final String createdBy;
  final int updatedAt;
  final String updatedBy;
  final String title;
  final String due;
  final String assigneeType;
  final String assignee;
  final bool done;
  final int? doneAt;
  final String? doneBy;
  const TodoRow({
    required this.id,
    required this.homeId,
    required this.deleted,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.title,
    required this.due,
    required this.assigneeType,
    required this.assignee,
    required this.done,
    this.doneAt,
    this.doneBy,
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
    map['title'] = Variable<String>(title);
    map['due'] = Variable<String>(due);
    map['assignee_type'] = Variable<String>(assigneeType);
    map['assignee'] = Variable<String>(assignee);
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<int>(doneAt);
    }
    if (!nullToAbsent || doneBy != null) {
      map['done_by'] = Variable<String>(doneBy);
    }
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      homeId: Value(homeId),
      deleted: Value(deleted),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
      updatedAt: Value(updatedAt),
      updatedBy: Value(updatedBy),
      title: Value(title),
      due: Value(due),
      assigneeType: Value(assigneeType),
      assignee: Value(assignee),
      done: Value(done),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      doneBy: doneBy == null && nullToAbsent
          ? const Value.absent()
          : Value(doneBy),
    );
  }

  factory TodoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoRow(
      id: serializer.fromJson<String>(json['id']),
      homeId: serializer.fromJson<String>(json['homeId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      title: serializer.fromJson<String>(json['title']),
      due: serializer.fromJson<String>(json['due']),
      assigneeType: serializer.fromJson<String>(json['assigneeType']),
      assignee: serializer.fromJson<String>(json['assignee']),
      done: serializer.fromJson<bool>(json['done']),
      doneAt: serializer.fromJson<int?>(json['doneAt']),
      doneBy: serializer.fromJson<String?>(json['doneBy']),
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
      'title': serializer.toJson<String>(title),
      'due': serializer.toJson<String>(due),
      'assigneeType': serializer.toJson<String>(assigneeType),
      'assignee': serializer.toJson<String>(assignee),
      'done': serializer.toJson<bool>(done),
      'doneAt': serializer.toJson<int?>(doneAt),
      'doneBy': serializer.toJson<String?>(doneBy),
    };
  }

  TodoRow copyWith({
    String? id,
    String? homeId,
    bool? deleted,
    int? createdAt,
    String? createdBy,
    int? updatedAt,
    String? updatedBy,
    String? title,
    String? due,
    String? assigneeType,
    String? assignee,
    bool? done,
    Value<int?> doneAt = const Value.absent(),
    Value<String?> doneBy = const Value.absent(),
  }) => TodoRow(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deleted: deleted ?? this.deleted,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy ?? this.updatedBy,
    title: title ?? this.title,
    due: due ?? this.due,
    assigneeType: assigneeType ?? this.assigneeType,
    assignee: assignee ?? this.assignee,
    done: done ?? this.done,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    doneBy: doneBy.present ? doneBy.value : this.doneBy,
  );
  TodoRow copyWithCompanion(TodosCompanion data) {
    return TodoRow(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      title: data.title.present ? data.title.value : this.title,
      due: data.due.present ? data.due.value : this.due,
      assigneeType: data.assigneeType.present
          ? data.assigneeType.value
          : this.assigneeType,
      assignee: data.assignee.present ? data.assignee.value : this.assignee,
      done: data.done.present ? data.done.value : this.done,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      doneBy: data.doneBy.present ? data.doneBy.value : this.doneBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoRow(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('title: $title, ')
          ..write('due: $due, ')
          ..write('assigneeType: $assigneeType, ')
          ..write('assignee: $assignee, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('doneBy: $doneBy')
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
    due,
    assigneeType,
    assignee,
    done,
    doneAt,
    doneBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoRow &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deleted == this.deleted &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.title == this.title &&
          other.due == this.due &&
          other.assigneeType == this.assigneeType &&
          other.assignee == this.assignee &&
          other.done == this.done &&
          other.doneAt == this.doneAt &&
          other.doneBy == this.doneBy);
}

class TodosCompanion extends UpdateCompanion<TodoRow> {
  final Value<String> id;
  final Value<String> homeId;
  final Value<bool> deleted;
  final Value<int> createdAt;
  final Value<String> createdBy;
  final Value<int> updatedAt;
  final Value<String> updatedBy;
  final Value<String> title;
  final Value<String> due;
  final Value<String> assigneeType;
  final Value<String> assignee;
  final Value<bool> done;
  final Value<int?> doneAt;
  final Value<String?> doneBy;
  final Value<int> rowid;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.title = const Value.absent(),
    this.due = const Value.absent(),
    this.assigneeType = const Value.absent(),
    this.assignee = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.doneBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodosCompanion.insert({
    required String id,
    required String homeId,
    this.deleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.title = const Value.absent(),
    this.due = const Value.absent(),
    this.assigneeType = const Value.absent(),
    this.assignee = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.doneBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       homeId = Value(homeId);
  static Insertable<TodoRow> custom({
    Expression<String>? id,
    Expression<String>? homeId,
    Expression<bool>? deleted,
    Expression<int>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? title,
    Expression<String>? due,
    Expression<String>? assigneeType,
    Expression<String>? assignee,
    Expression<bool>? done,
    Expression<int>? doneAt,
    Expression<String>? doneBy,
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
      if (due != null) 'due': due,
      if (assigneeType != null) 'assignee_type': assigneeType,
      if (assignee != null) 'assignee': assignee,
      if (done != null) 'done': done,
      if (doneAt != null) 'done_at': doneAt,
      if (doneBy != null) 'done_by': doneBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodosCompanion copyWith({
    Value<String>? id,
    Value<String>? homeId,
    Value<bool>? deleted,
    Value<int>? createdAt,
    Value<String>? createdBy,
    Value<int>? updatedAt,
    Value<String>? updatedBy,
    Value<String>? title,
    Value<String>? due,
    Value<String>? assigneeType,
    Value<String>? assignee,
    Value<bool>? done,
    Value<int?>? doneAt,
    Value<String?>? doneBy,
    Value<int>? rowid,
  }) {
    return TodosCompanion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      title: title ?? this.title,
      due: due ?? this.due,
      assigneeType: assigneeType ?? this.assigneeType,
      assignee: assignee ?? this.assignee,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      doneBy: doneBy ?? this.doneBy,
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
    if (due.present) {
      map['due'] = Variable<String>(due.value);
    }
    if (assigneeType.present) {
      map['assignee_type'] = Variable<String>(assigneeType.value);
    }
    if (assignee.present) {
      map['assignee'] = Variable<String>(assignee.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<int>(doneAt.value);
    }
    if (doneBy.present) {
      map['done_by'] = Variable<String>(doneBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deleted: $deleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('title: $title, ')
          ..write('due: $due, ')
          ..write('assigneeType: $assigneeType, ')
          ..write('assignee: $assignee, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('doneBy: $doneBy, ')
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
  late final $HomesTable homes = $HomesTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $StaffTable staff = $StaffTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $LeavesTable leaves = $LeavesTable(this);
  late final $PayRulesTable payRules = $PayRulesTable(this);
  late final $PayAdjustmentsTable payAdjustments = $PayAdjustmentsTable(this);
  late final $SettlementAttemptsTable settlementAttempts =
      $SettlementAttemptsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $ItemHistoryTable itemHistory = $ItemHistoryTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $TodosTable todos = $TodosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ops,
    fieldClocks,
    devNotes,
    homes,
    members,
    staff,
    visits,
    leaves,
    payRules,
    payAdjustments,
    settlementAttempts,
    expenses,
    items,
    itemHistory,
    routines,
    todos,
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
typedef $$HomesTableCreateCompanionBuilder = HomesCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> name,
  Value<int?> budgetMonthlyPaise,
  Value<String?> vaultId,
  Value<String?> genesisJson,
  Value<String?> homeKeyId,
  Value<int> rowid,
});
typedef $$HomesTableUpdateCompanionBuilder = HomesCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> name,
  Value<int?> budgetMonthlyPaise,
  Value<String?> vaultId,
  Value<String?> genesisJson,
  Value<String?> homeKeyId,
  Value<int> rowid,
});

class $$HomesTableFilterComposer extends Composer<_$NestDatabase, $HomesTable> {
  $$HomesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetMonthlyPaise => $composableBuilder(
    column: $table.budgetMonthlyPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genesisJson => $composableBuilder(
    column: $table.genesisJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeKeyId => $composableBuilder(
    column: $table.homeKeyId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HomesTableOrderingComposer
    extends Composer<_$NestDatabase, $HomesTable> {
  $$HomesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetMonthlyPaise => $composableBuilder(
    column: $table.budgetMonthlyPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genesisJson => $composableBuilder(
    column: $table.genesisJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeKeyId => $composableBuilder(
    column: $table.homeKeyId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HomesTableAnnotationComposer
    extends Composer<_$NestDatabase, $HomesTable> {
  $$HomesTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get budgetMonthlyPaise => $composableBuilder(
    column: $table.budgetMonthlyPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumn<String> get genesisJson => $composableBuilder(
    column: $table.genesisJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeKeyId =>
      $composableBuilder(column: $table.homeKeyId, builder: (column) => column);
}

class $$HomesTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $HomesTable,
          Home,
          $$HomesTableFilterComposer,
          $$HomesTableOrderingComposer,
          $$HomesTableAnnotationComposer,
          $$HomesTableCreateCompanionBuilder,
          $$HomesTableUpdateCompanionBuilder,
          (Home, BaseReferences<_$NestDatabase, $HomesTable, Home>),
          Home,
          PrefetchHooks Function()
        > {
  $$HomesTableTableManager(_$NestDatabase db, $HomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> budgetMonthlyPaise = const Value.absent(),
                Value<String?> vaultId = const Value.absent(),
                Value<String?> genesisJson = const Value.absent(),
                Value<String?> homeKeyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HomesCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                name: name,
                budgetMonthlyPaise: budgetMonthlyPaise,
                vaultId: vaultId,
                genesisJson: genesisJson,
                homeKeyId: homeKeyId,
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
                Value<String?> name = const Value.absent(),
                Value<int?> budgetMonthlyPaise = const Value.absent(),
                Value<String?> vaultId = const Value.absent(),
                Value<String?> genesisJson = const Value.absent(),
                Value<String?> homeKeyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HomesCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                name: name,
                budgetMonthlyPaise: budgetMonthlyPaise,
                vaultId: vaultId,
                genesisJson: genesisJson,
                homeKeyId: homeKeyId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HomesTable, Home>(table),
                  BaseReferences<_$NestDatabase, $HomesTable, Home>(
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

typedef $$HomesTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $HomesTable,
      Home,
      $$HomesTableFilterComposer,
      $$HomesTableOrderingComposer,
      $$HomesTableAnnotationComposer,
      $$HomesTableCreateCompanionBuilder,
      $$HomesTableUpdateCompanionBuilder,
      (Home, BaseReferences<_$NestDatabase, $HomesTable, Home>),
      Home,
      PrefetchHooks Function()
    >;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> fullName,
  Value<String?> firstName,
  Value<String> role,
  Value<String> status,
  Value<String?> color,
  Value<String?> deviceModel,
  Value<int?> joinedAt,
  Value<String?> joinedVia,
  Value<String?> invitedBy,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> fullName,
  Value<String?> firstName,
  Value<String> role,
  Value<String> status,
  Value<String?> color,
  Value<String?> deviceModel,
  Value<int?> joinedAt,
  Value<String?> joinedVia,
  Value<String?> invitedBy,
  Value<int> rowid,
});

class $$MembersTableFilterComposer
    extends Composer<_$NestDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get joinedVia => $composableBuilder(
    column: $table.joinedVia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invitedBy => $composableBuilder(
    column: $table.invitedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableOrderingComposer
    extends Composer<_$NestDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get joinedVia => $composableBuilder(
    column: $table.joinedVia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invitedBy => $composableBuilder(
    column: $table.invitedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$NestDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
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

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<String> get joinedVia =>
      $composableBuilder(column: $table.joinedVia, builder: (column) => column);

  GeneratedColumn<String> get invitedBy =>
      $composableBuilder(column: $table.invitedBy, builder: (column) => column);
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $MembersTable,
          Member,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (Member, BaseReferences<_$NestDatabase, $MembersTable, Member>),
          Member,
          PrefetchHooks Function()
        > {
  $$MembersTableTableManager(_$NestDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<int?> joinedAt = const Value.absent(),
                Value<String?> joinedVia = const Value.absent(),
                Value<String?> invitedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                fullName: fullName,
                firstName: firstName,
                role: role,
                status: status,
                color: color,
                deviceModel: deviceModel,
                joinedAt: joinedAt,
                joinedVia: joinedVia,
                invitedBy: invitedBy,
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
                Value<String?> fullName = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<int?> joinedAt = const Value.absent(),
                Value<String?> joinedVia = const Value.absent(),
                Value<String?> invitedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                fullName: fullName,
                firstName: firstName,
                role: role,
                status: status,
                color: color,
                deviceModel: deviceModel,
                joinedAt: joinedAt,
                joinedVia: joinedVia,
                invitedBy: invitedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MembersTable, Member>(table),
                  BaseReferences<_$NestDatabase, $MembersTable, Member>(
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

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $MembersTable,
      Member,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (Member, BaseReferences<_$NestDatabase, $MembersTable, Member>),
      Member,
      PrefetchHooks Function()
    >;
typedef $$StaffTableCreateCompanionBuilder = StaffCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> name,
  Value<String?> role,
  Value<String?> phoneE164,
  Value<String?> upiId,
  Value<String?> color,
  Value<String> workDays,
  Value<String> expectedTimes,
  Value<String?> usualEndTime,
  Value<String?> startDate,
  Value<String?> endDate,
  Value<bool> active,
  Value<String?> initialPayType,
  Value<int?> initialPayPaise,
  Value<int> rowid,
});
typedef $$StaffTableUpdateCompanionBuilder = StaffCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> name,
  Value<String?> role,
  Value<String?> phoneE164,
  Value<String?> upiId,
  Value<String?> color,
  Value<String> workDays,
  Value<String> expectedTimes,
  Value<String?> usualEndTime,
  Value<String?> startDate,
  Value<String?> endDate,
  Value<bool> active,
  Value<String?> initialPayType,
  Value<int?> initialPayPaise,
  Value<int> rowid,
});

class $$StaffTableFilterComposer extends Composer<_$NestDatabase, $StaffTable> {
  $$StaffTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiId => $composableBuilder(
    column: $table.upiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workDays => $composableBuilder(
    column: $table.workDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedTimes => $composableBuilder(
    column: $table.expectedTimes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usualEndTime => $composableBuilder(
    column: $table.usualEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initialPayType => $composableBuilder(
    column: $table.initialPayType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialPayPaise => $composableBuilder(
    column: $table.initialPayPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaffTableOrderingComposer
    extends Composer<_$NestDatabase, $StaffTable> {
  $$StaffTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiId => $composableBuilder(
    column: $table.upiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workDays => $composableBuilder(
    column: $table.workDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedTimes => $composableBuilder(
    column: $table.expectedTimes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usualEndTime => $composableBuilder(
    column: $table.usualEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initialPayType => $composableBuilder(
    column: $table.initialPayType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialPayPaise => $composableBuilder(
    column: $table.initialPayPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffTableAnnotationComposer
    extends Composer<_$NestDatabase, $StaffTable> {
  $$StaffTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get workDays =>
      $composableBuilder(column: $table.workDays, builder: (column) => column);

  GeneratedColumn<String> get expectedTimes => $composableBuilder(
    column: $table.expectedTimes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usualEndTime => $composableBuilder(
    column: $table.usualEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get initialPayType => $composableBuilder(
    column: $table.initialPayType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialPayPaise => $composableBuilder(
    column: $table.initialPayPaise,
    builder: (column) => column,
  );
}

class $$StaffTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $StaffTable,
          StaffData,
          $$StaffTableFilterComposer,
          $$StaffTableOrderingComposer,
          $$StaffTableAnnotationComposer,
          $$StaffTableCreateCompanionBuilder,
          $$StaffTableUpdateCompanionBuilder,
          (StaffData, BaseReferences<_$NestDatabase, $StaffTable, StaffData>),
          StaffData,
          PrefetchHooks Function()
        > {
  $$StaffTableTableManager(_$NestDatabase db, $StaffTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> phoneE164 = const Value.absent(),
                Value<String?> upiId = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String> workDays = const Value.absent(),
                Value<String> expectedTimes = const Value.absent(),
                Value<String?> usualEndTime = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> initialPayType = const Value.absent(),
                Value<int?> initialPayPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                name: name,
                role: role,
                phoneE164: phoneE164,
                upiId: upiId,
                color: color,
                workDays: workDays,
                expectedTimes: expectedTimes,
                usualEndTime: usualEndTime,
                startDate: startDate,
                endDate: endDate,
                active: active,
                initialPayType: initialPayType,
                initialPayPaise: initialPayPaise,
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
                Value<String?> name = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> phoneE164 = const Value.absent(),
                Value<String?> upiId = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String> workDays = const Value.absent(),
                Value<String> expectedTimes = const Value.absent(),
                Value<String?> usualEndTime = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> initialPayType = const Value.absent(),
                Value<int?> initialPayPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                name: name,
                role: role,
                phoneE164: phoneE164,
                upiId: upiId,
                color: color,
                workDays: workDays,
                expectedTimes: expectedTimes,
                usualEndTime: usualEndTime,
                startDate: startDate,
                endDate: endDate,
                active: active,
                initialPayType: initialPayType,
                initialPayPaise: initialPayPaise,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StaffTable, StaffData>(table),
                  BaseReferences<_$NestDatabase, $StaffTable, StaffData>(
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

typedef $$StaffTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $StaffTable,
      StaffData,
      $$StaffTableFilterComposer,
      $$StaffTableOrderingComposer,
      $$StaffTableAnnotationComposer,
      $$StaffTableCreateCompanionBuilder,
      $$StaffTableUpdateCompanionBuilder,
      (StaffData, BaseReferences<_$NestDatabase, $StaffTable, StaffData>),
      StaffData,
      PrefetchHooks Function()
    >;
typedef $$VisitsTableCreateCompanionBuilder = VisitsCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> staffId,
  Value<String?> date,
  Value<int?> inAt,
  Value<int?> outAt,
  Value<String?> inBy,
  Value<String?> outBy,
  Value<int> rowid,
});
typedef $$VisitsTableUpdateCompanionBuilder = VisitsCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> staffId,
  Value<String?> date,
  Value<int?> inAt,
  Value<int?> outAt,
  Value<String?> inBy,
  Value<String?> outBy,
  Value<int> rowid,
});

class $$VisitsTableFilterComposer
    extends Composer<_$NestDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inAt => $composableBuilder(
    column: $table.inAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outAt => $composableBuilder(
    column: $table.outAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inBy => $composableBuilder(
    column: $table.inBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outBy => $composableBuilder(
    column: $table.outBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsTableOrderingComposer
    extends Composer<_$NestDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inAt => $composableBuilder(
    column: $table.inAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outAt => $composableBuilder(
    column: $table.outAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inBy => $composableBuilder(
    column: $table.inBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outBy => $composableBuilder(
    column: $table.outBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$NestDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get inAt =>
      $composableBuilder(column: $table.inAt, builder: (column) => column);

  GeneratedColumn<int> get outAt =>
      $composableBuilder(column: $table.outAt, builder: (column) => column);

  GeneratedColumn<String> get inBy =>
      $composableBuilder(column: $table.inBy, builder: (column) => column);

  GeneratedColumn<String> get outBy =>
      $composableBuilder(column: $table.outBy, builder: (column) => column);
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $VisitsTable,
          Visit,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (Visit, BaseReferences<_$NestDatabase, $VisitsTable, Visit>),
          Visit,
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$NestDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<int?> inAt = const Value.absent(),
                Value<int?> outAt = const Value.absent(),
                Value<String?> inBy = const Value.absent(),
                Value<String?> outBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                date: date,
                inAt: inAt,
                outAt: outAt,
                inBy: inBy,
                outBy: outBy,
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
                Value<String?> staffId = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<int?> inAt = const Value.absent(),
                Value<int?> outAt = const Value.absent(),
                Value<String?> inBy = const Value.absent(),
                Value<String?> outBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                date: date,
                inAt: inAt,
                outAt: outAt,
                inBy: inBy,
                outBy: outBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, Visit>(table),
                  BaseReferences<_$NestDatabase, $VisitsTable, Visit>(
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

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $VisitsTable,
      Visit,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (Visit, BaseReferences<_$NestDatabase, $VisitsTable, Visit>),
      Visit,
      PrefetchHooks Function()
    >;
typedef $$LeavesTableCreateCompanionBuilder = LeavesCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> staffId,
  Value<String?> date,
  Value<String?> markedBy,
  Value<int> rowid,
});
typedef $$LeavesTableUpdateCompanionBuilder = LeavesCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String?> staffId,
  Value<String?> date,
  Value<String?> markedBy,
  Value<int> rowid,
});

class $$LeavesTableFilterComposer
    extends Composer<_$NestDatabase, $LeavesTable> {
  $$LeavesTableFilterComposer({
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedBy => $composableBuilder(
    column: $table.markedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeavesTableOrderingComposer
    extends Composer<_$NestDatabase, $LeavesTable> {
  $$LeavesTableOrderingComposer({
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedBy => $composableBuilder(
    column: $table.markedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeavesTableAnnotationComposer
    extends Composer<_$NestDatabase, $LeavesTable> {
  $$LeavesTableAnnotationComposer({
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get markedBy =>
      $composableBuilder(column: $table.markedBy, builder: (column) => column);
}

class $$LeavesTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $LeavesTable,
          Leave,
          $$LeavesTableFilterComposer,
          $$LeavesTableOrderingComposer,
          $$LeavesTableAnnotationComposer,
          $$LeavesTableCreateCompanionBuilder,
          $$LeavesTableUpdateCompanionBuilder,
          (Leave, BaseReferences<_$NestDatabase, $LeavesTable, Leave>),
          Leave,
          PrefetchHooks Function()
        > {
  $$LeavesTableTableManager(_$NestDatabase db, $LeavesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeavesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeavesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeavesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<String?> markedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeavesCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                date: date,
                markedBy: markedBy,
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
                Value<String?> staffId = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<String?> markedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeavesCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                date: date,
                markedBy: markedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LeavesTable, Leave>(table),
                  BaseReferences<_$NestDatabase, $LeavesTable, Leave>(
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

typedef $$LeavesTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $LeavesTable,
      Leave,
      $$LeavesTableFilterComposer,
      $$LeavesTableOrderingComposer,
      $$LeavesTableAnnotationComposer,
      $$LeavesTableCreateCompanionBuilder,
      $$LeavesTableUpdateCompanionBuilder,
      (Leave, BaseReferences<_$NestDatabase, $LeavesTable, Leave>),
      Leave,
      PrefetchHooks Function()
    >;
typedef $$PayRulesTableCreateCompanionBuilder = PayRulesCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> staffId,
  Value<String> effectiveMonth,
  Value<String> workDays,
  Value<String> payType,
  Value<int> ratePerHourPaise,
  Value<int> roundingMin,
  Value<int> minHoursPerVisit,
  Value<int> amountPerMonthPaise,
  Value<int> paidLeavesPerMonth,
  Value<int> rowid,
});
typedef $$PayRulesTableUpdateCompanionBuilder = PayRulesCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> staffId,
  Value<String> effectiveMonth,
  Value<String> workDays,
  Value<String> payType,
  Value<int> ratePerHourPaise,
  Value<int> roundingMin,
  Value<int> minHoursPerVisit,
  Value<int> amountPerMonthPaise,
  Value<int> paidLeavesPerMonth,
  Value<int> rowid,
});

class $$PayRulesTableFilterComposer
    extends Composer<_$NestDatabase, $PayRulesTable> {
  $$PayRulesTableFilterComposer({
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveMonth => $composableBuilder(
    column: $table.effectiveMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workDays => $composableBuilder(
    column: $table.workDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payType => $composableBuilder(
    column: $table.payType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePerHourPaise => $composableBuilder(
    column: $table.ratePerHourPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundingMin => $composableBuilder(
    column: $table.roundingMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minHoursPerVisit => $composableBuilder(
    column: $table.minHoursPerVisit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPerMonthPaise => $composableBuilder(
    column: $table.amountPerMonthPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidLeavesPerMonth => $composableBuilder(
    column: $table.paidLeavesPerMonth,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayRulesTableOrderingComposer
    extends Composer<_$NestDatabase, $PayRulesTable> {
  $$PayRulesTableOrderingComposer({
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveMonth => $composableBuilder(
    column: $table.effectiveMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workDays => $composableBuilder(
    column: $table.workDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payType => $composableBuilder(
    column: $table.payType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePerHourPaise => $composableBuilder(
    column: $table.ratePerHourPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundingMin => $composableBuilder(
    column: $table.roundingMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minHoursPerVisit => $composableBuilder(
    column: $table.minHoursPerVisit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPerMonthPaise => $composableBuilder(
    column: $table.amountPerMonthPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidLeavesPerMonth => $composableBuilder(
    column: $table.paidLeavesPerMonth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayRulesTableAnnotationComposer
    extends Composer<_$NestDatabase, $PayRulesTable> {
  $$PayRulesTableAnnotationComposer({
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get effectiveMonth => $composableBuilder(
    column: $table.effectiveMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workDays =>
      $composableBuilder(column: $table.workDays, builder: (column) => column);

  GeneratedColumn<String> get payType =>
      $composableBuilder(column: $table.payType, builder: (column) => column);

  GeneratedColumn<int> get ratePerHourPaise => $composableBuilder(
    column: $table.ratePerHourPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundingMin => $composableBuilder(
    column: $table.roundingMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minHoursPerVisit => $composableBuilder(
    column: $table.minHoursPerVisit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPerMonthPaise => $composableBuilder(
    column: $table.amountPerMonthPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidLeavesPerMonth => $composableBuilder(
    column: $table.paidLeavesPerMonth,
    builder: (column) => column,
  );
}

class $$PayRulesTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $PayRulesTable,
          PayRuleRow,
          $$PayRulesTableFilterComposer,
          $$PayRulesTableOrderingComposer,
          $$PayRulesTableAnnotationComposer,
          $$PayRulesTableCreateCompanionBuilder,
          $$PayRulesTableUpdateCompanionBuilder,
          (
            PayRuleRow,
            BaseReferences<_$NestDatabase, $PayRulesTable, PayRuleRow>,
          ),
          PayRuleRow,
          PrefetchHooks Function()
        > {
  $$PayRulesTableTableManager(_$NestDatabase db, $PayRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String> effectiveMonth = const Value.absent(),
                Value<String> workDays = const Value.absent(),
                Value<String> payType = const Value.absent(),
                Value<int> ratePerHourPaise = const Value.absent(),
                Value<int> roundingMin = const Value.absent(),
                Value<int> minHoursPerVisit = const Value.absent(),
                Value<int> amountPerMonthPaise = const Value.absent(),
                Value<int> paidLeavesPerMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayRulesCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                effectiveMonth: effectiveMonth,
                workDays: workDays,
                payType: payType,
                ratePerHourPaise: ratePerHourPaise,
                roundingMin: roundingMin,
                minHoursPerVisit: minHoursPerVisit,
                amountPerMonthPaise: amountPerMonthPaise,
                paidLeavesPerMonth: paidLeavesPerMonth,
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
                Value<String> staffId = const Value.absent(),
                Value<String> effectiveMonth = const Value.absent(),
                Value<String> workDays = const Value.absent(),
                Value<String> payType = const Value.absent(),
                Value<int> ratePerHourPaise = const Value.absent(),
                Value<int> roundingMin = const Value.absent(),
                Value<int> minHoursPerVisit = const Value.absent(),
                Value<int> amountPerMonthPaise = const Value.absent(),
                Value<int> paidLeavesPerMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayRulesCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                effectiveMonth: effectiveMonth,
                workDays: workDays,
                payType: payType,
                ratePerHourPaise: ratePerHourPaise,
                roundingMin: roundingMin,
                minHoursPerVisit: minHoursPerVisit,
                amountPerMonthPaise: amountPerMonthPaise,
                paidLeavesPerMonth: paidLeavesPerMonth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayRulesTable, PayRuleRow>(table),
                  BaseReferences<_$NestDatabase, $PayRulesTable, PayRuleRow>(
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

typedef $$PayRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $PayRulesTable,
      PayRuleRow,
      $$PayRulesTableFilterComposer,
      $$PayRulesTableOrderingComposer,
      $$PayRulesTableAnnotationComposer,
      $$PayRulesTableCreateCompanionBuilder,
      $$PayRulesTableUpdateCompanionBuilder,
      (PayRuleRow, BaseReferences<_$NestDatabase, $PayRulesTable, PayRuleRow>),
      PayRuleRow,
      PrefetchHooks Function()
    >;
typedef $$PayAdjustmentsTableCreateCompanionBuilder =
    PayAdjustmentsCompanion Function({
      required String id,
      required String homeId,
      Value<bool> deleted,
      Value<int> createdAt,
      Value<String> createdBy,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<String> staffId,
      Value<String> month,
      Value<String> kind,
      Value<int> amountPaise,
      Value<String> note,
      Value<String?> settlementAttemptId,
      Value<int> rowid,
    });
typedef $$PayAdjustmentsTableUpdateCompanionBuilder =
    PayAdjustmentsCompanion Function({
      Value<String> id,
      Value<String> homeId,
      Value<bool> deleted,
      Value<int> createdAt,
      Value<String> createdBy,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<String> staffId,
      Value<String> month,
      Value<String> kind,
      Value<int> amountPaise,
      Value<String> note,
      Value<String?> settlementAttemptId,
      Value<int> rowid,
    });

class $$PayAdjustmentsTableFilterComposer
    extends Composer<_$NestDatabase, $PayAdjustmentsTable> {
  $$PayAdjustmentsTableFilterComposer({
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settlementAttemptId => $composableBuilder(
    column: $table.settlementAttemptId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayAdjustmentsTableOrderingComposer
    extends Composer<_$NestDatabase, $PayAdjustmentsTable> {
  $$PayAdjustmentsTableOrderingComposer({
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settlementAttemptId => $composableBuilder(
    column: $table.settlementAttemptId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayAdjustmentsTableAnnotationComposer
    extends Composer<_$NestDatabase, $PayAdjustmentsTable> {
  $$PayAdjustmentsTableAnnotationComposer({
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get settlementAttemptId => $composableBuilder(
    column: $table.settlementAttemptId,
    builder: (column) => column,
  );
}

class $$PayAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $PayAdjustmentsTable,
          PayAdjustmentRow,
          $$PayAdjustmentsTableFilterComposer,
          $$PayAdjustmentsTableOrderingComposer,
          $$PayAdjustmentsTableAnnotationComposer,
          $$PayAdjustmentsTableCreateCompanionBuilder,
          $$PayAdjustmentsTableUpdateCompanionBuilder,
          (
            PayAdjustmentRow,
            BaseReferences<
              _$NestDatabase,
              $PayAdjustmentsTable,
              PayAdjustmentRow
            >,
          ),
          PayAdjustmentRow,
          PrefetchHooks Function()
        > {
  $$PayAdjustmentsTableTableManager(
    _$NestDatabase db,
    $PayAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayAdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayAdjustmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> settlementAttemptId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayAdjustmentsCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                month: month,
                kind: kind,
                amountPaise: amountPaise,
                note: note,
                settlementAttemptId: settlementAttemptId,
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
                Value<String> staffId = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> settlementAttemptId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayAdjustmentsCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                month: month,
                kind: kind,
                amountPaise: amountPaise,
                note: note,
                settlementAttemptId: settlementAttemptId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayAdjustmentsTable, PayAdjustmentRow>(table),
                  BaseReferences<
                    _$NestDatabase,
                    $PayAdjustmentsTable,
                    PayAdjustmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $PayAdjustmentsTable,
      PayAdjustmentRow,
      $$PayAdjustmentsTableFilterComposer,
      $$PayAdjustmentsTableOrderingComposer,
      $$PayAdjustmentsTableAnnotationComposer,
      $$PayAdjustmentsTableCreateCompanionBuilder,
      $$PayAdjustmentsTableUpdateCompanionBuilder,
      (
        PayAdjustmentRow,
        BaseReferences<_$NestDatabase, $PayAdjustmentsTable, PayAdjustmentRow>,
      ),
      PayAdjustmentRow,
      PrefetchHooks Function()
    >;
typedef $$SettlementAttemptsTableCreateCompanionBuilder =
    SettlementAttemptsCompanion Function({
      required String id,
      required String homeId,
      Value<bool> deleted,
      Value<int> createdAt,
      Value<String> createdBy,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<String> staffId,
      Value<String> month,
      Value<String> kind,
      Value<String?> refAttemptId,
      Value<int> amountPaise,
      Value<String?> method,
      Value<int> netPaise,
      Value<String?> breakdownJson,
      Value<int> deltaPaise,
      Value<String?> prevTransferIds,
      Value<String?> expenseId,
      Value<String> byMember,
      Value<int> rowid,
    });
typedef $$SettlementAttemptsTableUpdateCompanionBuilder =
    SettlementAttemptsCompanion Function({
      Value<String> id,
      Value<String> homeId,
      Value<bool> deleted,
      Value<int> createdAt,
      Value<String> createdBy,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<String> staffId,
      Value<String> month,
      Value<String> kind,
      Value<String?> refAttemptId,
      Value<int> amountPaise,
      Value<String?> method,
      Value<int> netPaise,
      Value<String?> breakdownJson,
      Value<int> deltaPaise,
      Value<String?> prevTransferIds,
      Value<String?> expenseId,
      Value<String> byMember,
      Value<int> rowid,
    });

class $$SettlementAttemptsTableFilterComposer
    extends Composer<_$NestDatabase, $SettlementAttemptsTable> {
  $$SettlementAttemptsTableFilterComposer({
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

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refAttemptId => $composableBuilder(
    column: $table.refAttemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netPaise => $composableBuilder(
    column: $table.netPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breakdownJson => $composableBuilder(
    column: $table.breakdownJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deltaPaise => $composableBuilder(
    column: $table.deltaPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevTransferIds => $composableBuilder(
    column: $table.prevTransferIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get byMember => $composableBuilder(
    column: $table.byMember,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettlementAttemptsTableOrderingComposer
    extends Composer<_$NestDatabase, $SettlementAttemptsTable> {
  $$SettlementAttemptsTableOrderingComposer({
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

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refAttemptId => $composableBuilder(
    column: $table.refAttemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netPaise => $composableBuilder(
    column: $table.netPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breakdownJson => $composableBuilder(
    column: $table.breakdownJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deltaPaise => $composableBuilder(
    column: $table.deltaPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevTransferIds => $composableBuilder(
    column: $table.prevTransferIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get byMember => $composableBuilder(
    column: $table.byMember,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettlementAttemptsTableAnnotationComposer
    extends Composer<_$NestDatabase, $SettlementAttemptsTable> {
  $$SettlementAttemptsTableAnnotationComposer({
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

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get refAttemptId => $composableBuilder(
    column: $table.refAttemptId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get netPaise =>
      $composableBuilder(column: $table.netPaise, builder: (column) => column);

  GeneratedColumn<String> get breakdownJson => $composableBuilder(
    column: $table.breakdownJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deltaPaise => $composableBuilder(
    column: $table.deltaPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prevTransferIds => $composableBuilder(
    column: $table.prevTransferIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expenseId =>
      $composableBuilder(column: $table.expenseId, builder: (column) => column);

  GeneratedColumn<String> get byMember =>
      $composableBuilder(column: $table.byMember, builder: (column) => column);
}

class $$SettlementAttemptsTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $SettlementAttemptsTable,
          SettlementAttemptRow,
          $$SettlementAttemptsTableFilterComposer,
          $$SettlementAttemptsTableOrderingComposer,
          $$SettlementAttemptsTableAnnotationComposer,
          $$SettlementAttemptsTableCreateCompanionBuilder,
          $$SettlementAttemptsTableUpdateCompanionBuilder,
          (
            SettlementAttemptRow,
            BaseReferences<
              _$NestDatabase,
              $SettlementAttemptsTable,
              SettlementAttemptRow
            >,
          ),
          SettlementAttemptRow,
          PrefetchHooks Function()
        > {
  $$SettlementAttemptsTableTableManager(
    _$NestDatabase db,
    $SettlementAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettlementAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettlementAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettlementAttemptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> refAttemptId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> method = const Value.absent(),
                Value<int> netPaise = const Value.absent(),
                Value<String?> breakdownJson = const Value.absent(),
                Value<int> deltaPaise = const Value.absent(),
                Value<String?> prevTransferIds = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<String> byMember = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettlementAttemptsCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                month: month,
                kind: kind,
                refAttemptId: refAttemptId,
                amountPaise: amountPaise,
                method: method,
                netPaise: netPaise,
                breakdownJson: breakdownJson,
                deltaPaise: deltaPaise,
                prevTransferIds: prevTransferIds,
                expenseId: expenseId,
                byMember: byMember,
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
                Value<String> staffId = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> refAttemptId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> method = const Value.absent(),
                Value<int> netPaise = const Value.absent(),
                Value<String?> breakdownJson = const Value.absent(),
                Value<int> deltaPaise = const Value.absent(),
                Value<String?> prevTransferIds = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<String> byMember = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettlementAttemptsCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                staffId: staffId,
                month: month,
                kind: kind,
                refAttemptId: refAttemptId,
                amountPaise: amountPaise,
                method: method,
                netPaise: netPaise,
                breakdownJson: breakdownJson,
                deltaPaise: deltaPaise,
                prevTransferIds: prevTransferIds,
                expenseId: expenseId,
                byMember: byMember,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettlementAttemptsTable, SettlementAttemptRow>(
                    table,
                  ),
                  BaseReferences<
                    _$NestDatabase,
                    $SettlementAttemptsTable,
                    SettlementAttemptRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettlementAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $SettlementAttemptsTable,
      SettlementAttemptRow,
      $$SettlementAttemptsTableFilterComposer,
      $$SettlementAttemptsTableOrderingComposer,
      $$SettlementAttemptsTableAnnotationComposer,
      $$SettlementAttemptsTableCreateCompanionBuilder,
      $$SettlementAttemptsTableUpdateCompanionBuilder,
      (
        SettlementAttemptRow,
        BaseReferences<
          _$NestDatabase,
          $SettlementAttemptsTable,
          SettlementAttemptRow
        >,
      ),
      SettlementAttemptRow,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<int> amountPaise,
  Value<String> merchant,
  Value<String> merchantKey,
  Value<String> category,
  Value<String> method,
  Value<String> date,
  Value<String> docMonth,
  Value<String?> forMonth,
  Value<String> paidBy,
  Value<String> addedBy,
  Value<String> source,
  Value<String?> billId,
  Value<String?> orderChannel,
  Value<String?> staffId,
  Value<String?> settlementAttemptId,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<int> amountPaise,
  Value<String> merchant,
  Value<String> merchantKey,
  Value<String> category,
  Value<String> method,
  Value<String> date,
  Value<String> docMonth,
  Value<String?> forMonth,
  Value<String> paidBy,
  Value<String> addedBy,
  Value<String> source,
  Value<String?> billId,
  Value<String?> orderChannel,
  Value<String?> staffId,
  Value<String?> settlementAttemptId,
  Value<String?> note,
  Value<int> rowid,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$NestDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docMonth => $composableBuilder(
    column: $table.docMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forMonth => $composableBuilder(
    column: $table.forMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidBy => $composableBuilder(
    column: $table.paidBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderChannel => $composableBuilder(
    column: $table.orderChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settlementAttemptId => $composableBuilder(
    column: $table.settlementAttemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$NestDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docMonth => $composableBuilder(
    column: $table.docMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forMonth => $composableBuilder(
    column: $table.forMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidBy => $composableBuilder(
    column: $table.paidBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderChannel => $composableBuilder(
    column: $table.orderChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settlementAttemptId => $composableBuilder(
    column: $table.settlementAttemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$NestDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
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

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get docMonth =>
      $composableBuilder(column: $table.docMonth, builder: (column) => column);

  GeneratedColumn<String> get forMonth =>
      $composableBuilder(column: $table.forMonth, builder: (column) => column);

  GeneratedColumn<String> get paidBy =>
      $composableBuilder(column: $table.paidBy, builder: (column) => column);

  GeneratedColumn<String> get addedBy =>
      $composableBuilder(column: $table.addedBy, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get billId =>
      $composableBuilder(column: $table.billId, builder: (column) => column);

  GeneratedColumn<String> get orderChannel => $composableBuilder(
    column: $table.orderChannel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get settlementAttemptId => $composableBuilder(
    column: $table.settlementAttemptId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (
            ExpenseRow,
            BaseReferences<_$NestDatabase, $ExpensesTable, ExpenseRow>,
          ),
          ExpenseRow,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$NestDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> merchantKey = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> docMonth = const Value.absent(),
                Value<String?> forMonth = const Value.absent(),
                Value<String> paidBy = const Value.absent(),
                Value<String> addedBy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> billId = const Value.absent(),
                Value<String?> orderChannel = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<String?> settlementAttemptId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                amountPaise: amountPaise,
                merchant: merchant,
                merchantKey: merchantKey,
                category: category,
                method: method,
                date: date,
                docMonth: docMonth,
                forMonth: forMonth,
                paidBy: paidBy,
                addedBy: addedBy,
                source: source,
                billId: billId,
                orderChannel: orderChannel,
                staffId: staffId,
                settlementAttemptId: settlementAttemptId,
                note: note,
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
                Value<int> amountPaise = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> merchantKey = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> docMonth = const Value.absent(),
                Value<String?> forMonth = const Value.absent(),
                Value<String> paidBy = const Value.absent(),
                Value<String> addedBy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> billId = const Value.absent(),
                Value<String?> orderChannel = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<String?> settlementAttemptId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                amountPaise: amountPaise,
                merchant: merchant,
                merchantKey: merchantKey,
                category: category,
                method: method,
                date: date,
                docMonth: docMonth,
                forMonth: forMonth,
                paidBy: paidBy,
                addedBy: addedBy,
                source: source,
                billId: billId,
                orderChannel: orderChannel,
                staffId: staffId,
                settlementAttemptId: settlementAttemptId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  BaseReferences<_$NestDatabase, $ExpensesTable, ExpenseRow>(
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

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, BaseReferences<_$NestDatabase, $ExpensesTable, ExpenseRow>),
      ExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> list,
  Value<String> name,
  Value<String> nameKey,
  Value<int> qtyMilli,
  Value<String> unit,
  Value<String> channel,
  Value<String> category,
  Value<String?> note,
  Value<bool> done,
  Value<int?> doneAt,
  Value<String?> doneBy,
  Value<String> source,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> list,
  Value<String> name,
  Value<String> nameKey,
  Value<int> qtyMilli,
  Value<String> unit,
  Value<String> channel,
  Value<String> category,
  Value<String?> note,
  Value<bool> done,
  Value<int?> doneAt,
  Value<String?> doneBy,
  Value<String> source,
  Value<int> rowid,
});

class $$ItemsTableFilterComposer extends Composer<_$NestDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
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

  ColumnFilters<String> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneBy => $composableBuilder(
    column: $table.doneBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$NestDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
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

  ColumnOrderings<String> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneBy => $composableBuilder(
    column: $table.doneBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$NestDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get list =>
      $composableBuilder(column: $table.list, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<int> get qtyMilli =>
      $composableBuilder(column: $table.qtyMilli, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<String> get doneBy =>
      $composableBuilder(column: $table.doneBy, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, BaseReferences<_$NestDatabase, $ItemsTable, ItemRow>),
          ItemRow,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$NestDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String> list = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<int> qtyMilli = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<String?> doneBy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                list: list,
                name: name,
                nameKey: nameKey,
                qtyMilli: qtyMilli,
                unit: unit,
                channel: channel,
                category: category,
                note: note,
                done: done,
                doneAt: doneAt,
                doneBy: doneBy,
                source: source,
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
                Value<String> list = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<int> qtyMilli = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<String?> doneBy = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                list: list,
                name: name,
                nameKey: nameKey,
                qtyMilli: qtyMilli,
                unit: unit,
                channel: channel,
                category: category,
                note: note,
                done: done,
                doneAt: doneAt,
                doneBy: doneBy,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, ItemRow>(table),
                  BaseReferences<_$NestDatabase, $ItemsTable, ItemRow>(
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

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, BaseReferences<_$NestDatabase, $ItemsTable, ItemRow>),
      ItemRow,
      PrefetchHooks Function()
    >;
typedef $$ItemHistoryTableCreateCompanionBuilder =
    ItemHistoryCompanion Function({
      required String id,
      required String homeId,
      Value<bool> deleted,
      Value<int> createdAt,
      Value<String> createdBy,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<String> list,
      Value<String> name,
      Value<String> nameKey,
      Value<String?> usualChannel,
      Value<int?> lastBoughtAt,
      Value<int> timesBought,
      Value<int?> lastQtyMilli,
      Value<String?> lastUnit,
      Value<int> rowid,
    });
typedef $$ItemHistoryTableUpdateCompanionBuilder =
    ItemHistoryCompanion Function({
      Value<String> id,
      Value<String> homeId,
      Value<bool> deleted,
      Value<int> createdAt,
      Value<String> createdBy,
      Value<int> updatedAt,
      Value<String> updatedBy,
      Value<String> list,
      Value<String> name,
      Value<String> nameKey,
      Value<String?> usualChannel,
      Value<int?> lastBoughtAt,
      Value<int> timesBought,
      Value<int?> lastQtyMilli,
      Value<String?> lastUnit,
      Value<int> rowid,
    });

class $$ItemHistoryTableFilterComposer
    extends Composer<_$NestDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableFilterComposer({
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

  ColumnFilters<String> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usualChannel => $composableBuilder(
    column: $table.usualChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastBoughtAt => $composableBuilder(
    column: $table.lastBoughtAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesBought => $composableBuilder(
    column: $table.timesBought,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastQtyMilli => $composableBuilder(
    column: $table.lastQtyMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastUnit => $composableBuilder(
    column: $table.lastUnit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemHistoryTableOrderingComposer
    extends Composer<_$NestDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get list => $composableBuilder(
    column: $table.list,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usualChannel => $composableBuilder(
    column: $table.usualChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastBoughtAt => $composableBuilder(
    column: $table.lastBoughtAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesBought => $composableBuilder(
    column: $table.timesBought,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastQtyMilli => $composableBuilder(
    column: $table.lastQtyMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastUnit => $composableBuilder(
    column: $table.lastUnit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemHistoryTableAnnotationComposer
    extends Composer<_$NestDatabase, $ItemHistoryTable> {
  $$ItemHistoryTableAnnotationComposer({
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

  GeneratedColumn<String> get list =>
      $composableBuilder(column: $table.list, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get usualChannel => $composableBuilder(
    column: $table.usualChannel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastBoughtAt => $composableBuilder(
    column: $table.lastBoughtAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesBought => $composableBuilder(
    column: $table.timesBought,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastQtyMilli => $composableBuilder(
    column: $table.lastQtyMilli,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastUnit =>
      $composableBuilder(column: $table.lastUnit, builder: (column) => column);
}

class $$ItemHistoryTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $ItemHistoryTable,
          ItemHistoryRow,
          $$ItemHistoryTableFilterComposer,
          $$ItemHistoryTableOrderingComposer,
          $$ItemHistoryTableAnnotationComposer,
          $$ItemHistoryTableCreateCompanionBuilder,
          $$ItemHistoryTableUpdateCompanionBuilder,
          (
            ItemHistoryRow,
            BaseReferences<_$NestDatabase, $ItemHistoryTable, ItemHistoryRow>,
          ),
          ItemHistoryRow,
          PrefetchHooks Function()
        > {
  $$ItemHistoryTableTableManager(_$NestDatabase db, $ItemHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String> list = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String?> usualChannel = const Value.absent(),
                Value<int?> lastBoughtAt = const Value.absent(),
                Value<int> timesBought = const Value.absent(),
                Value<int?> lastQtyMilli = const Value.absent(),
                Value<String?> lastUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemHistoryCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                list: list,
                name: name,
                nameKey: nameKey,
                usualChannel: usualChannel,
                lastBoughtAt: lastBoughtAt,
                timesBought: timesBought,
                lastQtyMilli: lastQtyMilli,
                lastUnit: lastUnit,
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
                Value<String> list = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String?> usualChannel = const Value.absent(),
                Value<int?> lastBoughtAt = const Value.absent(),
                Value<int> timesBought = const Value.absent(),
                Value<int?> lastQtyMilli = const Value.absent(),
                Value<String?> lastUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemHistoryCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                list: list,
                name: name,
                nameKey: nameKey,
                usualChannel: usualChannel,
                lastBoughtAt: lastBoughtAt,
                timesBought: timesBought,
                lastQtyMilli: lastQtyMilli,
                lastUnit: lastUnit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemHistoryTable, ItemHistoryRow>(table),
                  BaseReferences<
                    _$NestDatabase,
                    $ItemHistoryTable,
                    ItemHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $ItemHistoryTable,
      ItemHistoryRow,
      $$ItemHistoryTableFilterComposer,
      $$ItemHistoryTableOrderingComposer,
      $$ItemHistoryTableAnnotationComposer,
      $$ItemHistoryTableCreateCompanionBuilder,
      $$ItemHistoryTableUpdateCompanionBuilder,
      (
        ItemHistoryRow,
        BaseReferences<_$NestDatabase, $ItemHistoryTable, ItemHistoryRow>,
      ),
      ItemHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> name,
  Value<String> room,
  Value<int> everyDays,
  Value<String> assigneeType,
  Value<String> assignee,
  Value<String> lastDone,
  Value<String?> lastDoneBy,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> name,
  Value<String> room,
  Value<int> everyDays,
  Value<String> assigneeType,
  Value<String> assignee,
  Value<String> lastDone,
  Value<String?> lastDoneBy,
  Value<int> rowid,
});

class $$RoutinesTableFilterComposer
    extends Composer<_$NestDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get everyDays => $composableBuilder(
    column: $table.everyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assigneeType => $composableBuilder(
    column: $table.assigneeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastDone => $composableBuilder(
    column: $table.lastDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastDoneBy => $composableBuilder(
    column: $table.lastDoneBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$NestDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get everyDays => $composableBuilder(
    column: $table.everyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assigneeType => $composableBuilder(
    column: $table.assigneeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDone => $composableBuilder(
    column: $table.lastDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDoneBy => $composableBuilder(
    column: $table.lastDoneBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$NestDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<int> get everyDays =>
      $composableBuilder(column: $table.everyDays, builder: (column) => column);

  GeneratedColumn<String> get assigneeType => $composableBuilder(
    column: $table.assigneeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignee =>
      $composableBuilder(column: $table.assignee, builder: (column) => column);

  GeneratedColumn<String> get lastDone =>
      $composableBuilder(column: $table.lastDone, builder: (column) => column);

  GeneratedColumn<String> get lastDoneBy => $composableBuilder(
    column: $table.lastDoneBy,
    builder: (column) => column,
  );
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (
            RoutineRow,
            BaseReferences<_$NestDatabase, $RoutinesTable, RoutineRow>,
          ),
          RoutineRow,
          PrefetchHooks Function()
        > {
  $$RoutinesTableTableManager(_$NestDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<int> everyDays = const Value.absent(),
                Value<String> assigneeType = const Value.absent(),
                Value<String> assignee = const Value.absent(),
                Value<String> lastDone = const Value.absent(),
                Value<String?> lastDoneBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                name: name,
                room: room,
                everyDays: everyDays,
                assigneeType: assigneeType,
                assignee: assignee,
                lastDone: lastDone,
                lastDoneBy: lastDoneBy,
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
                Value<String> name = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<int> everyDays = const Value.absent(),
                Value<String> assigneeType = const Value.absent(),
                Value<String> assignee = const Value.absent(),
                Value<String> lastDone = const Value.absent(),
                Value<String?> lastDoneBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                name: name,
                room: room,
                everyDays: everyDays,
                assigneeType: assigneeType,
                assignee: assignee,
                lastDone: lastDone,
                lastDoneBy: lastDoneBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, RoutineRow>(table),
                  BaseReferences<_$NestDatabase, $RoutinesTable, RoutineRow>(
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

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, BaseReferences<_$NestDatabase, $RoutinesTable, RoutineRow>),
      RoutineRow,
      PrefetchHooks Function()
    >;
typedef $$TodosTableCreateCompanionBuilder = TodosCompanion Function({
  required String id,
  required String homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> title,
  Value<String> due,
  Value<String> assigneeType,
  Value<String> assignee,
  Value<bool> done,
  Value<int?> doneAt,
  Value<String?> doneBy,
  Value<int> rowid,
});
typedef $$TodosTableUpdateCompanionBuilder = TodosCompanion Function({
  Value<String> id,
  Value<String> homeId,
  Value<bool> deleted,
  Value<int> createdAt,
  Value<String> createdBy,
  Value<int> updatedAt,
  Value<String> updatedBy,
  Value<String> title,
  Value<String> due,
  Value<String> assigneeType,
  Value<String> assignee,
  Value<bool> done,
  Value<int?> doneAt,
  Value<String?> doneBy,
  Value<int> rowid,
});

class $$TodosTableFilterComposer extends Composer<_$NestDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
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

  ColumnFilters<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assigneeType => $composableBuilder(
    column: $table.assigneeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneBy => $composableBuilder(
    column: $table.doneBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodosTableOrderingComposer
    extends Composer<_$NestDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
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

  ColumnOrderings<String> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assigneeType => $composableBuilder(
    column: $table.assigneeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneBy => $composableBuilder(
    column: $table.doneBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodosTableAnnotationComposer
    extends Composer<_$NestDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
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

  GeneratedColumn<String> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<String> get assigneeType => $composableBuilder(
    column: $table.assigneeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignee =>
      $composableBuilder(column: $table.assignee, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<String> get doneBy =>
      $composableBuilder(column: $table.doneBy, builder: (column) => column);
}

class $$TodosTableTableManager
    extends
        RootTableManager<
          _$NestDatabase,
          $TodosTable,
          TodoRow,
          $$TodosTableFilterComposer,
          $$TodosTableOrderingComposer,
          $$TodosTableAnnotationComposer,
          $$TodosTableCreateCompanionBuilder,
          $$TodosTableUpdateCompanionBuilder,
          (TodoRow, BaseReferences<_$NestDatabase, $TodosTable, TodoRow>),
          TodoRow,
          PrefetchHooks Function()
        > {
  $$TodosTableTableManager(_$NestDatabase db, $TodosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> due = const Value.absent(),
                Value<String> assigneeType = const Value.absent(),
                Value<String> assignee = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<String?> doneBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                title: title,
                due: due,
                assigneeType: assigneeType,
                assignee: assignee,
                done: done,
                doneAt: doneAt,
                doneBy: doneBy,
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
                Value<String> title = const Value.absent(),
                Value<String> due = const Value.absent(),
                Value<String> assigneeType = const Value.absent(),
                Value<String> assignee = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int?> doneAt = const Value.absent(),
                Value<String?> doneBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodosCompanion.insert(
                id: id,
                homeId: homeId,
                deleted: deleted,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                title: title,
                due: due,
                assigneeType: assigneeType,
                assignee: assignee,
                done: done,
                doneAt: doneAt,
                doneBy: doneBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TodosTable, TodoRow>(table),
                  BaseReferences<_$NestDatabase, $TodosTable, TodoRow>(
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

typedef $$TodosTableProcessedTableManager =
    ProcessedTableManager<
      _$NestDatabase,
      $TodosTable,
      TodoRow,
      $$TodosTableFilterComposer,
      $$TodosTableOrderingComposer,
      $$TodosTableAnnotationComposer,
      $$TodosTableCreateCompanionBuilder,
      $$TodosTableUpdateCompanionBuilder,
      (TodoRow, BaseReferences<_$NestDatabase, $TodosTable, TodoRow>),
      TodoRow,
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
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db, _db.homes);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db, _db.staff);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$LeavesTableTableManager get leaves =>
      $$LeavesTableTableManager(_db, _db.leaves);
  $$PayRulesTableTableManager get payRules =>
      $$PayRulesTableTableManager(_db, _db.payRules);
  $$PayAdjustmentsTableTableManager get payAdjustments =>
      $$PayAdjustmentsTableTableManager(_db, _db.payAdjustments);
  $$SettlementAttemptsTableTableManager get settlementAttempts =>
      $$SettlementAttemptsTableTableManager(_db, _db.settlementAttempts);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$ItemHistoryTableTableManager get itemHistory =>
      $$ItemHistoryTableTableManager(_db, _db.itemHistory);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db, _db.todos);
}
