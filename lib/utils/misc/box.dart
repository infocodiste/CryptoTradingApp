import 'package:coin_analyzer/models/credential_models/credentails_list_model.dart';
import 'package:coin_analyzer/models/credential_models/credentials_model.dart';
import 'package:coin_analyzer/models/network/networks_list_model.dart';
import 'package:coin_analyzer/models/network/networks_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../constants.dart';
import 'credential_manager.dart';

class BoxUtils {
  static Future<void> initializeHive() async {
    await Hive.initFlutter("CoinAnalyzerHive");
    Hive.registerAdapter(CredentialsObjectAdapter());
    Hive.registerAdapter(CredentialsListAdapter());
    Hive.registerAdapter(NetworksObjectAdapter());
    Hive.registerAdapter(NetworksListAdapter());
  }

  static Future<bool> checkLogin() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    int len = box.length;
    if (len == 0)
      return false;
    else
      return true;
  }

  static Future<bool> setFirstAccount(String mnemonic, String privateKey,
      String address, String salt, String pin) async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    int len = box.length;
    var creds = new CredentialsObject()
      ..address = address
      ..privateKey = privateKey
      ..mnemonic = mnemonic;
    var credsList = new CredentialsList()
      ..active = 0
      ..credentials = [creds]
      ..salt = salt
      ..pin = pin;
    if (len == 1) {
      box.putAt(0, credsList);
    } else {
      box.add(credsList);
    }
    return true;
  }

  static Future<bool> addAccount(
    String privateKey,
    String address,
  ) async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    var mnemonic = box.getAt(0).credentials[0].mnemonic;
    var creds = new CredentialsObject()
      ..address = address
      ..privateKey = privateKey
      ..mnemonic = mnemonic;
    List<CredentialsObject> list = box.getAt(0).credentials;
    list.add(creds);
    CredentialsList credsList = box.getAt(0);
    credsList.credentials = list;
    box.putAt(0, credsList);
    return true;
  }

  static Future<int> getAccountCount() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    return box.getAt(0).credentials.length;
  }

  static Future<bool> setAccount(int id) async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    CredentialsList obj = box.getAt(0);
    obj.active = id;
    box.putAt(0, obj);
    return true;
  }

  static Future<CredentialsObject> getCredentialBox() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    int active = box.getAt(0).active;
    CredentialsObject creds = box.getAt(0).credentials[active];
    return creds;
  }

  static Future<Box<CredentialsList>> getCredentialsListBox() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    return box;
  }

  static Future<int> getActiveId() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    return box.getAt(0).active;
  }

  static Future<List<CredentialsObject>> getCredentialsList() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    List<CredentialsObject> creds = box.getAt(0).credentials;
    return creds;
  }

  static Future<String> getSalt() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    String salt = box.getAt(0).salt;
    return salt;
  }

  static Future<String> getPin() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    String pin = box.getAt(0).pin;
    return pin;
  }

  static Future<String> getAddress() async {
    Box<CredentialsList> box =
        await Hive.openBox<CredentialsList>(credentialBox);
    int active = box.getAt(0).active;
    return box.getAt(0).credentials[active].address;
  }

  // static Future<int> getNetworkConfig() async {
  //   Box<int> box = await Hive.openBox<int>(networkBox);
  //   int id = box.get(networkBox);
  //   return id;
  // }
  //
  // static Future<Box<int>> getNetworkIdBox() async {
  //   Box<int> box = await Hive.openBox<int>(networkBox);
  //   return box;
  // }
  //
  // static Future<void> setNetworkConfig(int id) async {
  //   Box<int> box = await Hive.openBox<int>(networkBox);
  //   box.put(networkBox, id);
  //   return;
  // }

  // static Future<void> addPendingTx(
  //     String tx, TransactionType type, String to) async {
  //   var network = await getNetworkConfig();
  //   var boxName = pendingTxBox + network.toString();
  //   Box<TransactionDetails> box =
  //       await Hive.openBox<TransactionDetails>(boxName);
  //   TransactionDetails txObj = TransactionDetails()
  //     ..txHash = tx
  //     ..txType = type.index
  //     ..network = network
  //     ..time = DateTime.now().toString()
  //     ..to = to;
  //   box.put(tx, txObj);
  //   await box.close();
  //   return;
  // }
  //
  // static Future<void> removePendingTx(String txhash) async {
  //   var network = await getNetworkConfig();
  //   var boxName = pendingTxBox + network.toString();
  //   Box<TransactionDetails> box =
  //       await Hive.openBox<TransactionDetails>(boxName);
  //   box.delete(txhash);
  //   await box.close();
  //   return;
  // }
  //
  // static Future<void> addDepositTransaction(
  //     String txhash,
  //     String name,
  //     String amount,
  //     String time,
  //     String imageUrl,
  //     String ticker,
  //     String fee) async {
  //   var network = await getNetworkConfig();
  //   var boxName = depositTransactionDbBox + network.toString();
  //   Box<DepositTransaction> box =
  //       await Hive.openBox<DepositTransaction>(boxName);
  //   DepositTransaction txObj = DepositTransaction()
  //     ..txHash = txhash
  //     ..amount = amount
  //     ..merged = false
  //     ..name = name
  //     ..imageUrl = imageUrl
  //     ..ticker = ticker
  //     ..fee = fee
  //     ..timeString = time;
  //   box.put(txhash, txObj);
  //   await box.close();
  //   return;
  // }
  //
  // static Future<void> updateDepositStatus(String txhash) async {
  //   var network = await getNetworkConfig();
  //   var boxName = depositTransactionDbBox + network.toString();
  //   Box<DepositTransaction> box =
  //       await Hive.openBox<DepositTransaction>(boxName);
  //
  //   DepositTransaction txObj = box.get(txhash);
  //   txObj.merged = true;
  //   txObj.save();
  //   await box.close();
  //   return;
  // }
  //
  // static Future<List<DepositTransaction>> getDepositTransactionsList() async {
  //   var network = await getNetworkConfig();
  //   var boxName = depositTransactionDbBox + network.toString();
  //   Box<DepositTransaction> box =
  //       await Hive.openBox<DepositTransaction>(boxName);
  //   var ls = <DepositTransaction>[];
  //   for (int i = 0; i < box.length; i++) {
  //     ls.add(box.getAt(i));
  //   }
  //   await box.close();
  //
  //   return ls;
  // }
  //
  // static Future<List<TransactionDetails>> getPendingTx(
  //     EtherScanTxList merged) async {
  //   var network = await getNetworkConfig();
  //   var boxName = pendingTxBox + network.toString();
  //   Box<TransactionDetails> box =
  //       await Hive.openBox<TransactionDetails>(boxName);
  //   var currentPending = <TransactionDetails>[];
  //   print(box.length);
  //   Map<String, TransactionDetails> map = {};
  //   box.values.forEach((element) {
  //     bool flag = false;
  //     for (int i = 0; i < merged.result.length; i++) {
  //       if (merged.result[i].hash == element.txHash) {
  //         flag = true;
  //         break;
  //       }
  //     }
  //     if (!flag) {
  //       map.putIfAbsent(element.txHash, () => element);
  //       currentPending.add(element);
  //     }
  //   });
  //   var keys = map.keys.toList();
  //   for (int i = 0; i < keys.length; i++) {
  //     try {
  //       await EthereumTransactions.getTrx(keys[i]);
  //     } catch (e) {
  //       map.remove(keys[i]);
  //     }
  //   }
  //   await box.clear();
  //   await box.putAll(map);
  //   await box.close();
  //   return currentPending;
  // }

  static Future<void> clear() async {
    var creds = await Hive.openBox<CredentialsList>(credentialBox);
    var networks = await Hive.openBox<NetworksList>(networkBox);
    await creds.clear();
    await networks.clear();
    creds.close();
    networks.close();
  }

  // static Future<void> addWithdrawTransaction(
  //     {String burnTxHash,
  //     TransactionType type,
  //     String userAddress,
  //     BridgeType bridge,
  //     String amount,
  //     String name,
  //     String addressRootToken,
  //     String addressChildToken,
  //     String timestring,
  //     String fee,
  //     int notificationId,
  //     String imageUrl
  //     // String confirmHash = "",
  //     // String exitHash = "",
  //     }) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = withdrawdbBox + network.toString() + address;
  //   Box<WithdrawDataDb> box = await Hive.openBox<WithdrawDataDb>(boxName);
  //   WithdrawDataDb txObj = WithdrawDataDb()
  //     ..burnHash = burnTxHash
  //     ..userAddress = userAddress
  //     ..addressChild = addressChildToken
  //     ..addressRoot = addressRootToken
  //     ..bridge = bridge.index
  //     ..amount = amount
  //     ..name = name
  //     ..notificationId = notificationId
  //     ..timeString = timestring
  //     ..imageUrl = imageUrl
  //     ..fee = fee;
  //   await box.put(burnTxHash, txObj);
  //   await box.close();
  //   return;
  // }

  // static Future<void> addPosExitHash({
  //   String burnTxHash,
  //   String exitHash,
  // }) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = withdrawdbBox + network.toString() + address;
  //   Box<WithdrawDataDb> box = await Hive.openBox<WithdrawDataDb>(boxName);
  //   var tx = box.get(burnTxHash);
  //   tx
  //     ..burnHash = burnTxHash
  //     ..exitHash = exitHash;
  //   await tx.save();
  //   await box.close();
  //   return;
  // }
  //
  // static Future<void> addPlasmaExitHash({
  //   String burnTxHash,
  //   String exitHash,
  // }) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = withdrawdbBox + network.toString() + address;
  //   Box<WithdrawDataDb> box = await Hive.openBox<WithdrawDataDb>(boxName);
  //   var tx = box.get(burnTxHash);
  //   tx..exitHash = exitHash;
  //   await tx.save();
  //   await box.close();
  //   return;
  // }
  //
  // static Future<void> markWithdrawComplete({
  //   String burnTxHash,
  // }) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = withdrawdbBox + network.toString() + address;
  //   Box<WithdrawDataDb> box = await Hive.openBox<WithdrawDataDb>(boxName);
  //   var tx = box.get(burnTxHash);
  //   tx..exited = true;
  //   await tx.save();
  //   await box.close();
  //   return;
  // }
  //
  // static Future<void> clearWithdraw() async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = withdrawdbBox + network.toString() + address;
  //   Box<WithdrawDataDb> box = await Hive.openBox<WithdrawDataDb>(boxName);
  //   box.clear();
  // }
  //
  // static Future<void> addPlasmaConfirmHash({
  //   String burnTxHash,
  //   String confirmHash,
  // }) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = withdrawdbBox + network.toString() + address;
  //   Box<WithdrawDataDb> box = await Hive.openBox<WithdrawDataDb>(boxName);
  //   var tx = box.get(burnTxHash);
  //   tx..confirmHash = confirmHash;
  //   await tx.save();
  //   await box.close();
  //   return;
  // }
  //
  // static Future<void> addUnbondTxData(
  //     {String validatorAddress,
  //     String userAddress,
  //     String amount,
  //     String name,
  //     String timestring,
  //     int validatorId,
  //     int notificationId,
  //     BigInt slippage}) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = unbondDbBox + network.toString() + address;
  //   var _amt = EthConversions.ethToWei(amount);
  //   Box<UnbondingDataDb> box = await Hive.openBox<UnbondingDataDb>(boxName);
  //   UnbondingDataDb txObj = UnbondingDataDb()
  //     ..userAddress = userAddress
  //     ..amount = _amt
  //     ..name = name
  //     ..notificationId = notificationId
  //     ..validatorId = validatorId
  //     ..timeString = timestring
  //     ..claimed = false
  //     ..slippage = slippage
  //     ..validatorAddress = validatorAddress;
  //   box.put(validatorAddress, txObj);
  //   await box.close();
  //   return;
  // }
  //
  // static Future<List<UnbondingDataDb>> getUnbondingList() async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = unbondDbBox + network.toString() + address;
  //   var ls = <UnbondingDataDb>[];
  //   Box<UnbondingDataDb> box = await Hive.openBox<UnbondingDataDb>(boxName);
  //   for (int i = 0; i < box.length; i++) {
  //     ls.add(box.getAt(i));
  //   }
  //   return ls;
  // }
  //
  // static Future<List<WithdrawDataDb>> getWithdrawList() async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = withdrawdbBox + network.toString() + address;
  //   Box<WithdrawDataDb> box = await Hive.openBox<WithdrawDataDb>(boxName);
  //   var ls = <WithdrawDataDb>[];
  //   for (int i = 0; i < box.length; i++) {
  //     ls.add(box.getAt(i));
  //   }
  //   return ls;
  // }
  //
  // static Future<UnbondingDataDb> getUnbondingBox(
  //     String validatorAddress) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = unbondDbBox + network.toString() + address;
  //   Box<UnbondingDataDb> box = await Hive.openBox<UnbondingDataDb>(boxName);
  //   try {
  //     var bx = box.get(validatorAddress);
  //     return bx;
  //   } catch (e) {
  //     return null;
  //   }
  // }
  //
  // static Future<void> addUnbondTxDataMarkClaimed({
  //   String validatorAddress,
  //   String userAddress,
  // }) async {
  //   var network = await getNetworkConfig();
  //   var address = await CredentialManager.getAddress();
  //   var boxName = unbondDbBox + network.toString() + address;
  //   Box<UnbondingDataDb> box = await Hive.openBox<UnbondingDataDb>(boxName);
  //   UnbondingDataDb txObj = box.get(validatorAddress);
  //   txObj.claimed = true;
  //   await txObj.save();
  //   await box.close();
  //   return;
  // }

  static Future<void> setNewMnemonicBox(bool status
      // true - verified, false not verified
      ) async {
    Box<bool> box = await Hive.openBox<bool>(newMnemonicBox);
    if (box.isEmpty) {
      box.add(status);
    } else {
      box.putAt(0, status);
    }
    return;
  }

  static Future<bool> getNewMnemonicBox() async {
    Box<bool> box = await Hive.openBox<bool>(newMnemonicBox);
    var status;
    try {
      status = box.getAt(0);
    } catch (e) {
      print(e.toString());
      return false;
    }
    return status;
  }

  // Network List
  static Future<bool> addNetwork(
      String name, String url, int chainId, int testNet) async {
    // var box = await Hive.openBox<NetworksList>(networkBox);
    // int len = box.length;
    // var network = new NetworksObject()
    //   ..name = name
    //   ..rpcUrl = url
    //   ..chainId = chainId
    //   ..testNet = testNet;
    //
    //
    // List<NetworksObject> list = box.getAt(0).networks;
    // list.add(network);
    // NetworksList networkList = box.getAt(0);
    // networkList.networks = list;
    // if (len == 1) {
    //   box.putAt(0, networkList);
    // } else {
    //   box.add(networkList);
    // }

    var box = await Hive.openBox<NetworksList>(networkBox);
    int len = box.length;
    var network = new NetworksObject()
      ..name = name
      ..rpcUrl = url
      ..chainId = chainId
      ..testNet = testNet;
    if (len == 1) {
      NetworksList networkList = box.getAt(0);
      var list = networkList.networks;
      var existNetwork = list.where((element) => element.chainId == chainId);
      if (existNetwork == null || existNetwork.isEmpty) {
        list.add(network);
        networkList.networks = list;
        networkList.active = 0;
        box.putAt(0, networkList);
      }
    } else {
      var networkList = new NetworksList()
        ..active = 0
        ..networks = [network];
      box.add(networkList);
    }
    return true;
  }

  static Future<bool> setNetwork(int id) async {
    var box = await Hive.openBox<NetworksList>(networkBox);
    NetworksList obj = box.getAt(0);
    obj.active = id;
    box.putAt(0, obj);
    return true;
  }

  static Future<NetworksObject> getActiveNetwork() async {
    var box = await Hive.openBox<NetworksList>(networkBox);
    int active = box.getAt(0).active;
    NetworksObject network = box.getAt(0).networks[active];
    return network;
  }

  static Future<Box<NetworksList>> getNetworkBox() async {
    var box = await Hive.openBox<NetworksList>(networkBox);
    return box;
  }

  static Future<int> getActiveNetworkId() async {
    var box = await Hive.openBox<NetworksList>(networkBox);
    return box.getAt(0).active;
  }

  static Future<NetworksList> getNetworksList() async {
    var box = await Hive.openBox<NetworksList>(networkBox);
    NetworksList networks = box.getAt(0);
    return networks;
  }

  static Future<List<NetworksObject>> getNetworkObjList() async {
    var box = await Hive.openBox<NetworksList>(networkBox);
    List<NetworksObject> networks = box.getAt(0).networks;
    return networks;
  }

  static Future<bool> checkNetworks() async {
    var box = await Hive.openBox<NetworksList>(networkBox);
    int len = box.length;
    if (len == 0)
      return false;
    else
      return true;
  }
}
