import 'dart:async';

import 'package:coin_analyzer/models/covalent_models/covalent_token_list.dart';
import 'package:coin_analyzer/models/network/networks_model.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:coin_analyzer/utils/network/network_config.dart';
import 'package:coin_analyzer/utils/network/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../../constants.dart';
import 'eth_conversions.dart';

class TokenWeb3Services {
  static Future<EtherAmount> getEthBalance() async {
    // NetworkConfigObject config = await NetworkManager.getNetworkObject();
    NetworksObject obj = await BoxUtils.getActiveNetwork();
    final client = Web3Client(obj.rpcUrl, http.Client());
    var address = await CredentialManager.getAddress();
    return await client.getBalance(EthereumAddress.fromHex(address));
  }

  static Future<BigInt> tokenBalance() async {
    // NetworkConfigObject config = await NetworkManager.getNetworkObject();
    NetworksObject obj = await BoxUtils.getActiveNetwork();

    final client = Web3Client(obj.rpcUrl, http.Client());

    var address = await CredentialManager.getAddress();

    String abi = await rootBundle.loadString(TejaTokenContractAbi);

    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "TejaTokenKovan"),
        EthereumAddress.fromHex("0x0d2eda610Ba6FaD1d0788b14A3F738319f802CD0"));

    var func = contract.function('balanceOf');

    var balance = await client.call(
      contract: contract,
      function: func,
      params: [EthereumAddress.fromHex(address)],
    );
    return balance[0];
  }

  static Future<String> sendTransaction(
      Transaction trx, BuildContext context) async {
    // NetworkConfigObject config = await NetworkManager.getNetworkObject();
    NetworksObject obj = await BoxUtils.getActiveNetwork();
    print("config.endpoint : ${obj.rpcUrl}");

    final client = Web3Client(obj.rpcUrl, http.Client());

    String privateKey = await CredentialManager.getPrivateKey(context);

    if (privateKey == null)
      return "failed";
    else {
      try {
        var credentials = await client.credentialsFromPrivateKey(privateKey);
        int networkId = await client.getNetworkId();

        var txHash = await client.sendTransaction(
          credentials,
          trx,
          chainId: networkId,
        );
        print("client network Id : $networkId");
        print("config network Id : ${obj.chainId}");
        print("Transfer Hash : $txHash");

        return txHash;
      } catch (e) {
        print(e.toString());
        if (e.toString() ==
            "RPCError: got code -32000 with msg \"insufficient funds for gas * price + value\".") {
          Fluttertoast.showToast(
              msg: "You don't have sufficient Token to make transaction",
              toastLength: Toast.LENGTH_LONG);
          return null;
        }
        Fluttertoast.showToast(
            msg: e.toString(), toastLength: Toast.LENGTH_LONG);
        return null;
      }
    }
  }

  static Future<Transaction> getAllowanceToken(String recipient) async {
    String abi = await rootBundle.loadString(TejaTokenContractAbi);
    String ownAddress = await CredentialManager.getAddress();
    final contract = DeployedContract(ContractAbi.fromJson(abi, "TejaToken"),
        EthereumAddress.fromHex("0x1ca45c6fdd89ad49e2dfd576afd6d6157b047300"));

    EtherAmount gasPrice =
        EtherAmount.fromUnitAndValue(EtherUnit.kwei, 9900000);
    print("gasPrice : ${gasPrice.toString()}");

    var func = contract.function('allowance');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      // gasPrice: gasPrice,
      // maxGas: 10000000,
      parameters: [
        EthereumAddress.fromHex(ownAddress),
        EthereumAddress.fromHex(recipient),
      ],
    );

    // var trx = Transaction(
    //     to: EthereumAddress.fromHex(ownAddress),
    //     gasPrice: EtherAmount.inWei(BigInt.one),
    //     maxGas: 100000,
    //     value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1));
    return trx;
  }

  static Future<Transaction> transferTejaToken(
      BigInt amt, String recipient) async {
    String abi = await rootBundle.loadString(TejaTokenContractAbi);

    final contract = DeployedContract(ContractAbi.fromJson(abi, "TejaToken"),
        EthereumAddress.fromHex("0x30aE710678C0Fb532Ee301cdAa292b8CB9483Ffd"));

    EtherAmount gasPrice =
        EtherAmount.fromUnitAndValue(EtherUnit.kwei, 9900000);
    print("gasPrice : ${gasPrice.toString()}");

    var func = contract.function('transfer');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      // gasPrice: gasPrice,
      // maxGas: 10000000,
      parameters: [
        // EthereumAddress.fromHex(ownAddress),
        EthereumAddress.fromHex(recipient),
        amt
      ],
    );

    // var trx = Transaction(
    //     to: EthereumAddress.fromHex(recipient),
    //     gasPrice: EtherAmount.inWei(BigInt.one),
    //     maxGas: 100000,
    //     value: EtherAmount.inWei(amt));
    return trx;
  }

  static Future<Transaction> transferERC20(String amount, String recipient,
      String erc20Address, BuildContext context) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    print(_amt);

    String abi = await rootBundle.loadString(erc20Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "ERC20"),
        EthereumAddress.fromHex(erc20Address));
    var transfer = contract.function('transfer');
    var trx = Transaction.callContract(
        contract: contract,
        function: transfer,
        maxGas: 210000,
        parameters: [EthereumAddress.fromHex(recipient.trim()), _amt]);
    return trx;
  }

  static Future<BigInt> getGasPrice() async {
    NetworksObject config = await BoxUtils.getActiveNetwork();
    final client = Web3Client(config.rpcUrl, http.Client());
    var price = await client.getGasPrice();
    return price.getInWei;
  }
}
