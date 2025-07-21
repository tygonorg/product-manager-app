// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_item.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class ExportItem extends _ExportItem
    with RealmEntity, RealmObjectBase, RealmObject {
  ExportItem(
    String productId,
    String productName,
    double priceAtExport,
    int quantity,
  ) {
    RealmObjectBase.set(this, 'productId', productId);
    RealmObjectBase.set(this, 'productName', productName);
    RealmObjectBase.set(this, 'priceAtExport', priceAtExport);
    RealmObjectBase.set(this, 'quantity', quantity);
  }

  ExportItem._();

  @override
  String get productId =>
      RealmObjectBase.get<String>(this, 'productId') as String;
  @override
  set productId(String value) => RealmObjectBase.set(this, 'productId', value);

  @override
  String get productName =>
      RealmObjectBase.get<String>(this, 'productName') as String;
  @override
  set productName(String value) =>
      RealmObjectBase.set(this, 'productName', value);

  @override
  double get priceAtExport =>
      RealmObjectBase.get<double>(this, 'priceAtExport') as double;
  @override
  set priceAtExport(double value) =>
      RealmObjectBase.set(this, 'priceAtExport', value);

  @override
  int get quantity => RealmObjectBase.get<int>(this, 'quantity') as int;
  @override
  set quantity(int value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  Stream<RealmObjectChanges<ExportItem>> get changes =>
      RealmObjectBase.getChanges<ExportItem>(this);

  @override
  Stream<RealmObjectChanges<ExportItem>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ExportItem>(this, keyPaths);

  @override
  ExportItem freeze() => RealmObjectBase.freezeObject<ExportItem>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'productId': productId.toEJson(),
      'productName': productName.toEJson(),
      'priceAtExport': priceAtExport.toEJson(),
      'quantity': quantity.toEJson(),
    };
  }

  static EJsonValue _toEJson(ExportItem value) => value.toEJson();
  static ExportItem _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'productId': EJsonValue productId,
        'productName': EJsonValue productName,
        'priceAtExport': EJsonValue priceAtExport,
        'quantity': EJsonValue quantity,
      } =>
        ExportItem(
          fromEJson(productId),
          fromEJson(productName),
          fromEJson(priceAtExport),
          fromEJson(quantity),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ExportItem._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ExportItem, 'ExportItem', [
      SchemaProperty('productId', RealmPropertyType.string),
      SchemaProperty('productName', RealmPropertyType.string),
      SchemaProperty('priceAtExport', RealmPropertyType.double),
      SchemaProperty('quantity', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
