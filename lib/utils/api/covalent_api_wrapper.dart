/*
https://api.covalenthq.com/v1/97/address/0xf605fc4fc37ded5aa5dec06ec3764567b7245352/balances_v2/?nft=true&key=ckey_92940427c13849f8a544dffa17b

https://api.covalenthq.com/v1/97/address/0x76d53710fc6028e845af092b818a9ec72f718465/transactions_v2/?contract-address=0x3b31d9e0a47e33177a9126bb8104b23236a580d4&key=ckey_92940427c13849f8a544dffa17b

https://www.covalenthq.com/docs/api*/

import 'dart:convert';

import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/models/covalent_models/token_history.dart';
import 'package:coin_analyzer/models/network/networks_model.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:http/http.dart' as http;

import 'api_key.dart';

class CovalentApiWrapper {
  static const baseUrl = "https://api.covalenthq.com/v1";

  static Future<CovalentTokenListResponse> tokensList() async {
    NetworksObject obj = await BoxUtils.getActiveNetwork();
    String address = await CredentialManager.getAddress();
    String url;
    CovalentTokenListResponse ctl;
    // https://api.covalenthq.com/v1/42/
    // address/0xf605fC4FC37DeD5aa5DeC06Ec3764567B7245352/balances_v2/?
    // nft=true&key=ckey_92940427c13849f8a544dffa17b
    // if (obj.testNet == 1) {
    //   url = baseUrl +
    //       "/${obj.chainId}/address/" +
    //       address +
    //       "/balances_v2/?nft=true&key=" +
    //       CovalentKey;
    // } else {
    //   url = baseUrl +
    //       "/1/address/" +
    //       address +
    //       "/balances_v2/?key=" +
    //       CovalentKey;
    // }
    url = baseUrl +
        "/${obj.chainId}/address/" +
        address +
        "/balances_v2/?nft=true&key=" +
        CovalentKey;
    print("tokensList - Url : $url");
    var resp = await http.get(Uri.parse(url));
    var json = jsonDecode(resp.body);
    ctl = CovalentTokenListResponse.fromJson(json);
    return ctl;
  }

  static Future<TokenHistory> tokenTransactions(String contractAddress) async {
    NetworksObject config = await BoxUtils.getActiveNetwork();
    TokenHistory ctl;
    String address = await CredentialManager.getAddress();
    String url = "https://api.covalenthq.com/v1/" +
        config.chainId.toString() +
        "/address/" +
        address +
        "/transactions_v2/?contract-address=" +
        contractAddress +
        "&key=" +
        CovalentKey;
    print("tokens transactions - Url : $url");
    var resp = await http.get(Uri.parse(url));
    var json = jsonDecode(resp.body);
    // ctl = TokenHistory.fromJson(json);
    ctl = TokenHistory.fromJson(json, contractAddress);
    return ctl;
  }
}
