import 'dart:io';

import 'package:coin_analyzer/models/network/networks_model.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'logout_popup.dart';

class WalletAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;

  WalletAppBar(this._scaffoldKey);

  @override
  _WalletAppBar createState() => _WalletAppBar();
  @override
  final Size preferredSize = Size.fromHeight(70);
}

class _WalletAppBar extends State<WalletAppBar> {
  String address = "";
  NetworksObject networksObject;
  String fullAddress = "";
  bool isTestNet = false;

  @override
  void initState() {
    _refreshNetwork();
    _getAddress();
    super.initState();
  }

  _getAddress() async {
    fullAddress = await CredentialManager.getAddress();
    var start = fullAddress.substring(0, 8);
    var end = fullAddress.substring(fullAddress.length - 4);
    address = start + "..." + end;
    networksObject = await BoxUtils.getActiveNetwork();
    isTestNet = networksObject.testNet == 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Theme.of(context).backgroundColor,
      // leadingWidth: 16,
      // leading: IconButton(
      //   icon: Icon(Icons.menu_open),
      //   onPressed: () {
      //     widget._scaffoldKey.currentState.openDrawer();
      //   },
      // ),
      titleSpacing: 4,
      title: SizedBox(
        width: isTestNet ? 230 : 180,
        child: FlatButton(
          onPressed: () {
            Clipboard.setData(new ClipboardData(text: fullAddress));
            Fluttertoast.showToast(msg: "Address Copied");
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.all(0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            elevation: 0,
            color: Theme.of(context).primaryColorLight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Icon(
                    Icons.account_circle_sharp,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(
                    address,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Colors.white),
                  ),
                ),
                isTestNet
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: Text(
                              "TEST",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // IconButton(
            //   icon: Image.asset(
            //     "assets/icons/qr_icon.png",
            //     color: Theme.of(context).iconTheme.color,
            //   ),
            //   onPressed: () async {},
            // ),
            IconButton(
              icon: Icon(
                Icons.power_settings_new_outlined,
                // color: AppTheme.darkerText,
              ),
              onPressed: _logout,
            )
          ],
        )
      ],
    );
  }

  _logout() {
    PopUpDialogLogout.showAlertDialog(context);
  }

  _refreshNetwork() async {
    var configBox = await BoxUtils.getNetworkBox();
    var networkBCast = configBox.watch().asBroadcastStream();
    networkBCast.listen((event) async {
      var networkObj = await BoxUtils.getActiveNetwork();
      setState(() {
        this.isTestNet = networkObj.testNet == 1;
      });
    });
  }
}
