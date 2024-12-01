// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_city.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedCityAdapter extends TypeAdapter<SavedCity> {
  @override
  final int typeId = 0;

  @override
  SavedCity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedCity(
      cityName: fields[0] as String,
      countryName: fields[1] as String,
      prayerTimes: (fields[2] as Map).cast<String, dynamic>(),
      lastUpdated: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedCity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cityName)
      ..writeByte(1)
      ..write(obj.countryName)
      ..writeByte(2)
      ..write(obj.prayerTimes)
      ..writeByte(3)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
