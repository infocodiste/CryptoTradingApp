import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/utils/api/covalent_api_wrapper.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'covalent_token_list_state_ethereum.dart';

class CovalentTokensListEthCubit extends Cubit<CovalentTokensListEthState> {
  CovalentTokensListEthCubit() : super(CovalentTokensListEthInitial());
  Future<void> getTokensList() async {
    try {
      emit(CovalentTokensListEthLoading());
      final list = await CovalentApiWrapper.tokensList();

      emit(CovalentTokensListEthLoaded(list));
    } catch (e) {
      print(e.toString());
      emit(CovalentTokensListEthError("Something Went wrong"));
    }
  }

  Future<void> refresh() async {
    try {
      final list = await CovalentApiWrapper.tokensList();
      //emit(CovalentTokensListEthLoading());

      emit(CovalentTokensListEthLoaded(list));
    } on Exception {
      emit(CovalentTokensListEthError("Something Went wrong"));
    }
  }
}
