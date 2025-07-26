// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Customer extends _Customer
    with RealmEntity, RealmObjectBase, RealmObject {
  Customer(
    String id,
    String name,
    String email,
    String phone,
    String address,
    String company,
    String taxCode,
    String customerType,
    String notes,
    DateTime createdAt,
    DateTime updatedAt,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'company', company);
    RealmObjectBase.set(this, 'taxCode', taxCode);
    RealmObjectBase.set(this, 'customerType', customerType);
    RealmObjectBase.set(this, 'notes', notes);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  Customer._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String get phone => RealmObjectBase.get<String>(this, 'phone') as String;
  @override
  set phone(String value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String get address => RealmObjectBase.get<String>(this, 'address') as String;
  @override
  set address(String value) => RealmObjectBase.set(this, 'address', value);

  @override
  String get company => RealmObjectBase.get<String>(this, 'company') as String;
  @override
  set company(String value) => RealmObjectBase.set(this, 'company', value);

  @override
  String get taxCode => RealmObjectBase.get<String>(this, 'taxCode') as String;
  @override
  set taxCode(String value) => RealmObjectBase.set(this, 'taxCode', value);

  @override
  String get customerType =>
      RealmObjectBase.get<String>(this, 'customerType') as String;
  @override
  set customerType(String value) =>
      RealmObjectBase.set(this, 'customerType', value);

  @override
  String get notes => RealmObjectBase.get<String>(this, 'notes') as String;
  @override
  set notes(String value) => RealmObjectBase.set(this, 'notes', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<Customer>> get changes =>
      RealmObjectBase.getChanges<Customer>(this);

  @override
  Stream<RealmObjectChanges<Customer>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Customer>(this, keyPaths);

  @override
  Customer freeze() => RealmObjectBase.freezeObject<Customer>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'email': email.toEJson(),
      'phone': phone.toEJson(),
      'address': address.toEJson(),
      'company': company.toEJson(),
      'taxCode': taxCode.toEJson(),
      'customerType': customerType.toEJson(),
      'notes': notes.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Customer value) => value.toEJson();
  static Customer _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'email': EJsonValue email,
        'phone': EJsonValue phone,
        'address': EJsonValue address,
        'company': EJsonValue company,
        'taxCode': EJsonValue taxCode,
        'customerType': EJsonValue customerType,
        'notes': EJsonValue notes,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
      } =>
        Customer(
          fromEJson(id),
          fromEJson(name),
          fromEJson(email),
          fromEJson(phone),
          fromEJson(address),
          fromEJson(company),
          fromEJson(taxCode),
          fromEJson(customerType),
          fromEJson(notes),
          fromEJson(createdAt),
          fromEJson(updatedAt),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Customer._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Customer, 'Customer', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('phone', RealmPropertyType.string),
      SchemaProperty('address', RealmPropertyType.string),
      SchemaProperty('company', RealmPropertyType.string),
      SchemaProperty('taxCode', RealmPropertyType.string),
      SchemaProperty('customerType', RealmPropertyType.string),
      SchemaProperty('notes', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
