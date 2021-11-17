import 'package:flutter/material.dart';

import 'wallet_app_bar.dart';
import 'wallet_body.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: WalletAppBar(_scaffoldKey),
      body: WalletBody(),
    );
  }
}
