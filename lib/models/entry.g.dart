// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntryAdapter extends TypeAdapter<Entry> {
  @override
  final int typeId = 2;

  @override
  Entry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Entry(
      title: fields[0] as String,
      amount: fields[1] as double,
      tag: fields[2] as String,
      date: fields[3] as DateTime,
      type: fields[4] as EntryType,
    );
  }

  @override
  void write(BinaryWriter writer, Entry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.tag)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EntryTypeAdapter extends TypeAdapter<EntryType> {
  @override
  final int typeId = 1;

  @override
  EntryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EntryType.income;
      case 1:
        return EntryType.expense;
      default:
        return EntryType.income;
    }
  }

  @override
  void write(BinaryWriter writer, EntryType obj) {
    switch (obj) {
      case EntryType.income:
        writer.writeByte(0);
        break;
      case EntryType.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
