// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'networks_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetworksListAdapter extends TypeAdapter<NetworksList> {
  @override
  final int typeId = 4;

  @override
  NetworksList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetworksList()
      ..active = fields[0] as int
      ..networks = (fields[1] as List)?.cast<NetworksObject>();
  }

  @override
  void write(BinaryWriter writer, NetworksList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.active)
      ..writeByte(1)
      ..write(obj.networks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworksListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
