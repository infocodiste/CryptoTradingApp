// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'networks_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetworksObjectAdapter extends TypeAdapter<NetworksObject> {
  @override
  final int typeId = 3;

  @override
  NetworksObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetworksObject()
      ..name = fields[0] as String
      ..rpcUrl = fields[1] as String
      ..chainId = fields[2] as int
      ..testNet = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, NetworksObject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.rpcUrl)
      ..writeByte(2)
      ..write(obj.chainId)
      ..writeByte(3)
      ..write(obj.testNet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworksObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
