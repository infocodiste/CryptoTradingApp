import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import 'box.dart';

class WCHandler {
  static connect(BuildContext context, {bool isWallet = true}) {
    try {
      invokeNativePlatform.invokeMethod(CONNECT_METHOD).then((address) {
        print("Flutter >> result : $address");
        if (address != null) {
          BoxUtils.setFirstAccount(null, null, address, null, null);
          if (isWallet) {
            Navigator.pushNamed(context, myWalletRoute);
          } else {
            Navigator.pushNamed(context, chatGroupsRoute);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Can not connect wallet, try again later!")));
        }
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${e.message}")));
    }
  }

  static disconnect(BuildContext context) {
    try {
      invokeNativePlatform.invokeMethod(DISCONNECT_METHOD).then((results) {
        print("Flutter >> result : $results");
        if (results != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(results.toString())));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Can not connect wallet, try again later!")));
        }
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${e.message}")));
    }
  }

  static tokenTransactions(BuildContext context) {
    print("Flutter >> tokenTransactions : Called");
    try {
      invokeNativePlatform.invokeMethod(TRANSACTIONS_METHOD).then((results) {
        print("Flutter >> result : $results");
        if (results != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(results.toString())));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Can not connect wallet, try again later!")));
        }
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${e.message}")));
    }
  }
}
