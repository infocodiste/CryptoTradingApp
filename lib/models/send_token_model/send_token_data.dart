import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';

class SendTokenData {
  final CovalentToken token;
  final String amount;
  final String receiver;

  SendTokenData({this.token, this.amount, this.receiver});
}
