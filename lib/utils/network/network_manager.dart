import '../../constants.dart';
import 'network_config.dart';

class NetworkManager {
  static Future<NetworkConfigObject> getNetworkObject() async {
    // int id = await BoxUtils.getNetworkConfig();
    int id = 0;
    var config;
    if (id == 0) {
      config = NetworkConfig.TestnetConfig;
    } else {
      config = NetworkConfig.MainnetConfig;
    }
    NetworkConfigObject obj = new NetworkConfigObject(
      endpoint: config[endpoint],
      chainId: config[chainId],
      ethChainId: config[ethChainId],
      ethEndpoint: config[ethEndpoint],
    );

    return obj;
  }
}
