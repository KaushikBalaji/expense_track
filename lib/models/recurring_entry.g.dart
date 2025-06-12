// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringEntryAdapter extends TypeAdapter<RecurringEntry> {
  @override
  final int typeId = 5;

  @override
  RecurringEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringEntry(
      id: fields[0] as String?,
      title: fields[1] as String,
      amount: fields[2] as double,
      tag: fields[3] as String,
      type: fields[4] as String,
      startDate: fields[5] as DateTime,
      frequency: fields[6] as String,
      interval: fields[7] as int,
      endDate: fields[8] as DateTime?,
      note: fields[9] as String?,
      lastModified: fields[10] as DateTime?,
      lastGenerated: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringEntry obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.tag)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.frequency)
      ..writeByte(7)
      ..write(obj.interval)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.lastModified)
      ..writeByte(11)
      ..write(obj.lastGenerated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
