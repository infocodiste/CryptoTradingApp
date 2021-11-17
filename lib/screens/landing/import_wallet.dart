import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants.dart';
import '../../theme_data.dart';

class ImportWalletScreen extends StatefulWidget {
  @override
  _ImportWalletScreenState createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  TextEditingController seed = new TextEditingController();
  bool isSeeds = true;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    isSeeds = arguments["seeds"] ?? true;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "Import Wallet",
        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Card(
                  shape: AppTheme.cardShape,
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.paddingHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSeeds ? 'Mnemonic' : 'Private Key',
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight12 / 3,
                        ),
                        Text(
                          "Enter your ${isSeeds ? '12 (or 24) Word recovery phrase' : 'private key'} to import your existing wallet",
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight12,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.cardRadius),
                              color: AppTheme.warmgray_100,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                  width: 1, color: AppTheme.orange_500)),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            maxLines: null,
                            controller: seed,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (val) => isSeeds
                                ? val.trim().split(" ").length == 12
                                    ? null
                                    : 'Invalid Mnemonic'
                                : null,
                            style: AppTheme.label_medium
                                .copyWith(color: AppTheme.warmgray_600),
                            decoration: InputDecoration(
                              fillColor: AppTheme.warmgray_100,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelText: isSeeds ? "Mnemonic" : "Private Key",
                              hintText: isSeeds
                                  ? "Enter your Mnemonic"
                                  : "Enter your Private Key",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.buttonHeight_44,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: AppTheme.buttonHeight_44,
          margin: EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight12),
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: AppTheme.orange_500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.buttonRadius))),
            onPressed: _proceed,
            child: Text(
              'Continue',
              style:
                  AppTheme.label_medium.copyWith(color: AppTheme.lightgray_700),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _proceed() async {
    if (isSeeds && seed.text.trim().split(" ").length != 12) {
      Fluttertoast.showToast(
          msg: "Invalid Mnemonic",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    Navigator.pushNamed(context, landingSetPinRoute,
        arguments: [seed.text.trim(), false, isSeeds]);
  }
}
