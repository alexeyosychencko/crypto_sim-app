// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradeAdapter extends TypeAdapter<Trade> {
  @override
  final int typeId = 2;

  @override
  Trade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trade(
      id: fields[0] as String,
      symbol: fields[1] as String,
      type: fields[2] as String,
      entryPrice: fields[3] as double,
      exitPrice: fields[4] as double,
      amount: fields[5] as double,
      leverage: fields[6] as int,
      pnl: fields[7] as double,
      pnlPercent: fields[8] as double,
      openedAt: fields[9] as DateTime,
      closedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Trade obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.entryPrice)
      ..writeByte(4)
      ..write(obj.exitPrice)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.leverage)
      ..writeByte(7)
      ..write(obj.pnl)
      ..writeByte(8)
      ..write(obj.pnlPercent)
      ..writeByte(9)
      ..write(obj.openedAt)
      ..writeByte(10)
      ..write(obj.closedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
