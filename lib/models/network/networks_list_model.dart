import 'package:hive/hive.dart';

import 'networks_model.dart';

part 'networks_list_model.g.dart';

@HiveType(typeId: 4)
class NetworksList extends HiveObject {
  @HiveField(0)
  int active;

  @HiveField(1)
  List<NetworksObject> networks;
}
