
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoseDataAdapter extends TypeAdapter<DoseData> {
  @override
  final int typeId = 3;

  @override
  DoseData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseData(
      id: fields[0] as String,
      tradeName: fields[1] as String,
      activeSubstanceWithConc: fields[2] as String,
      activeSubstance: fields[3] as String,
      route: fields[4] as String,
      form: fields[5] as String?,
      concMg: fields[6] as double,
      volumeMl: fields[7] as double,
      packageSize: fields[8] as double?,
      barcode: fields[9] as String?,
      note: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DoseData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tradeName)
      ..writeByte(2)
      ..write(obj.activeSubstanceWithConc)
      ..writeByte(3)
      ..write(obj.activeSubstance)
      ..writeByte(4)
      ..write(obj.route)
      ..writeByte(5)
      ..write(obj.form)
      ..writeByte(6)
      ..write(obj.concMg)
      ..writeByte(7)
      ..write(obj.volumeMl)
      ..writeByte(8)
      ..write(obj.packageSize)
      ..writeByte(9)
      ..write(obj.barcode)
      ..writeByte(10)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
