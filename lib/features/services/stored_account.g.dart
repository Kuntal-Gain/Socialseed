// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredAccountAdapter extends TypeAdapter<StoredAccount> {
  @override
  final int typeId = 0;

  @override
  StoredAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredAccount(
      email: fields[0] as String,
      password: fields[1] as String,
      username: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StoredAccount obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.username);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
