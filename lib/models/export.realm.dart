// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Export extends _Export with RealmEntity, RealmObjectBase, RealmObject {
  Export(
    String id,
    String employeeId,
    String customerName,
    String customerPhone,
    DateTime exportDate,
    double totalAmount,
    String itemsJson,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'employeeId', employeeId);
    RealmObjectBase.set(this, 'customerName', customerName);
    RealmObjectBase.set(this, 'customerPhone', customerPhone);
    RealmObjectBase.set(this, 'exportDate', exportDate);
    RealmObjectBase.set(this, 'totalAmount', totalAmount);
    RealmObjectBase.set(this, 'itemsJson', itemsJson);
  }

  Export._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get employeeId =>
      RealmObjectBase.get<String>(this, 'employeeId') as String;
  @override
  set employeeId(String value) =>
      RealmObjectBase.set(this, 'employeeId', value);

  @override
  String get customerName =>
      RealmObjectBase.get<String>(this, 'customerName') as String;
  @override
  set customerName(String value) =>
      RealmObjectBase.set(this, 'customerName', value);

  @override
  String get customerPhone =>
      RealmObjectBase.get<String>(this, 'customerPhone') as String;
  @override
  set customerPhone(String value) =>
      RealmObjectBase.set(this, 'customerPhone', value);

  @override
  DateTime get exportDate =>
      RealmObjectBase.get<DateTime>(this, 'exportDate') as DateTime;
  @override
  set exportDate(DateTime value) =>
      RealmObjectBase.set(this, 'exportDate', value);

  @override
  double get totalAmount =>
      RealmObjectBase.get<double>(this, 'totalAmount') as double;
  @override
  set totalAmount(double value) =>
      RealmObjectBase.set(this, 'totalAmount', value);

  @override
  String get itemsJson =>
      RealmObjectBase.get<String>(this, 'itemsJson') as String;
  @override
  set itemsJson(String value) => RealmObjectBase.set(this, 'itemsJson', value);

  @override
  Stream<RealmObjectChanges<Export>> get changes =>
      RealmObjectBase.getChanges<Export>(this);

  @override
  Stream<RealmObjectChanges<Export>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Export>(this, keyPaths);

  @override
  Export freeze() => RealmObjectBase.freezeObject<Export>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'employeeId': employeeId.toEJson(),
      'customerName': customerName.toEJson(),
      'customerPhone': customerPhone.toEJson(),
      'exportDate': exportDate.toEJson(),
      'totalAmount': totalAmount.toEJson(),
      'itemsJson': itemsJson.toEJson(),
    };
  }

  static EJsonValue _toEJson(Export value) => value.toEJson();
  static Export _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'employeeId': EJsonValue employeeId,
        'customerName': EJsonValue customerName,
        'customerPhone': EJsonValue customerPhone,
        'exportDate': EJsonValue exportDate,
        'totalAmount': EJsonValue totalAmount,
        'itemsJson': EJsonValue itemsJson,
      } =>
        Export(
          fromEJson(id),
          fromEJson(employeeId),
          fromEJson(customerName),
          fromEJson(customerPhone),
          fromEJson(exportDate),
          fromEJson(totalAmount),
          fromEJson(itemsJson),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Export._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Export, 'Export', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('employeeId', RealmPropertyType.string),
      SchemaProperty('customerName', RealmPropertyType.string),
      SchemaProperty('customerPhone', RealmPropertyType.string),
      SchemaProperty('exportDate', RealmPropertyType.timestamp),
      SchemaProperty('totalAmount', RealmPropertyType.double),
      SchemaProperty('itemsJson', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
