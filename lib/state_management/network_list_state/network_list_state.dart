part of 'network_list_cubit.dart';

abstract class NetworkListState {
  const NetworkListState();
}

class NetworkListInitial extends NetworkListState {
  const NetworkListInitial();
}

class NetworkListLoading extends NetworkListState {
  const NetworkListLoading();
}

class NetworkListFinal extends NetworkListState {
  final NetworksList data;

  const NetworkListFinal(this.data);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NetworkListFinal &&
        o.data.networks.length == data.networks.length &&
        _checkEquality(o.data, data);
  }

  @override
  int get hashCode => data.hashCode;

  _checkEquality(NetworksList o1, NetworksList o2) {
    for (int i = 0; i < o1.networks.length; i++) {
      var element1 = o1.networks[i];
      var ls =
          o2.networks.where((element2) => element1.rpcUrl == element2.rpcUrl);
      if (ls.isNotEmpty) {
        if (ls.first.chainId != element1.chainId) {
          return false;
        }
      }
    }

    return true;
  }
}

class NetworkListError extends NetworkListState {
  final String message;

  const NetworkListError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NetworkListError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
