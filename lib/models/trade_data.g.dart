
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradeDataAdapter extends TypeAdapter<TradeData> {
  @override
  final int typeId = 2;

  @override
  TradeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradeData(
      id: fields[0] as String,
      indication: fields[1] as String,
      activeSubstance: fields[2] as String,
      route: fields[3] as String,
      param: fields[4] as String,
      doseFrom: fields[5] as double,
      doseTo: fields[6] as double,
      dosePer: fields[7] as String,
      maxDose: fields[8] as String?,
      duration: fields[9] as String?,
      divisionDoseNumber: fields[10] as String,
      note: fields[11] as String?,
      ref: fields[12] as String?,
      use: fields[13] as String?,
      category: fields[14] as String?,
      precaution: fields[15] as String?,
      contraindications: fields[16] as String?,
      g6pd: fields[17] as dynamic,
      solidDose: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TradeData obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.indication)
      ..writeByte(2)
      ..write(obj.activeSubstance)
      ..writeByte(3)
      ..write(obj.route)
      ..writeByte(4)
      ..write(obj.param)
      ..writeByte(5)
      ..write(obj.doseFrom)
      ..writeByte(6)
      ..write(obj.doseTo)
      ..writeByte(7)
      ..write(obj.dosePer)
      ..writeByte(8)
      ..write(obj.maxDose)
      ..writeByte(9)
      ..write(obj.duration)
      ..writeByte(10)
      ..write(obj.divisionDoseNumber)
      ..writeByte(11)
      ..write(obj.note)
      ..writeByte(12)
      ..write(obj.ref)
      ..writeByte(13)
      ..write(obj.use)
      ..writeByte(14)
      ..write(obj.category)
      ..writeByte(15)
      ..write(obj.precaution)
      ..writeByte(16)
      ..write(obj.contraindications)
      ..writeByte(17)
      ..write(obj.g6pd)
      ..writeByte(18)
      ..write(obj.solidDose);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
