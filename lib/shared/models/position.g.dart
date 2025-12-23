// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PositionAdapter extends TypeAdapter<Position> {
  @override
  final int typeId = 1;

  @override
  Position read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Position(
      id: fields[0] as String,
      symbol: fields[1] as String,
      type: fields[2] as String,
      entryPrice: fields[3] as double,
      amount: fields[4] as double,
      leverage: fields[5] as int,
      openedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Position obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.entryPrice)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.leverage)
      ..writeByte(6)
      ..write(obj.openedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
