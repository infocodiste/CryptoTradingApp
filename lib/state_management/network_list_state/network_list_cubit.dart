import 'package:bloc/bloc.dart';
import 'package:coin_analyzer/models/network/networks_list_model.dart';
import 'package:coin_analyzer/utils/misc/box.dart';

part 'network_list_state.dart';

class NetworkListCubit extends Cubit<NetworkListState> {
  NetworkListCubit() : super(NetworkListInitial());

  Future<void> getNetworkList() async {
    try {
      emit(NetworkListLoading());
      final list = await BoxUtils.getNetworksList();

      emit(NetworkListFinal(list));
    } catch (e) {
      print(e.toString());
      emit(NetworkListError("Something Went wrong"));
    }
  }
}
