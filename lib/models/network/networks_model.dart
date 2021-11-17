import 'package:hive/hive.dart';

part 'networks_model.g.dart';

@HiveType(typeId: 3)
class NetworksObject extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String rpcUrl;

  @HiveField(2)
  int chainId;

  @HiveField(3)
  int testNet;
}
