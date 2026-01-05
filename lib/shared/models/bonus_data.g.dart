// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonus_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BonusDataAdapter extends TypeAdapter<BonusData> {
  @override
  final int typeId = 3;

  @override
  BonusData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BonusData(
      lastClaimDate: fields[0] as DateTime?,
      currentStreak: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BonusData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lastClaimDate)
      ..writeByte(1)
      ..write(obj.currentStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonusDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
