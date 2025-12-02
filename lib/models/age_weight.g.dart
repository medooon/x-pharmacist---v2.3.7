
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'age_weight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgeWeightAdapter extends TypeAdapter<AgeWeight> {
  @override
  final int typeId = 4;

  @override
  AgeWeight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgeWeight(
      id: fields[0] as String,
      years: fields[1] as int,
      months: fields[2] as int,
      weightKg: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AgeWeight obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.years)
      ..writeByte(2)
      ..write(obj.months)
      ..writeByte(3)
      ..write(obj.weightKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgeWeightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
